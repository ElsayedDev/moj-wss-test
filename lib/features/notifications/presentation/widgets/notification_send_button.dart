import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moj_wss_notification/l10n/app_localizations_extension.dart';

class NotificationSendButton extends StatelessWidget {
  const NotificationSendButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('send-button'),
        onPressed: isSubmitting ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: isSubmitting
              ? Row(
                  key: const ValueKey('send-button-loading'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 16.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    10.horizontalSpace,
                    Text(context.l10n.sendingButtonLabel),
                  ],
                )
              : Text(
                  context.l10n.sendButtonLabel,
                  key: const ValueKey('send-button-idle'),
                ),
        ),
      ),
    );
  }
}
