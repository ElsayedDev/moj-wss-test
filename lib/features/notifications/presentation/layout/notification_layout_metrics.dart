import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationLayoutMetrics {
  const NotificationLayoutMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.transcriptHorizontalPadding,
    required this.transcriptTopPadding,
    required this.transcriptBottomPadding,
    required this.transcriptMaxWidth,
    required this.composeSideInset,
    required this.composeBottomInset,
    required this.composeWidth,
  });

  factory NotificationLayoutMetrics.fromConstraints(
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortestSide = math.min(width, height);
    final isTablet = shortestSide >= 600;
    final isLandscape = width > height;
    final transcriptHorizontalPadding = isTablet
        ? _scaledWidth(28, max: 36)
        : _scaledWidth(12, max: 16);
    final composeSideInset = isTablet
        ? _scaledWidth(28, max: 48)
        : _scaledWidth(12, max: 16);
    final composeMaxWidth = isTablet
        ? (isLandscape ? 720.0 : 680.0)
        : double.infinity;
    final usableComposeWidth = math.max(0.0, width - (composeSideInset * 2));

    return NotificationLayoutMetrics(
      isTablet: isTablet,
      isLandscape: isLandscape,
      transcriptHorizontalPadding: transcriptHorizontalPadding,
      transcriptTopPadding: isTablet
          ? _scaledHeight(24, max: 32)
          : _scaledHeight(12, max: 16),
      transcriptBottomPadding: isTablet
          ? _scaledHeight(18, max: 24)
          : _scaledHeight(12, max: 16),
      transcriptMaxWidth: isTablet
          ? (isLandscape ? 920.0 : 760.0)
          : double.infinity,
      composeSideInset: composeSideInset,
      composeBottomInset: isTablet
          ? _scaledHeight(22, max: 28)
          : _scaledHeight(16, max: 20),
      composeWidth: math.min(usableComposeWidth, composeMaxWidth),
    );
  }

  final bool isTablet;
  final bool isLandscape;
  final double transcriptHorizontalPadding;
  final double transcriptTopPadding;
  final double transcriptBottomPadding;
  final double transcriptMaxWidth;
  final double composeSideInset;
  final double composeBottomInset;
  final double composeWidth;

  static double _scaledWidth(double value, {required double max}) {
    return math.min(value.w, max);
  }

  static double _scaledHeight(double value, {required double max}) {
    return math.min(value.h, max);
  }
}
