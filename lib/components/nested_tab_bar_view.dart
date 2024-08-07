import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NestedTabBarView extends StatefulWidget {
  final TabController? controller;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final DragStartBehavior dragStartBehavior;
  final double viewportFraction;
  final Clip clipBehavior;

  const NestedTabBarView({
    super.key,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction = 1.0,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  State<StatefulWidget> createState() => _NestedTabBarViewState();
}

class _NestedTabBarViewState extends State<NestedTabBarView> {
  List<NestedInnerScrollController> _nestedInnerControllers = [];

  @override
  void initState() {
    super.initState();
    _initNestedInnerControllers();
    widget.controller?.addListener(_onTabChange);
  }

  @override
  void didUpdateWidget(covariant NestedTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _initNestedInnerControllers();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTabChange);
    _disposeNestedInnerControllers();
    super.dispose();
  }

  void _onTabChange() {
    int index = widget.controller!.index;
    if (index == widget.controller!.animation?.value) {
      _nestedInnerControllers[index].attachCurrent();
    }
  }

  void _initNestedInnerControllers() {
    _disposeNestedInnerControllers();
    List<NestedInnerScrollController> controllers =
        List.generate(widget.children.length, (index) {
      return NestedInnerScrollController();
    });

    if (mounted) {
      setState(() {
        _nestedInnerControllers = controllers;
      });
    } else {
      _nestedInnerControllers = controllers;
    }
  }

  void _disposeNestedInnerControllers() {
    for (var element in _nestedInnerControllers) {
      element.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: widget.controller,
        physics: widget.physics,
        dragStartBehavior: widget.dragStartBehavior,
        viewportFraction: widget.viewportFraction,
        clipBehavior: widget.clipBehavior,
        children: List<Widget>.generate(widget.children.length, (index) {
          return _InheritedInnerScrollController(
            controller: _nestedInnerControllers[index],
            child: widget.children[index],
          );
        }));
  }
}

class _InheritedInnerScrollController extends InheritedWidget {
  final ScrollController controller;

  const _InheritedInnerScrollController(
      {required super.child, required this.controller});

  @override
  bool updateShouldNotify(
          covariant _InheritedInnerScrollController oldWidget) =>
      controller != oldWidget.controller;
}

class NestedInnerScrollController extends ScrollController {
  ScrollController? _inner;

  NestedInnerScrollController();

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    ScrollPosition scrollPosition;
    ScrollableState? scrollableState = context as ScrollableState;
    if (scrollableState != null) {
      _inner = PrimaryScrollController.maybeOf(scrollableState.context);
    }
    if (_inner == null) {
      scrollPosition =
          super.createScrollPosition(physics, context, oldPosition);
    } else {
      scrollPosition =
          _inner!.createScrollPosition(physics, context, oldPosition);
    }
    return scrollPosition;
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    _inner?.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    _inner?.detach(position);
    super.detach(position);
  }

  void attachCurrent() {
    if (_inner != null) {
      while (_inner!.positions.isNotEmpty) {
        _inner!.detach(_inner!.positions.first);
      }
      _inner!.attach(position);
    }
  }

  static ScrollController of(BuildContext context) {
    final _InheritedInnerScrollController? target = context
        .dependOnInheritedWidgetOfExactType<_InheritedInnerScrollController>();
    assert(
      target != null,
      'NestedInnerScrollController.of must be called with a context that contains a NestedTabBarView\'s children.',
    );
    return target!.controller;
  }

  static ScrollController? maybeOf(BuildContext context) {
    final _InheritedInnerScrollController? target = context
        .dependOnInheritedWidgetOfExactType<_InheritedInnerScrollController>();
    return target?.controller;
  }
}
