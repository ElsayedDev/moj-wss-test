import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/core/clock.dart';
import 'package:moj_wss_notification/features/notifications/domain/entities/sent_notification.dart';
import 'package:moj_wss_notification/features/notifications/presentation/channel_presentation/notification_channel_presentation.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationMessageCard extends StatelessWidget {
  const NotificationMessageCard({required this.notification, super.key});

  final SentNotification notification;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final channelPresentation = context
        .read<NotificationChannelPresentationFactory>()
        .resolveSent(notification);

    return DecoratedBox(
      key: const ValueKey('notification-card'),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.58),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: context.l10n.providerIconLabel(
                channel: notification.channelLabel,
              ),
              image: true,
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Icon(channelPresentation.icon, size: 18.r),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.w,
                    children: [
                      Expanded(
                        child: Text(
                          notification.channelLabel,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _formatTimestamp(context, notification.sentAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    context.l10n.recipientPrefix(
                      recipient: notification.recipient,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    notification.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value));
    final now = context.read<Clock>().now();
    final isToday =
        value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;

    if (isToday) {
      return time;
    }

    return '${localizations.formatShortDate(value)} $time';
  }
}
