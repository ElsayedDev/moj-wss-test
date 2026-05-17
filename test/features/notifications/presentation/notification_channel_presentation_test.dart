import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';

void main() {
  group('DefaultNotificationChannelPresentationFactory', () {
    const factory = DefaultNotificationChannelPresentationFactory(
      channelVisualSpecs: {
        'email': NotificationChannelVisualSpec(
          icon: Icons.mail_outline_rounded,
          selectedIcon: Icons.mail_rounded,
          sfSymbol: 'envelope',
          selectedSfSymbol: 'envelope.fill',
        ),
        'sms': NotificationChannelVisualSpec(
          icon: Icons.sms_outlined,
          selectedIcon: Icons.sms_rounded,
          sfSymbol: 'message',
          selectedSfSymbol: 'message.fill',
        ),
        'push': NotificationChannelVisualSpec(
          icon: Icons.notifications_none_rounded,
          selectedIcon: Icons.notifications_rounded,
          sfSymbol: 'bell',
          selectedSfSymbol: 'bell.fill',
        ),
      },
    );

    test('resolves email presentation', () {
      final presentation = factory.resolve(
        const NotificationChannelInfo(
          id: 'email',
          label: 'Email',
          recipientInputKind: RecipientInputKind.email,
        ),
      );

      expect(presentation.channelId, 'email');
      expect(presentation.label, 'Email');
      expect(presentation.icon, Icons.mail_outline_rounded);
      expect(presentation.selectedIcon, Icons.mail_rounded);
      expect(presentation.sfSymbol, 'envelope');
      expect(presentation.selectedSfSymbol, 'envelope.fill');
      expect(presentation.keyboardType, TextInputType.emailAddress);
      expect(presentation.recipientHint, 'name@example.gov');
    });

    test('resolves sms presentation', () {
      final presentation = factory.resolve(
        const NotificationChannelInfo(
          id: 'sms',
          label: 'SMS',
          recipientInputKind: RecipientInputKind.phone,
        ),
      );

      expect(presentation.icon, Icons.sms_outlined);
      expect(presentation.selectedIcon, Icons.sms_rounded);
      expect(presentation.sfSymbol, 'message');
      expect(presentation.selectedSfSymbol, 'message.fill');
      expect(presentation.keyboardType, TextInputType.phone);
      expect(presentation.recipientHint, '+201001112222');
    });

    test('resolves push presentation', () {
      final presentation = factory.resolve(
        const NotificationChannelInfo(
          id: 'push',
          label: 'Push',
          recipientInputKind: RecipientInputKind.token,
        ),
      );

      expect(presentation.icon, Icons.notifications_none_rounded);
      expect(presentation.selectedIcon, Icons.notifications_rounded);
      expect(presentation.sfSymbol, 'bell');
      expect(presentation.selectedSfSymbol, 'bell.fill');
      expect(presentation.keyboardType, TextInputType.text);
      expect(presentation.recipientHint, 'Device token');
    });

    test('falls back safely for unknown providers', () {
      final presentation = factory.resolve(
        const NotificationChannelInfo(
          id: 'whatsapp',
          label: 'WhatsApp',
          recipientInputKind: RecipientInputKind.phone,
        ),
      );

      expect(presentation.channelId, 'whatsapp');
      expect(presentation.label, 'WhatsApp');
      expect(presentation.icon, Icons.notifications_none_rounded);
      expect(presentation.selectedIcon, Icons.notifications_rounded);
      expect(presentation.sfSymbol, 'bell');
      expect(presentation.selectedSfSymbol, 'bell.fill');
      expect(presentation.keyboardType, TextInputType.phone);
      expect(presentation.recipientHint, '+201001112222');
    });
  });
}
