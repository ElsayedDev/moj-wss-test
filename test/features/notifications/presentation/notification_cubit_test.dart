import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/data/repositories/in_memory_notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';

class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime(2026, 5, 17, 13);
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
  int sendCount = 0;

  @override
  Result<void> validateRecipient(String recipient) => validation;

  @override
  Future<Result<NotificationSendReceipt>> send(
    NotificationRequest request,
  ) async {
    sendCount += 1;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}

class _ThrowingHistoryRepository implements NotificationRepository {
  @override
  Future<List<SentNotification>> history() async {
    throw StateError('storage unavailable');
  }

  @override
  Future<void> save(SentNotification notification) async {}
}

NotificationCubit _buildCubit({
  Result<NotificationSendReceipt> result = const Result.success(
    NotificationSendReceipt(providerMessageId: 'receipt-1', status: 'accepted'),
  ),
  Result<void> validation = const Result.success(null),
  NotificationRepository? repository,
  Duration sendDelay = Duration.zero,
}) {
  final effectiveRepository = repository ?? InMemoryNotificationRepository();
  final sendNotification = SendNotification(
    registry: ChannelRegistry([
      _FakeChannel(
        id: 'email',
        label: 'Email',
        result: result,
        validation: validation,
        delay: sendDelay,
      ),
      _FakeChannel(id: 'sms', label: 'SMS', result: result),
      _FakeChannel(id: 'push', label: 'Push', result: result),
    ]),
    repository: effectiveRepository,
    clock: const _FixedClock(),
  );
  return NotificationCubit(
    sendNotification: sendNotification,
    loadHistory: LoadNotificationHistory(repository: effectiveRepository),
  );
}

void main() {
  group('NotificationCubit', () {
    test('starts with email selected and empty history', () {
      expect(
        _buildCubit().state,
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having(
              (state) => state.channels.map((channel) => channel.id),
              'channels',
              ['email', 'sms', 'push'],
            )
            .having((state) => state.history, 'history', isEmpty)
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.initial,
            ),
      );
    });

    blocTest<NotificationCubit, NotificationState>(
      'changing channel updates selected channel id',
      build: _buildCubit,
      act: (cubit) => cubit.onSelectChannel('sms'),
      expect: () => [
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'sms',
            )
            .having((state) => state.history, 'history', isEmpty)
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.initial,
            ),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'typed recipient failure maps to recipient validation error',
      build: () => _buildCubit(
        validation: const Result.failure(
          NotificationFailure(
            target: NotificationFailureTarget.recipient,
            message: 'Enter a valid email address.',
          ),
        ),
      ),
      act: (cubit) => cubit.onSend(recipient: 'invalid', message: 'Message'),
      expect: () => [
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.submitting,
            ),
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.failure,
            )
            .having(
              (state) => state.recipientError,
              'recipientError',
              'Enter a valid email address.',
            )
            .having((state) => state.messageError, 'messageError', isNull)
            .having((state) => state.generalError, 'generalError', isNull),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'valid send emits loading then success',
      build: _buildCubit,
      act: (cubit) => cubit.onSend(
        recipient: 'case.worker@justice.gov',
        message: 'Reminder ready',
      ),
      expect: () => [
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having((state) => state.history, 'history', isEmpty)
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.submitting,
            ),
        isA<NotificationState>()
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.success,
            )
            .having((state) => state.history, 'history', hasLength(1)),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'successful send adds newest item to history',
      build: _buildCubit,
      act: (cubit) async {
        await cubit.onSend(
          recipient: 'case.worker@justice.gov',
          message: 'First',
        );
        await cubit.onSend(
          recipient: 'case.worker@justice.gov',
          message: 'Second',
        );
      },
      verify: (cubit) {
        expect(cubit.state.history, hasLength(2));
        expect(cubit.state.history.first.message, 'Second');
      },
    );

    blocTest<NotificationCubit, NotificationState>(
      'send failure emits a general error state',
      build: () => _buildCubit(
        result: const Result.failure(
          NotificationFailure(
            target: NotificationFailureTarget.general,
            message: 'Gateway unavailable.',
          ),
        ),
      ),
      act: (cubit) => cubit.onSend(
        recipient: 'case.worker@justice.gov',
        message: 'Reminder ready',
      ),
      expect: () => [
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.submitting,
            ),
        isA<NotificationState>()
            .having(
              (state) => state.selectedChannelId,
              'selectedChannelId',
              'email',
            )
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.failure,
            )
            .having(
              (state) => state.generalError,
              'generalError',
              'Gateway unavailable.',
            ),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'loads existing history from repository',
      build: () {
        final repository = InMemoryNotificationRepository();
        repository.save(
          SentNotification(
            id: 'existing',
            channelId: 'sms',
            channelLabel: 'SMS',
            recipient: '+201001112222',
            message: 'Existing',
            sentAt: DateTime(2026, 5, 17, 10),
            receipt: const NotificationSendReceipt(
              providerMessageId: 'provider-existing',
              status: 'accepted',
            ),
          ),
        );
        return _buildCubit(repository: repository);
      },
      act: (cubit) => cubit.onLoadHistory(),
      expect: () => [
        isA<NotificationState>().having(
          (state) => state.history.single.message,
          'history.single.message',
          'Existing',
        ),
      ],
    );

    blocTest<NotificationCubit, NotificationState>(
      'load failure emits a general error state',
      build: () => _buildCubit(repository: _ThrowingHistoryRepository()),
      act: (cubit) => cubit.onLoadHistory(),
      expect: () => [
        isA<NotificationState>()
            .having(
              (state) => state.status,
              'status',
              NotificationStatus.failure,
            )
            .having(
              (state) => state.generalError,
              'generalError',
              'Unable to load notification history.',
            ),
      ],
    );

    test('ignores duplicate sends while submitting', () async {
      final cubit = _buildCubit(sendDelay: const Duration(milliseconds: 30));
      addTearDown(cubit.close);

      final firstSend = cubit.onSend(
        recipient: 'case.worker@justice.gov',
        message: 'First',
      );
      await Future<void>.delayed(Duration.zero);
      await cubit.onSend(
        recipient: 'case.worker@justice.gov',
        message: 'Second',
      );
      await firstSend;

      expect(cubit.state.history, hasLength(1));
      expect(cubit.state.history.single.message, 'First');
    });
  });
}
