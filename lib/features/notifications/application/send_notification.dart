import 'dart:async';

import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/core/result.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_send_receipt.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_validator.dart';

class SendNotification {
  const SendNotification({
    required ChannelRegistry registry,
    required NotificationRepository repository,
    required Clock clock,
    Duration sendTimeout = const Duration(seconds: 5),
  }) : _registry = registry,
       _repository = repository,
       _clock = clock,
       _sendTimeout = sendTimeout;

  final ChannelRegistry _registry;
  final NotificationRepository _repository;
  final Clock _clock;
  final Duration _sendTimeout;

  List<NotificationChannelInfo> get availableChannels => _registry.channels;

  Future<Result<SentNotification>> call(NotificationRequest request) async {
    final validation = NotificationValidator.validateRequiredFields(request);
    if (validation.isFailure) {
      return Result.failure(validation.errorObject);
    }

    final channelResult = _registry.resolve(request.channelId);
    if (channelResult.isFailure) {
      return Result.failure(channelResult.errorObject);
    }

    final channel = channelResult.value;
    final recipientValidation = channel.validateRecipient(request.recipient);
    if (recipientValidation.isFailure) {
      return Result.failure(recipientValidation.errorObject);
    }

    final Result<NotificationSendReceipt> sendResult;
    try {
      sendResult = await channel
          .send(request)
          .timeout(
            _sendTimeout,
            onTimeout: () => Result.failure(
              const NotificationFailure(
                target: NotificationFailureTarget.general,
                message: 'Notification provider timed out.',
              ),
            ),
          );
    } on TimeoutException {
      return Result.failure(
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Notification provider timed out.',
        ),
      );
    } catch (_) {
      return Result.failure(
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Unable to send notification. Please try again.',
        ),
      );
    }
    if (sendResult.isFailure) {
      return Result.failure(sendResult.errorObject);
    }

    final sentAt = _clock.now();
    final notification = SentNotification(
      id: '${request.channelId}-${sentAt.microsecondsSinceEpoch}',
      channelId: request.channelId,
      channelLabel: channel.label,
      recipient: request.recipient.trim(),
      message: request.message.trim(),
      sentAt: sentAt,
      receipt: sendResult.value,
    );
    try {
      await _repository.save(notification);
    } catch (_) {
      return Result.failure(
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Notification sent but history could not be updated.',
        ),
      );
    }
    return Result.success(notification);
  }
}
