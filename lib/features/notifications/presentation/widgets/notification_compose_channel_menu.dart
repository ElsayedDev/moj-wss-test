import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_adaptive_controls.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationComposeChannelMenu extends StatelessWidget {
  const NotificationComposeChannelMenu({super.key, required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedChannel = state.selectedChannel;
    final presentationFactory = context
        .read<NotificationChannelPresentationFactory>();
    final controls = NotificationAdaptiveControls.resolve(context);
    final selectedPresentation = presentationFactory.resolve(selectedChannel);

    final selectedChannelLabel = context.l10n.channelLabel(
      channel: selectedPresentation.label,
    );
    return Row(
      children: [
        Icon(
          selectedPresentation.materialIcon(selected: true),
          size: 20.r,
          color: colorScheme.primary,
        ),
        10.horizontalSpace,
        Expanded(
          child: Text(
            selectedChannelLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        controls.menu<String>(
          context: context,
          trigger: NotificationAdaptiveMenuTrigger(
            key: const ValueKey('compose-channel-menu'),
            tooltip: selectedChannelLabel,
            materialIcon: Icons.keyboard_arrow_down_rounded,
            cupertinoSymbol: 'chevron.down',
            cupertinoSymbolSize: 12,
          ),
          options: [
            for (final channel in state.channels)
              NotificationAdaptiveMenuOption<String>(
                value: channel.id,
                label: channel.label,
                materialIcon: presentationFactory
                    .resolve(channel)
                    .materialIcon(selected: channel.id == selectedChannel.id),
                cupertinoSymbol: presentationFactory
                    .resolve(channel)
                    .sfSymbolName(selected: channel.id == selectedChannel.id),
                selected: channel.id == selectedChannel.id,
                enabled: !state.isSubmitting,
              ),
          ],
          onSelected: (channelId) {
            if (state.isSubmitting) {
              return;
            }

            context.read<NotificationCubit>().onSelectChannel(channelId);
          },
        ),
      ],
    );
  }
}
