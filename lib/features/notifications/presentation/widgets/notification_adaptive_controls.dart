import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:moj_wss_notification/features/notifications/presentation/widgets/notification_material_menu.dart';

class NotificationAdaptiveMenuOption<T> {
  const NotificationAdaptiveMenuOption({
    required this.value,
    required this.label,
    required this.materialIcon,
    required this.cupertinoSymbol,
    this.selected = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData materialIcon;
  final String cupertinoSymbol;
  final bool selected;
  final bool enabled;
}

class NotificationAdaptiveMenuTrigger {
  const NotificationAdaptiveMenuTrigger({
    required this.key,
    required this.tooltip,
    required this.materialIcon,
    required this.cupertinoSymbol,
    this.cupertinoSymbolSize = 20,
  });

  final Key key;
  final String tooltip;
  final IconData materialIcon;
  final String cupertinoSymbol;
  final double cupertinoSymbolSize;
}

abstract interface class NotificationAdaptiveControls {
  static NotificationAdaptiveControls resolve(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android
        ? const MaterialNotificationAdaptiveControls()
        : const CupertinoNotificationAdaptiveControls();
  }

  Widget menu<T>({
    required BuildContext context,
    required NotificationAdaptiveMenuTrigger trigger,
    required List<NotificationAdaptiveMenuOption<T>> options,
    required ValueChanged<T> onSelected,
  });

  Widget floatingAction({
    required BuildContext context,
    required Key buttonKey,
    required String tooltip,
    required VoidCallback onPressed,
  });
}

class MaterialNotificationAdaptiveControls
    implements NotificationAdaptiveControls {
  const MaterialNotificationAdaptiveControls();

  @override
  Widget menu<T>({
    required BuildContext context,
    required NotificationAdaptiveMenuTrigger trigger,
    required List<NotificationAdaptiveMenuOption<T>> options,
    required ValueChanged<T> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: trigger.tooltip,
      button: true,
      child: NotificationMaterialMenu<T>(
        options: [
          for (final option in options)
            NotificationMaterialMenuOption<T>(
              value: option.value,
              label: option.label,
              icon: option.materialIcon,
              selected: option.selected,
              enabled: option.enabled,
            ),
        ],
        onSelected: onSelected,
        anchorBuilder: (context, controller) {
          return IconButton(
            key: trigger.key,
            tooltip: trigger.tooltip,
            color: colorScheme.primary,
            onPressed: () {
              controller.isOpen ? controller.close() : controller.open();
            },
            icon: Icon(trigger.materialIcon),
          );
        },
      ),
    );
  }

  @override
  Widget floatingAction({
    required BuildContext context,
    required Key buttonKey,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      key: buttonKey,
      tooltip: tooltip,
      heroTag: 'compose-notification',
      onPressed: onPressed,
      child: const Icon(Icons.edit_rounded),
    );
  }
}

class CupertinoNotificationAdaptiveControls
    implements NotificationAdaptiveControls {
  const CupertinoNotificationAdaptiveControls();

  @override
  Widget menu<T>({
    required BuildContext context,
    required NotificationAdaptiveMenuTrigger trigger,
    required List<NotificationAdaptiveMenuOption<T>> options,
    required ValueChanged<T> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: trigger.tooltip,
      button: true,
      child: CNPopupMenuButton.icon(
        key: trigger.key,
        buttonIcon: CNSymbol(
          trigger.cupertinoSymbol,
          size: trigger.cupertinoSymbolSize,
        ),
        buttonStyle: CNButtonStyle.glass,
        tint: colorScheme.primary,
        items: [
          for (final option in options)
            CNPopupMenuItem(
              label: option.label,
              icon: CNSymbol(option.cupertinoSymbol, size: 18),
              enabled: option.enabled,
            ),
        ],
        onSelected: (index) => onSelected(options[index].value),
      ),
    );
  }

  @override
  Widget floatingAction({
    required BuildContext context,
    required Key buttonKey,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

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
