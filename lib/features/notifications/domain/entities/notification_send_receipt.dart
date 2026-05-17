import 'package:equatable/equatable.dart';

class NotificationSendReceipt extends Equatable {
  const NotificationSendReceipt({
    required this.providerMessageId,
    required this.status,
    this.metadata = const {},
  });

  final String providerMessageId;
  final String status;
  final Map<String, String> metadata;

  @override
  List<Object> get props => [providerMessageId, status, metadata];
}
