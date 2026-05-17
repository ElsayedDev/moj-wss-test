// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Notification Center';

  @override
  String get createMessageTooltip => 'Create message';

  @override
  String get filterMessagesTooltip => 'Filter messages';

  @override
  String get allFilterLabel => 'All';

  @override
  String get newNotificationTitle => 'New Notification';

  @override
  String get cancelTooltip => 'Cancel';

  @override
  String channelLabel({required String channel}) {
    return '$channel Channel';
  }

  @override
  String get recipientLabel => 'Recipient';

  @override
  String get messageContentLabel => 'Message Content';

  @override
  String get messageHint => 'Type a notification';

  @override
  String get sendButtonLabel => 'Send';

  @override
  String get sendingButtonLabel => 'Sending';

  @override
  String get notificationSent => 'Notification sent.';

  @override
  String get emptyAllTitle => 'No notifications yet';

  @override
  String emptyChannelTitle({required String channel}) {
    return 'No $channel notifications yet';
  }

  @override
  String get emptyAllBody =>
      'Create a notification to start the message history.';

  @override
  String get emptyChannelBody =>
      'Create or show all messages to review other channels.';

  @override
  String recipientPrefix({required String recipient}) {
    return 'To $recipient';
  }

  @override
  String providerIconLabel({required String channel}) {
    return '$channel notification';
  }
}
