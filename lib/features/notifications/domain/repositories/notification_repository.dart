import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';

abstract interface class NotificationRepository {
  Future<void> save(SentNotification notification);

  Future<List<SentNotification>> history();
}
