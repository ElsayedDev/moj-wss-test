import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/data/repositories/in_memory_notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';

void main() {
  group('InMemoryNotificationRepository', () {
    test('stores notifications newest first', () async {
      final repository = InMemoryNotificationRepository();
      final older = SentNotification(
        id: 'older',
        channelId: 'email',
        channelLabel: 'Email',
        recipient: 'first@justice.gov',
        message: 'First',
        sentAt: DateTime(2026, 5, 17, 10),
        receipt: const NotificationSendReceipt(
          providerMessageId: 'provider-older',
          status: 'accepted',
        ),
      );
      final newer = SentNotification(
        id: 'newer',
        channelId: 'sms',
        channelLabel: 'SMS',
        recipient: '+201001234567',
        message: 'Second',
        sentAt: DateTime(2026, 5, 17, 11),
        receipt: const NotificationSendReceipt(
          providerMessageId: 'provider-newer',
          status: 'accepted',
        ),
      );

      await repository.save(older);
      await repository.save(newer);

      final history = await repository.history();
      expect(history.map((item) => item.id), ['newer', 'older']);
    });

    test('returns a defensive copy of history', () async {
      final repository = InMemoryNotificationRepository();
      await repository.save(
        SentNotification(
          id: 'item',
          channelId: 'push',
          channelLabel: 'Push',
          recipient: 'device-1',
          message: 'Body',
          sentAt: DateTime(2026, 5, 17, 10),
          receipt: const NotificationSendReceipt(
            providerMessageId: 'provider-item',
            status: 'accepted',
          ),
        ),
      );

      final history = await repository.history();
      history.clear();

      final nextHistory = await repository.history();
      expect(nextHistory, hasLength(1));
    });
  });
}
