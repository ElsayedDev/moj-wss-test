import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

class SmsNotificationChannel implements NotificationChannel {
  @override
  String get id => 'sms';

  @override
  String get label => 'SMS';

  @override
  RecipientInputKind get recipientInputKind => RecipientInputKind.phone;

  @override
  Result<void> validateRecipient(String recipient) {
    final trimmed = recipient.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    final isPhoneLike =
        RegExp(r'^\+?[0-9][0-9\s\-()]{6,}$').hasMatch(trimmed) &&
        digits.length >= 7;

    if (!isPhoneLike) {
      return const Result.failure(
        NotificationFailure.recipient('Enter a valid phone number.'),
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
          'SMS channel can only send SMS notifications.',
        ),
      );
    }
    final recipient = request.recipient.trim();
    return Result.success(
      NotificationSendReceipt(
        providerMessageId: 'sms-${recipient.hashCode.abs()}',
        status: 'accepted',
        metadata: {'recipient': recipient},
      ),
    );
  }
}
