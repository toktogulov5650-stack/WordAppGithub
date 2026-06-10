import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) => screenWidth(context) < 370;

  static double horizontalPadding(
    BuildContext context, {
    double compact = 20,
    double regular = 24,
    double wide = 28,
  }) {
    final width = screenWidth(context);
    if (width < 370) {
      return compact;
    }
    if (width >= 430) {
      return wide;
    }
    return regular;
  }

  static double value(
    BuildContext context,
    double base, {
    double minScale = 0.88,
    double maxScale = 1.08,
  }) {
    final scale = (screenWidth(context) / 390)
        .clamp(minScale, maxScale)
        .toDouble();
    return base * scale;
  }

  static double font(
    BuildContext context,
    double base, {
    double minScale = 0.90,
    double maxScale = 1.04,
  }) {
    return value(
      context,
      base,
      minScale: minScale,
      maxScale: maxScale,
    );
  }

  static double verticalGap(
    BuildContext context,
    double base, {
    double minScale = 0.78,
    double maxScale = 1.08,
  }) {
    final heightScale = (screenHeight(context) / 844)
        .clamp(minScale, maxScale)
        .toDouble();
    return base * heightScale;
  }
}
