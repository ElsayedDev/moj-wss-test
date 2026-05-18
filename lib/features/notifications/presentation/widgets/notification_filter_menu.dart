import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_adaptive_controls.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationFilterMenu extends StatelessWidget {
  const NotificationFilterMenu({
    super.key,
    required this.selectedValue,
    required this.channels,
    required this.onSelected,
  });

  static const allValue = '__all__';

  final String selectedValue;
  final List<NotificationChannelInfo> channels;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final presentationFactory = context
        .read<NotificationChannelPresentationFactory>();
    final controls = NotificationAdaptiveControls.resolve(context);

    return controls.menu<String>(
      context: context,
      trigger: NotificationAdaptiveMenuTrigger(
        key: const ValueKey('message-filter-menu'),
        tooltip: context.l10n.filterMessagesTooltip,
        materialIcon: Icons.filter_list_rounded,
        cupertinoSymbol: 'line.3.horizontal.decrease.circle',
      ),
      options: [
        NotificationAdaptiveMenuOption<String>(
          value: allValue,
          label: context.l10n.allFilterLabel,
          materialIcon: Icons.all_inbox_rounded,
          cupertinoSymbol: 'tray.full',
          selected: selectedValue == allValue,
        ),
        for (final channel in channels)
          NotificationAdaptiveMenuOption<String>(
            value: channel.id,
            label: channel.label,
            materialIcon: presentationFactory
                .resolve(channel)
                .materialIcon(selected: channel.id == selectedValue),
            cupertinoSymbol: presentationFactory
                .resolve(channel)
                .sfSymbolName(selected: channel.id == selectedValue),
            selected: channel.id == selectedValue,
          ),
      ],
      onSelected: onSelected,
    );
  }
}
