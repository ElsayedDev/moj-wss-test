import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/application/channel_registry.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/email_notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/data/channels/sms_notification_channel.dart';

void main() {
  group('ChannelRegistry', () {
    test('resolves registered channels by channel id', () {
      final email = EmailNotificationChannel();
      final sms = SmsNotificationChannel();
      final registry = ChannelRegistry([email, sms]);

      expect(registry.resolve('email').value, same(email));
      expect(registry.resolve('sms').value, same(sms));
    });

    test('exposes registered channel metadata in registration order', () {
      final registry = ChannelRegistry([
        EmailNotificationChannel(),
        SmsNotificationChannel(),
      ]);

      expect(registry.channels.map((channel) => channel.id), ['email', 'sms']);
      expect(registry.channels.map((channel) => channel.label), [
        'Email',
        'SMS',
      ]);
    });

    test('fails cleanly when a provider is missing', () {
      final registry = ChannelRegistry([EmailNotificationChannel()]);

      final result = registry.resolve('push');

      expect(result.isFailure, isTrue);
      expect(result.error, 'No notification channel registered for push.');
    });

    test('rejects duplicate channel ids', () {
      expect(
        () => ChannelRegistry([
          EmailNotificationChannel(),
          EmailNotificationChannel(),
        ]),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Duplicate notification channel id: email.',
          ),
        ),
      );
    });
  });
}
