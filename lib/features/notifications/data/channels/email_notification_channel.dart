import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class EmailNotificationChannel implements NotificationChannel {
  @override
  String get id => 'email';

  @override
  String get label => 'Email';

  @override
  RecipientInputKind get recipientInputKind => RecipientInputKind.email;

  @override
  Result<void> validateRecipient(String recipient) {
    final trimmed = recipient.trim();
    final isEmailLike = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);

    if (!isEmailLike) {
      return const Result.failure(
        NotificationFailure.recipient('Enter a valid email address.'),
      );
    }

    return const Result.success(null);
  }

  @override
  Future<Result<NotificationSendReceipt>> send(
    NotificationRequest request,
  ) async {
    if (request.channelId != id) {
      return const Result.failure(
        NotificationFailure.general(
          'Email channel can only send email notifications.',
        ),
      );
    }
    final recipient = request.recipient.trim();
    return Result.success(
      NotificationSendReceipt(
        providerMessageId: 'email-${recipient.hashCode.abs()}',
        status: 'accepted',
        metadata: {'recipient': recipient},
      ),
    );
  }
}
