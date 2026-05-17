import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class PushNotificationChannel implements NotificationChannel {
  @override
  String get id => 'push';

  @override
  String get label => 'Push';

  @override
  RecipientInputKind get recipientInputKind => RecipientInputKind.token;

  @override
  Result<void> validateRecipient(String recipient) {
    final trimmed = recipient.trim();
    final isTokenLike = RegExp(r'^[A-Za-z0-9:_-]{8,}$').hasMatch(trimmed);

    if (!isTokenLike) {
      return const Result.failure(
        NotificationFailure.recipient('Enter a valid device token.'),
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
          'Push channel can only send push notifications.',
        ),
      );
    }
    final recipient = request.recipient.trim();
    return Result.success(
      NotificationSendReceipt(
        providerMessageId: 'push-${recipient.hashCode.abs()}',
        status: 'accepted',
        metadata: {'recipient': recipient},
      ),
    );
  }
}
