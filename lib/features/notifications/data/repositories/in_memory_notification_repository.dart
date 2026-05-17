import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';

class InMemoryNotificationRepository implements NotificationRepository {
  final List<SentNotification> _items = [];

  @override
  Future<void> save(SentNotification notification) async {
    _items.add(notification);
    _items.sort((left, right) => right.sentAt.compareTo(left.sentAt));
  }

  @override
  Future<List<SentNotification>> history() async => List.of(_items);
}
