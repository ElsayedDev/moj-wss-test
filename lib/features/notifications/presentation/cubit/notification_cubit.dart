import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moj_wss_notification/features/notifications/application/load_notification_history.dart';
import 'package:moj_wss_notification/features/notifications/application/send_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required SendNotification sendNotification,
    required LoadNotificationHistory loadHistory,
  }) : _sendNotification = sendNotification,
       _loadHistory = loadHistory,
       super(NotificationState.initial(sendNotification.availableChannels));

  final SendNotification _sendNotification;
  final LoadNotificationHistory _loadHistory;

  void onSelectChannel(String channelId) {
    if (!state.channels.any((channel) => channel.id == channelId)) {
      return;
    }

    emit(
      state.copyWith(
        selectedChannelId: channelId,
        status: NotificationStatus.initial,
        clearRecipientError: true,
        clearMessageError: true,
        clearGeneralError: true,
      ),
    );
  }

  Future<void> onSend({
    required String recipient,
    required String message,
  }) async {
    if (state.isSubmitting) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationStatus.submitting,
        clearRecipientError: true,
        clearMessageError: true,
        clearGeneralError: true,
      ),
    );

    final result = await _sendNotification(
      NotificationRequest(
        channelId: state.selectedChannelId,
        recipient: recipient,
        message: message,
      ),
    );

    if (result.isSuccess) {
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          history: [result.value, ...state.history],
          clearRecipientError: true,
          clearMessageError: true,
          clearGeneralError: true,
        ),
      );
      return;
    }

    final error = result.errorObject;
    if (error is NotificationFailure) {
      emit(_failureStateFor(error));
      return;
    }

    emit(
      state.copyWith(
        status: NotificationStatus.failure,
        generalError: error.toString(),
      ),
    );
  }

  Future<void> onLoadHistory() async {
    final result = await _loadHistory();

    if (result.isSuccess) {
      emit(
        state.copyWith(
          history: result.value,
          status: NotificationStatus.initial,
          clearGeneralError: true,
        ),
      );
      return;
    }

    final error = result.errorObject;
    if (error is NotificationFailure) {
      emit(_failureStateFor(error));
      return;
    }

    emit(
      state.copyWith(
        status: NotificationStatus.failure,
        generalError: error.toString(),
      ),
    );
  }

  NotificationState _failureStateFor(NotificationFailure failure) =>
      switch (failure.target) {
        NotificationFailureTarget.recipient => state.copyWith(
          status: NotificationStatus.failure,
          recipientError: failure.message,
        ),
        NotificationFailureTarget.message => state.copyWith(
          status: NotificationStatus.failure,
          messageError: failure.message,
        ),
        NotificationFailureTarget.general => state.copyWith(
          status: NotificationStatus.failure,
          generalError: failure.message,
        ),
      };
}
