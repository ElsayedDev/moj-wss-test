import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';

class _ThrowingHistoryRepository implements NotificationRepository {
  @override
  Future<List<SentNotification>> history() async {
    throw StateError('storage unavailable');
  }

  @override
  Future<void> save(SentNotification notification) async {}
}

class _SeededHistoryRepository implements NotificationRepository {
  _SeededHistoryRepository(this.items);

  final List<SentNotification> items;

  @override
  Future<List<SentNotification>> history() async => items;

  @override
  Future<void> save(SentNotification notification) async {}
}

void main() {
  group('LoadNotificationHistory', () {
    test('returns saved history from the repository', () async {
      final item = SentNotification(
        id: 'item-1',
        channelId: 'email',
        channelLabel: 'Email',
        recipient: 'clerk@justice.gov',
        message: 'Body',
        sentAt: DateTime(2026, 5, 17, 12),
        receipt: const NotificationSendReceipt(
          providerMessageId: 'provider-1',
          status: 'accepted',
        ),
      );
      final useCase = LoadNotificationHistory(
        repository: _SeededHistoryRepository([item]),
      );

      final result = await useCase();

      expect(result.isSuccess, isTrue);
      expect(result.value, [item]);
    });

    test('maps repository exceptions to a general failure', () async {
      final useCase = LoadNotificationHistory(
        repository: _ThrowingHistoryRepository(),
      );

      final result = await useCase();

      expect(result.isFailure, isTrue);
      expect(result.error, 'Unable to load notification history.');
    });
  });
}
