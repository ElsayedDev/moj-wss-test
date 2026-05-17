import 'package:equatable/equatable.dart';

class NotificationRequest extends Equatable {
  const NotificationRequest({
    required this.channelId,
    required this.recipient,
    required this.message,
  });

  final String channelId;
  final String recipient;
  final String message;

  @override
  List<Object> get props => [channelId, recipient, message];
}
