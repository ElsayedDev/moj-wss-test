import 'package:equatable/equatable.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';

enum NotificationStatus { initial, submitting, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    required this.channels,
    required this.selectedChannelId,
    required this.history,
    required this.status,
    this.recipientError,
    this.messageError,
    this.generalError,
  });

  factory NotificationState.initial(List<NotificationChannelInfo> channels) {
    return NotificationState(
      channels: channels,
      selectedChannelId: channels.isEmpty ? '' : channels.first.id,
      history: const [],
      status: NotificationStatus.initial,
    );
  }

  final List<NotificationChannelInfo> channels;
  final String selectedChannelId;
  final List<SentNotification> history;
  final NotificationStatus status;
  final String? recipientError;
  final String? messageError;
  final String? generalError;

  bool get isSubmitting => status == NotificationStatus.submitting;

  NotificationChannelInfo get selectedChannel {
    return channels.firstWhere(
      (channel) => channel.id == selectedChannelId,
      orElse: () => channels.first,
    );
  }

  NotificationState copyWith({
    List<NotificationChannelInfo>? channels,
    String? selectedChannelId,
    List<SentNotification>? history,
    NotificationStatus? status,
    String? recipientError,
    String? messageError,
    String? generalError,
    bool clearRecipientError = false,
    bool clearMessageError = false,
    bool clearGeneralError = false,
  }) {
    return NotificationState(
      channels: channels ?? this.channels,
      selectedChannelId: selectedChannelId ?? this.selectedChannelId,
      history: history ?? this.history,
      status: status ?? this.status,
      recipientError: clearRecipientError
          ? null
          : recipientError ?? this.recipientError,
      messageError: clearMessageError
          ? null
          : messageError ?? this.messageError,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
    );
  }

  @override
  List<Object?> get props => [
    channels,
    selectedChannelId,
    history,
    status,
    recipientError,
    messageError,
    generalError,
  ];
}
