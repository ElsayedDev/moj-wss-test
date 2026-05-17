import 'package:flutter/material.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';

class NotificationChannelPresentation {
  const NotificationChannelPresentation({
    required this.channelId,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.sfSymbol,
    required this.selectedSfSymbol,
    required this.keyboardType,
    required this.recipientHint,
  });

  final String channelId;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String sfSymbol;
  final String selectedSfSymbol;
  final TextInputType keyboardType;
  final String recipientHint;

  IconData materialIcon({bool selected = false}) {
    return selected ? selectedIcon : icon;
  }

  String sfSymbolName({bool selected = false}) {
    return selected ? selectedSfSymbol : sfSymbol;
  }
}

abstract interface class NotificationChannelPresentationFactory {
  NotificationChannelPresentation resolve(NotificationChannelInfo channel);

  NotificationChannelPresentation resolveSent(SentNotification notification);
}

class DefaultNotificationChannelPresentationFactory
    implements NotificationChannelPresentationFactory {
  const DefaultNotificationChannelPresentationFactory({
    this.channelVisualSpecs = const {},
  });

  final Map<String, NotificationChannelVisualSpec> channelVisualSpecs;

  static const _fallbackSpec = NotificationChannelVisualSpec(
    icon: Icons.notifications_none_rounded,
    selectedIcon: Icons.notifications_rounded,
    sfSymbol: 'bell',
    selectedSfSymbol: 'bell.fill',
  );

  @override
  NotificationChannelPresentation resolve(NotificationChannelInfo channel) {
    return _build(
      channelId: channel.id,
      label: channel.label,
      recipientInputKind: channel.recipientInputKind,
    );
  }

  @override
  NotificationChannelPresentation resolveSent(SentNotification notification) {
    return _build(
      channelId: notification.channelId,
      label: notification.channelLabel,
      recipientInputKind: RecipientInputKind.token,
    );
  }

  NotificationChannelPresentation _build({
    required String channelId,
    required String label,
    required RecipientInputKind recipientInputKind,
  }) {
    final visualSpec = channelVisualSpecs[channelId] ?? _fallbackSpec;

    return NotificationChannelPresentation(
      channelId: channelId,
      label: label,
      icon: visualSpec.icon,
      selectedIcon: visualSpec.selectedIcon,
      sfSymbol: visualSpec.sfSymbol,
      selectedSfSymbol: visualSpec.selectedSfSymbol,
      keyboardType: _keyboardTypeFor(recipientInputKind),
      recipientHint: _hintFor(recipientInputKind),
    );
  }

  TextInputType _keyboardTypeFor(RecipientInputKind inputKind) {
    switch (inputKind) {
      case RecipientInputKind.email:
        return TextInputType.emailAddress;
      case RecipientInputKind.phone:
        return TextInputType.phone;
      case RecipientInputKind.token:
        return TextInputType.text;
    }
  }

  String _hintFor(RecipientInputKind inputKind) {
    switch (inputKind) {
      case RecipientInputKind.email:
        return 'name@example.gov';
      case RecipientInputKind.phone:
        return '+201001112222';
      case RecipientInputKind.token:
        return 'Device token';
    }
  }
}

class NotificationChannelVisualSpec {
  const NotificationChannelVisualSpec({
    required this.icon,
    required this.selectedIcon,
    required this.sfSymbol,
    required this.selectedSfSymbol,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String sfSymbol;
  final String selectedSfSymbol;
}
