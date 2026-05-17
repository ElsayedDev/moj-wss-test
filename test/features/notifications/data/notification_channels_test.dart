import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/email_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/push_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/sms_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/notification_request.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_failure.dart';

void main() {
  group('notification channels', () {
    test('email channel exposes metadata and validates email recipients', () {
      final channel = EmailNotificationChannel();

      expect(channel.id, 'email');
      expect(channel.label, 'Email');
      expect(channel.recipientInputKind, RecipientInputKind.email);
      expect(channel.validateRecipient('clerk@justice.gov').isSuccess, isTrue);

      final invalid = channel.validateRecipient('clerk');

      expect(invalid.isFailure, isTrue);
      expect(
        invalid.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.recipient,
          message: 'Enter a valid email address.',
        ),
      );
    });

    test('email channel sends email requests', () async {
      final channel = EmailNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Email body',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.providerMessageId, startsWith('email-'));
      expect(result.value.status, 'accepted');
      expect(result.value.metadata, {'recipient': 'clerk@justice.gov'});
    });

    test('sms channel exposes metadata and validates phone recipients', () {
      final channel = SmsNotificationChannel();

      expect(channel.id, 'sms');
      expect(channel.label, 'SMS');
      expect(channel.recipientInputKind, RecipientInputKind.phone);
      expect(channel.validateRecipient('+20 (100) 123-4567').isSuccess, isTrue);

      final invalid = channel.validateRecipient('call-me');

      expect(invalid.isFailure, isTrue);
      expect(
        invalid.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.recipient,
          message: 'Enter a valid phone number.',
        ),
      );
    });

    test('sms channel sends sms requests', () async {
      final channel = SmsNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'sms',
          recipient: '+201001234567',
          message: 'SMS body',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.providerMessageId, startsWith('sms-'));
      expect(result.value.status, 'accepted');
      expect(result.value.metadata, {'recipient': '+201001234567'});
    });

    test('push channel exposes metadata and validates device tokens', () {
      final channel = PushNotificationChannel();

      expect(channel.id, 'push');
      expect(channel.label, 'Push');
      expect(channel.recipientInputKind, RecipientInputKind.token);
      expect(channel.validateRecipient('device-token_12').isSuccess, isTrue);

      final invalid = channel.validateRecipient('short');

      expect(invalid.isFailure, isTrue);
      expect(
        invalid.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.recipient,
          message: 'Enter a valid device token.',
        ),
      );
    });

    test('push channel sends push requests', () async {
      final channel = PushNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'push',
          recipient: 'device-token_12',
          message: 'Push body',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.providerMessageId, startsWith('push-'));
      expect(result.value.status, 'accepted');
      expect(result.value.metadata, {'recipient': 'device-token_12'});
    });

    test('email channel rejects a request for a different type', () async {
      final channel = EmailNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'sms',
          recipient: '+201001234567',
          message: 'Wrong channel',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Email channel can only send email notifications.',
        ),
      );
    });

    test('sms channel rejects a request for a different type', () async {
      final channel = SmsNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'email',
          recipient: 'clerk@justice.gov',
          message: 'Wrong channel',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'SMS channel can only send SMS notifications.',
        ),
      );
    });

    test('push channel rejects a request for a different type', () async {
      final channel = PushNotificationChannel();

      final result = await channel.send(
        const NotificationRequest(
          channelId: 'sms',
          recipient: '+201001234567',
          message: 'Wrong channel',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.errorObject,
        const NotificationFailure(
          target: NotificationFailureTarget.general,
          message: 'Push channel can only send push notifications.',
        ),
      );
    });
  });
}
