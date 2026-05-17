import 'package:equatable/equatable.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';

class SentNotification extends Equatable {
  const SentNotification({
    required this.id,
    required this.channelId,
    required this.channelLabel,
    required this.recipient,
    required this.message,
    required this.sentAt,
    required this.receipt,
  });

  final String id;
  final String channelId;
  final String channelLabel;
  final String recipient;
  final String message;
  final DateTime sentAt;
  final NotificationSendReceipt receipt;

  @override
  List<Object> get props => [
    id,
    channelId,
    channelLabel,
    recipient,
    message,
    sentAt,
    receipt,
  ];
}
