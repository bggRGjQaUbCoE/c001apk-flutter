import 'package:flutter/material.dart';

class NoSplashFactory extends InteractiveInkFeatureFactory {
  @override
  InteractiveInkFeature create(
      {required MaterialInkController controller,
      required RenderBox referenceBox,
      required Offset position,
      required Color color,
      required TextDirection textDirection,
      bool containedInkWell = false,
      RectCallback? rectCallback,
      BorderRadius? borderRadius,
      ShapeBorder? customBorder,
      double? radius,
      VoidCallback? onRemoved}) {
    return _NoInteractiveInkFeature(
        controller: controller,
        referenceBox: referenceBox,
        color: color,
        onRemoved: onRemoved);
  }
}

class _NoInteractiveInkFeature extends InteractiveInkFeature {
  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
  _NoInteractiveInkFeature({
    required super.controller,
    required super.referenceBox,
    required super.color,
    super.onRemoved,
  });
}
