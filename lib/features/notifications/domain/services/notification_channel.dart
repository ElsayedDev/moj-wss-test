import 'package:equatable/equatable.dart';
import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';

enum RecipientInputKind { email, phone, token }

class NotificationChannelInfo extends Equatable {
  const NotificationChannelInfo({
    required this.id,
    required this.label,
    required this.recipientInputKind,
  });

  final String id;
  final String label;
  final RecipientInputKind recipientInputKind;

  @override
  List<Object> get props => [id, label, recipientInputKind];
}

abstract interface class NotificationChannel {
  String get id;

  String get label;

  RecipientInputKind get recipientInputKind;

  Result<void> validateRecipient(String recipient);

  Future<Result<NotificationSendReceipt>> send(NotificationRequest request);
}
