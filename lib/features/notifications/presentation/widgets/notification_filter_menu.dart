import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moj_wss_notification/features/notifications/domain/services/notification_channel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final presentationFactory = context
        .read<NotificationChannelPresentationFactory>();
    final values = [allValue, for (final channel in channels) channel.id];

    return Semantics(
      label: context.l10n.filterMessagesTooltip,
      button: true,
      child: CNPopupMenuButton.icon(
        key: const ValueKey('message-filter-menu'),
        buttonIcon: CNSymbol('line.3.horizontal.decrease.circle', size: 20),
        buttonStyle: CNButtonStyle.glass,
        tint: colorScheme.primary,
        items: [
          CNPopupMenuItem(
            label: context.l10n.allFilterLabel,
            icon: const CNSymbol('tray.full', size: 18),
          ),
          for (final channel in channels)
            CNPopupMenuItem(
              label: channel.label,
              icon: CNSymbol(
                presentationFactory
                    .resolve(channel)
                    .sfSymbolName(selected: channel.id == selectedValue),
                size: 18,
              ),
            ),
        ],
        onSelected: (index) => onSelected(values[index]),
      ),
    );
  }
}
