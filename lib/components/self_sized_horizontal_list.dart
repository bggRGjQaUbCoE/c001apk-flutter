import 'package:flutter/material.dart';

/// https://stackoverflow.com/a/76605401

class SelfSizedHorizontalList extends StatefulWidget {
  final Widget Function(int) childBuilder;
  final int itemCount;
  final double gapSize;
  final EdgeInsetsGeometry? padding;
  const SelfSizedHorizontalList({
    super.key,
    required this.childBuilder,
    required this.itemCount,
    required this.gapSize,
    required this.padding,
  });

  @override
  State<SelfSizedHorizontalList> createState() =>
      _SelfSizedHorizontalListState();
}

class _SelfSizedHorizontalListState extends State<SelfSizedHorizontalList> {
  final infoKey = GlobalKey();

  double? prevHeight;
  double? get height {
    if (prevHeight != null) return prevHeight;
    prevHeight = infoKey.globalPaintBounds?.height;
    return prevHeight;
  }

  bool get isInit => height == null;

  @override
  Widget build(BuildContext context) {
    if (height == null) {
      WidgetsBinding.instance.addPostFrameCallback((v) => setState(() {}));
    }
    if (widget.itemCount == 0) return const SizedBox();
    if (isInit) return Container(key: infoKey, child: widget.childBuilder(0));

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: widget.padding,
        scrollDirection: Axis.horizontal,
        itemCount: widget.itemCount,
        itemBuilder: (c, i) => widget.childBuilder.call(i),
        separatorBuilder: (c, i) => SizedBox(width: widget.gapSize),
      ),
    );
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
