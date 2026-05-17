import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class LoadNotificationHistory {
  const LoadNotificationHistory({required NotificationRepository repository})
    : _repository = repository;

  final NotificationRepository _repository;

  Future<Result<List<SentNotification>>> call() async {
    try {
      return Result.success(await _repository.history());
    } catch (_) {
      return Result.failure(
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Unable to load notification history.',
        ),
      );
    }
  }
}
