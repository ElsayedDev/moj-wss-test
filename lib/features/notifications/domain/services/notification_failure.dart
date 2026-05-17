import 'package:equatable/equatable.dart';

enum NotificationFailureTarget { recipient, message, general }

class NotificationFailure extends Equatable {
  const NotificationFailure({required this.target, required this.message});

  const NotificationFailure.recipient(String message)
    : this(target: NotificationFailureTarget.recipient, message: message);

  const NotificationFailure.message(String message)
    : this(target: NotificationFailureTarget.message, message: message);

  const NotificationFailure.general(String message)
    : this(target: NotificationFailureTarget.general, message: message);

  final NotificationFailureTarget target;
  final String message;

  @override
  List<Object> get props => [target, message];

  @override
  String toString() => message;
}
