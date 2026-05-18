import 'package:flutter/material.dart';

typedef NotificationMaterialMenuAnchorBuilder =
    Widget Function(BuildContext context, MenuController controller);

class NotificationMaterialMenuOption<T> {
  const NotificationMaterialMenuOption({
    required this.value,
    required this.label,
    required this.icon,
    this.selected = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
}

class NotificationMaterialMenu<T> extends StatelessWidget {
  const NotificationMaterialMenu({
    super.key,
    required this.options,
    required this.onSelected,
    required this.anchorBuilder,
    this.minWidth = 176,
    this.maxWidth = 320,
  });

  final List<NotificationMaterialMenuOption<T>> options;
  final ValueChanged<T> onSelected;
  final NotificationMaterialMenuAnchorBuilder anchorBuilder;
  final double minWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      consumeOutsideTap: true,
      useRootOverlay: true,
      style: MenuStyle(
        alignment: AlignmentDirectional.topEnd,
        minimumSize: WidgetStatePropertyAll<Size?>(Size(minWidth, 0)),
        maximumSize: WidgetStatePropertyAll<Size?>(
          Size(maxWidth, double.infinity),
        ),
      ),
      menuChildren: [
        for (final option in options)
          _NotificationMaterialMenuItem<T>(
            option: option,
            onSelected: onSelected,
          ),
      ],
      builder: (context, controller, child) {
        return anchorBuilder(context, controller);
      },
    );
  }
}

class _NotificationMaterialMenuItem<T> extends StatelessWidget {
  const _NotificationMaterialMenuItem({
    required this.option,
    required this.onSelected,
  });

  final NotificationMaterialMenuOption<T> option;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = option.enabled;
    final foregroundColor = option.selected
        ? colorScheme.primary
        : colorScheme.onSurface;
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    return MenuItemButton(
      leadingIcon: Icon(option.icon, size: 20),
      trailingIcon: option.selected
          ? const Icon(Icons.check_rounded, size: 18)
          : const SizedBox(width: 18, height: 18),
      onPressed: enabled ? () => onSelected(option.value) : null,
      style: MenuItemButton.styleFrom(
        foregroundColor: foregroundColor,
        iconColor: foregroundColor,
        disabledForegroundColor: disabledColor,
        disabledIconColor: disabledColor,
        minimumSize: const Size(176, 48),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        textStyle: textTheme.bodyLarge,
      ),
      child: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
