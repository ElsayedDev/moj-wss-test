import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_validator.dart';

void main() {
  group('NotificationValidator', () {
    test('accepts a request with recipient and message', () {
      final result = NotificationValidator.validateRequiredFields(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'case.worker@justice.gov',
          message: 'Your hearing reminder is ready.',
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('rejects a missing recipient with a typed recipient failure', () {
      final result = NotificationValidator.validateRequiredFields(
        const NotificationRequest(
          channelId: 'push',
          recipient: '   ',
          message: 'A new filing was received.',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.recipient,
          message: 'Recipient is required.',
        ),
      );
      expect(result.error, 'Recipient is required.');
    });

    test('rejects a missing message with a typed message failure', () {
      final result = NotificationValidator.validateRequiredFields(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'case.worker@justice.gov',
          message: ' ',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.message,
          message: 'Message is required.',
        ),
      );
      expect(result.error, 'Message is required.');
    });
  });
}
