import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/data/repositories/in_memory_notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class _FixedClock implements Clock {
  _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

class _FakeChannel implements NotificationChannel {
  _FakeChannel({
    required this.id,
    required this.label,
    this.result = const Result.success(
      NotificationSendReceipt(
        providerMessageId: 'receipt-1',
        status: 'accepted',
      ),
    ),
    this.validation = const Result.success(null),
    this.delay = Duration.zero,
    this.throwOnSend = false,
  });

  @override
  final String id;

  @override
  final String label;

  @override
  RecipientInputKind get recipientInputKind => RecipientInputKind.token;

  final Result<void> validation;
  final Result<NotificationSendReceipt> result;
  final Duration delay;
  final bool throwOnSend;
  int sendCount = 0;

  @override
  Result<void> validateRecipient(String recipient) => validation;

  @override
  Future<Result<NotificationSendReceipt>> send(
    NotificationRequest request,
  ) async {
    sendCount += 1;
    if (throwOnSend) {
      throw StateError('transport exploded');
    }
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}

class _ThrowingSaveRepository implements NotificationRepository {
  @override
  Future<List<SentNotification>> history() async => const [];

  @override
  Future<void> save(SentNotification notification) async {
    throw StateError('disk unavailable');
  }
}

void main() {
  group('SendNotification', () {
    test('validates required fields before resolving or sending', () async {
      final channel = _FakeChannel(id: 'email', label: 'Email');
      final useCase = SendNotification(
        registry: ChannelRegistry([channel]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: '',
          message: 'Body',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.recipient,
          message: 'Recipient is required.',
        ),
      );
      expect(channel.sendCount, 0);
    });

    test('delegates recipient validation to the resolved channel', () async {
      final channel = _FakeChannel(
        id: 'email',
        label: 'Email',
        validation: const Result.failure(
          NotificationFailure(
            target: NotificationFailureTarget.recipient,
            message: 'Enter a valid email address.',
          ),
        ),
      );
      final useCase = SendNotification(
        registry: ChannelRegistry([channel]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'invalid',
          message: 'Body',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'Enter a valid email address.');
      expect(channel.sendCount, 0);
    });

    test(
      'records successful sends with the injected clock timestamp',
      () async {
        final sentAt = DateTime(2026, 5, 17, 12, 30);
        final repository = InMemoryNotificationRepository();
        final useCase = SendNotification(
          registry: ChannelRegistry([_FakeChannel(id: 'push', label: 'Push')]),
          repository: repository,
          clock: _FixedClock(sentAt),
        );

        final result = await useCase(
          const NotificationRequest(
            channelId: 'push',
            recipient: 'device-347',
            message: 'Filing received',
          ),
        );

        expect(result.isSuccess, isTrue);
        expect(result.value.sentAt, sentAt);
        expect(result.value.channelId, 'push');
        expect(result.value.channelLabel, 'Push');
        expect(result.value.id, isNotEmpty);
        expect(await repository.history(), [result.value]);
      },
    );

    test('sends through only the selected channel', () async {
      final email = _FakeChannel(id: 'email', label: 'Email');
      final sms = _FakeChannel(id: 'sms', label: 'SMS');
      final useCase = SendNotification(
        registry: ChannelRegistry([email, sms]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'sms',
          recipient: '+201001234567',
          message: 'Code 4839',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(email.sendCount, 0);
      expect(sms.sendCount, 1);
    });

    test('does not record failed sends', () async {
      final repository = InMemoryNotificationRepository();
      final useCase = SendNotification(
        registry: ChannelRegistry([
          _FakeChannel(
            id: 'sms',
            label: 'SMS',
            result: const Result.failure(
              NotificationFailure(
                target: NotificationFailureTarget.general,
                message: 'Gateway unavailable.',
              ),
            ),
          ),
        ]),
        repository: repository,
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'sms',
          recipient: '+201001234567',
          message: 'Code 4839',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'Gateway unavailable.');
      expect(await repository.history(), isEmpty);
    });

    test('fails cleanly when selected channel is unsupported', () async {
      final useCase = SendNotification(
        registry: ChannelRegistry([_FakeChannel(id: 'email', label: 'Email')]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'whatsapp',
          recipient: '+201001234567',
          message: 'Code 4839',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'No notification channel registered for whatsapp.');
    });

    test('stores provider receipt on successful sends', () async {
      final repository = InMemoryNotificationRepository();
      final useCase = SendNotification(
        registry: ChannelRegistry([
          _FakeChannel(
            id: 'email',
            label: 'Email',
            result: const Result.success(
              NotificationSendReceipt(
                providerMessageId: 'provider-123',
                status: 'queued',
                metadata: {'gateway': 'mock-email'},
              ),
            ),
          ),
        ]),
        repository: repository,
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Receipt test',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.receipt.providerMessageId, 'provider-123');
      expect(result.value.receipt.status, 'queued');
      expect(result.value.receipt.metadata, {'gateway': 'mock-email'});
      expect((await repository.history()).single.receipt, result.value.receipt);
    });

    test('maps thrown provider exceptions to a general failure', () async {
      final useCase = SendNotification(
        registry: ChannelRegistry([
          _FakeChannel(id: 'email', label: 'Email', throwOnSend: true),
        ]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Body',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'Unable to send notification. Please try again.');
    });

    test('maps provider timeouts to a general failure', () async {
      final useCase = SendNotification(
        registry: ChannelRegistry([
          _FakeChannel(
            id: 'email',
            label: 'Email',
            delay: const Duration(milliseconds: 50),
          ),
        ]),
        repository: InMemoryNotificationRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
        sendTimeout: const Duration(milliseconds: 1),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Body',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.error, 'Notification provider timed out.');
    });

    test('maps repository save failures after send', () async {
      final useCase = SendNotification(
        registry: ChannelRegistry([_FakeChannel(id: 'email', label: 'Email')]),
        repository: _ThrowingSaveRepository(),
        clock: _FixedClock(DateTime(2026, 5, 17, 12)),
      );

      final result = await useCase(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Body',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.error,
        'Notification sent but history could not be updated.',
      );
    });
  });
}
