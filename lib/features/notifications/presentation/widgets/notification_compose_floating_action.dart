import 'package:flutter/material.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_adaptive_controls.dart';

class NotificationComposeFloatingAction extends StatelessWidget {
  const NotificationComposeFloatingAction({
    super.key,
    required this.buttonKey,
    required this.tooltip,
    required this.onPressed,
  });

  final Key buttonKey;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return NotificationAdaptiveControls.resolve(context).floatingAction(
      context: context,
      buttonKey: buttonKey,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
