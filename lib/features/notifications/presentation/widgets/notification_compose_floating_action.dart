import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    if (Theme.of(context).platform == TargetPlatform.android) {
      return FloatingActionButton(
        key: buttonKey,
        tooltip: tooltip,
        heroTag: 'compose-notification',
        onPressed: onPressed,
        child: const Icon(Icons.edit_rounded),
      );
    }

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        child: CNButton.icon(
          key: buttonKey,
          icon: const CNSymbol('square.and.pencil', size: 20),
          tint: colorScheme.primary,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
