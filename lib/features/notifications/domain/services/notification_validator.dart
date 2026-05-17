import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class NotificationValidator {
  const NotificationValidator._();

  static Result<void> validateRequiredFields(NotificationRequest request) {
    final recipient = request.recipient.trim();
    final message = request.message.trim();

    if (recipient.isEmpty) {
      return const Result.failure(
        NotificationFailure.recipient('Recipient is required.'),
      );
    }

    if (message.isEmpty) {
      return const Result.failure(
        NotificationFailure.message('Message is required.'),
      );
    }

    return const Result.success(null);
  }
}
