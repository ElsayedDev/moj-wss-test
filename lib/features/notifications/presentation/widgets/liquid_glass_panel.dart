import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:moj_wss_notification/core/theme/app_theme.dart';

class LiquidGlassPanel extends StatelessWidget {
  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final glass = Theme.of(context).extension<GlassColors>();
    final panelFill =
        glass?.panelFill ?? colorScheme.surface.withValues(alpha: 0.78);
    final panelBorder =
        glass?.panelBorder ??
        colorScheme.outlineVariant.withValues(alpha: 0.72);

    return Padding(
      padding: margin,
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 16,
          blur: 8,
          glassColor: panelFill.withValues(alpha: 0.24),
          lightIntensity: 0.42,
          saturation: 1.18,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: panelFill,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(color: panelBorder),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
