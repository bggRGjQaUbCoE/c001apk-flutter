import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// https://gist.github.com/aarajput/d4fb5b0651d1a0d3f383596fb267ffde

class SliverStickyHeader extends RenderObjectWidget {
  final Widget child;

  const SliverStickyHeader({
    super.key,
    required this.child,
  });

  @override
  _RenderSliverStickyHeader createRenderObject(
    final BuildContext context,
  ) {
    return _RenderSliverStickyHeader();
  }

  @override
  _SliverStickyHeaderElement createElement() =>
      _SliverStickyHeaderElement(this);
}

class _SliverStickyHeaderElement extends RenderObjectElement {
  _SliverStickyHeaderElement(
    super.widget,
  );

  @override
  _RenderSliverStickyHeader get renderObject =>
      super.renderObject as _RenderSliverStickyHeader;

  @override
  void mount(final Element? parent, final Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject._element = this;
  }

  @override
  void unmount() {
    renderObject._element = null;
    super.unmount();
  }

  @override
  void update(final SliverStickyHeader newWidget) {
    final oldWidget = widget as SliverStickyHeader;
    super.update(newWidget);
    final newChild = newWidget.child;
    final oldChild = oldWidget.child;
    if (newChild != oldChild &&
        (newChild.runtimeType != oldChild.runtimeType)) {
      renderObject.triggerRebuild();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.triggerRebuild();
  }

  Element? child;

  void _build() {
    owner!.buildScope(this, () {
      final headerWidget = widget as SliverStickyHeader;
      child = updateChild(
        child,
        headerWidget.child,
        null,
      );
    });
  }

  @override
  void forgetChild(final Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(
    covariant final RenderBox child,
    final Object? slot,
  ) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(
    covariant final RenderObject child,
    final Object? oldSlot,
    final Object? newSlot,
  ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(
    covariant final RenderObject child,
    final Object? slot,
  ) {
    renderObject.child = null;
  }

  @override
  void visitChildren(final ElementVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }
}

// --------------------- renderer --------------------------- //

Rect? _trim(
  final Rect? original, {
  final double top = -double.infinity,
  final double right = double.infinity,
  final double bottom = double.infinity,
  final double left = -double.infinity,
}) =>
    original?.intersect(Rect.fromLTRB(left, top, right, bottom));

class _RenderSliverStickyHeader extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox>, RenderSliverHelpers {
  double? _lastActualScrollOffset;
  double? _effectiveScrollOffset;

  ScrollDirection? _lastStartedScrollDirection;

  double? _childPosition;

  _SliverStickyHeaderElement? _element;

  _RenderSliverStickyHeader({
    final RenderBox? child,
  }) {
    this.child = child;
  }

  @protected
  double get childExtent {
    if (child == null) {
      return 0.0;
    }
    assert(child!.hasSize);
    switch (constraints.axis) {
      case Axis.vertical:
        return child!.size.height;
      case Axis.horizontal:
        return child!.size.width;
    }
  }

  bool _needsUpdateChild = true;

  @override
  void markNeedsLayout() {
    _needsUpdateChild = true;
    super.markNeedsLayout();
  }

  @protected
  void layoutChild(
    final double scrollOffset,
    final double maxExtent, {
    final bool overlapsContent = false,
  }) {
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    if (_needsUpdateChild) {
      invokeLayoutCallback<SliverConstraints>(
          (final SliverConstraints constraints) {
        assert(constraints == this.constraints);
        updateChild(shrinkOffset, overlapsContent);
      });
      _needsUpdateChild = false;
    }
    child?.layout(
      constraints.asBoxConstraints(),
      parentUsesSize: true,
    );
  }

  @override
  bool hitTestChildren(
    final SliverHitTestResult result, {
    required final double mainAxisPosition,
    required final double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null) {
      return hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child!,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }

  @override
  void applyPaintTransform(final RenderObject child, final Matrix4 transform) {
    assert(child == this.child);
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  void paint(final PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection,
        constraints.growthDirection,
      )) {
        case AxisDirection.up:
          offset += Offset(
            0.0,
            geometry!.paintExtent - childMainAxisPosition(child!) - childExtent,
          );
          break;
        case AxisDirection.down:
          offset += Offset(0.0, childMainAxisPosition(child!));
          break;
        case AxisDirection.left:
          offset += Offset(
            geometry!.paintExtent - childMainAxisPosition(child!) - childExtent,
            0.0,
          );
          break;
        case AxisDirection.right:
          offset += Offset(childMainAxisPosition(child!), 0.0);
          break;
      }
      context.paintChild(child!, offset);
    }
  }

  @override
  void describeSemanticsConfiguration(final SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.addTagForChildren(RenderViewport.excludeFromScrolling);
  }

  // pinned floating

  @protected
  double updateGeometry() {
    final double minExtent = childExtent;
    final double minAllowedExtent = constraints.remainingPaintExtent > minExtent
        ? minExtent
        : constraints.remainingPaintExtent;
    final double maxExtent = childExtent;
    final double paintExtent = maxExtent - _effectiveScrollOffset!;
    final double clampedPaintExtent = clampDouble(
      paintExtent,
      minAllowedExtent,
      constraints.remainingPaintExtent,
    );
    final double layoutExtent = maxExtent - constraints.scrollOffset;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: math.min(constraints.overlap, 0.0),
      paintExtent: clampedPaintExtent,
      layoutExtent: clampDouble(layoutExtent, 0.0, clampedPaintExtent),
      maxPaintExtent: maxExtent,
      maxScrollObstructionExtent: minExtent,
      hasVisualOverflow: true,
    );
    return 0.0;
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double maxExtent = childExtent;
    if (_lastActualScrollOffset != null &&
        ((constraints.scrollOffset < _lastActualScrollOffset!) ||
            (_effectiveScrollOffset! < maxExtent))) {
      double delta = _lastActualScrollOffset! - constraints.scrollOffset;

      final bool allowFloatingExpansion =
          constraints.userScrollDirection == ScrollDirection.forward ||
              (_lastStartedScrollDirection != null &&
                  _lastStartedScrollDirection == ScrollDirection.forward);
      if (allowFloatingExpansion) {
        if (_effectiveScrollOffset! > maxExtent) {
          _effectiveScrollOffset = maxExtent;
        }
      } else {
        if (delta > 0.0) {
          delta = 0.0;
        }
      }
      _effectiveScrollOffset = clampDouble(
        _effectiveScrollOffset! - delta,
        0.0,
        constraints.scrollOffset,
      );
    } else {
      _effectiveScrollOffset = constraints.scrollOffset;
    }
    final bool overlapsContent =
        _effectiveScrollOffset! < constraints.scrollOffset;

    layoutChild(
      _effectiveScrollOffset!,
      maxExtent,
      overlapsContent: overlapsContent,
    );
    _childPosition = updateGeometry();
    _lastActualScrollOffset = constraints.scrollOffset;
  }

  @override
  void showOnScreen({
    final RenderObject? descendant,
    final Rect? rect,
    final Duration duration = Duration.zero,
    final Curve curve = Curves.ease,
  }) {
    assert(child != null || descendant == null);

    final Rect? childBounds = descendant != null
        ? MatrixUtils.transformRect(
            descendant.getTransformTo(child),
            rect ?? descendant.paintBounds,
          )
        : rect;

    double targetExtent;
    Rect? targetRect;
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.up:
        targetExtent = childExtent - (childBounds?.top ?? 0);
        targetRect = _trim(childBounds, bottom: childExtent);
        break;
      case AxisDirection.right:
        targetExtent = childBounds?.right ?? childExtent;
        targetRect = _trim(childBounds, left: 0);
        break;
      case AxisDirection.down:
        targetExtent = childBounds?.bottom ?? childExtent;
        targetRect = _trim(childBounds, top: 0);
        break;
      case AxisDirection.left:
        targetExtent = childExtent - (childBounds?.left ?? 0);
        targetRect = _trim(childBounds, right: childExtent);
        break;
    }

    final double effectiveMaxExtent = math.max(childExtent, childExtent);

    targetExtent = clampDouble(
      clampDouble(
        targetExtent,
        double.negativeInfinity,
        double.infinity,
      ),
      childExtent,
      effectiveMaxExtent,
    );

    super.showOnScreen(
      descendant: descendant == null ? this : child,
      rect: targetRect,
      duration: duration,
      curve: curve,
    );
  }

  @override
  double childMainAxisPosition(final RenderBox child) {
    assert(child == this.child);
    return _childPosition ?? 0.0;
  }

  void updateChild(final double shrinkOffset, final bool overlapsContent) {
    assert(_element != null);
    _element!._build();
  }

  @protected
  void triggerRebuild() {
    markNeedsLayout();
  }
}
