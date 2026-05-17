import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:moj_wss_notification/features/notifications/presentation/cubit/notification_state.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/liquid_glass_panel.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_channel_menu.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_compose_fields.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_send_button.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationComposePanel extends StatelessWidget {
  const NotificationComposePanel({
    super.key,
    required this.state,
    required this.recipientController,
    required this.messageController,
    required this.onCancel,
  });

  final NotificationState state;
  final TextEditingController recipientController;
  final TextEditingController messageController;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LiquidGlassPanel(
      borderRadius: 28.r,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          14.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.newNotificationTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('cancel-compose-button'),
                tooltip: context.l10n.cancelTooltip,
                onPressed: state.isSubmitting ? null : onCancel,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          14.verticalSpace,
          NotificationComposeChannelMenu(state: state),
          12.verticalSpace,
          NotificationComposeFields(
            state: state,
            recipientController: recipientController,
            messageController: messageController,
          ),
          if (state.generalError != null) ...[
            10.verticalSpace,
            Text(
              state.generalError!,
              style: TextStyle(color: colorScheme.error),
            ),
          ],
          14.verticalSpace,
          NotificationSendButton(
            isSubmitting: state.isSubmitting,
            onPressed: () => context.read<NotificationCubit>().onSend(
              recipient: recipientController.text,
              message: messageController.text,
            ),
          ),
        ],
      ),
    );
  }
}
