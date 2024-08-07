import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StickySliverToBoxAdapter extends SingleChildRenderObjectWidget {
  const StickySliverToBoxAdapter({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _StickyRenderSliverToBoxAdapter();
}

class _StickyRenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  //查找前一个吸顶的section
  RenderSliver? _prev() {
    if (parent is RenderViewportBase) {
      RenderSliver? current = this;
      while (current != null) {
        current = (parent as RenderViewportBase).childBefore(current);
        if (current is _StickyRenderSliverToBoxAdapter &&
            current.geometry != null) {
          return current;
        }
      }
    }
    return null;
  }

  // 必须重写，否则点击事件失效。
  @override
  double childMainAxisPosition(covariant RenderBox child) => 0.0;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    //摆放子View，并把constraints传递给子View
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    //获取子View在滑动主轴方向的尺寸
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
      case Axis.vertical:
        childExtent = child!.size.height;
    }

    final double minExtent = childExtent;
    final double minAllowedExtent = constraints.remainingPaintExtent > minExtent
        ? minExtent
        : constraints.remainingPaintExtent;
    final double maxExtent = childExtent;
    final double paintExtent = maxExtent;
    final double clampedPaintExtent = clampDouble(
      paintExtent,
      minAllowedExtent,
      constraints.remainingPaintExtent,
    );
    final double layoutExtent = maxExtent - constraints.scrollOffset;

    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: min(constraints.overlap, 0.0),
      paintExtent: clampedPaintExtent,
      layoutExtent: clampDouble(layoutExtent, 0.0, clampedPaintExtent),
      maxPaintExtent: maxExtent,
      maxScrollObstructionExtent: minExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );

    //上推关键代码: 当前吸顶的Sliver被覆盖了多少，前一个吸顶的Sliver就移动多少
    RenderSliver? prev = _prev();
    if (prev != null && constraints.overlap > 0) {
      setChildParentData(
          _prev()!,
          constraints.copyWith(scrollOffset: constraints.overlap),
          _prev()!.geometry!);
    }
  }
}
