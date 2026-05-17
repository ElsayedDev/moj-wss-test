import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
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
        CNPopupMenuButton.icon(
          key: const ValueKey('compose-channel-menu'),
          buttonStyle: CNButtonStyle.glass,
          tint: colorScheme.primary,
          buttonIcon: CNSymbol('chevron.down', size: 12),
          items: [
            for (final channel in state.channels)
              CNPopupMenuItem(
                label: channel.label,
                icon: CNSymbol(
                  presentationFactory
                      .resolve(channel)
                      .sfSymbolName(selected: channel.id == selectedChannel.id),
                  size: 18,
                ),
                enabled: !state.isSubmitting,
              ),
          ],
          onSelected: (index) {
            if (state.isSubmitting) {
              return;
            }

            context.read<NotificationCubit>().onSelectChannel(
              state.channels[index].id,
            );
          },
        ),
      ],
    );
  }
}
