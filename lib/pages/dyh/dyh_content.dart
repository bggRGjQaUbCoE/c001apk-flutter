import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../pages/dyh/dyh_controller.dart';
import '../../pages/home/return_top_controller.dart';

class DyhContent extends StatefulWidget {
  const DyhContent({
    super.key,
    required this.random,
    required this.type,
    required this.id,
    required this.title,
  });

  final String random;
  final String type;
  final String id;
  final String title;

  @override
  State<DyhContent> createState() => _DyhContentState();
}

class _DyhContentState extends State<DyhContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _dyhController = Get.put(
    DyhController(type: widget.type, id: widget.id),
    tag: widget.type + widget.id + widget.random,
  );

  @override
  void initState() {
    super.initState();

    _dyhController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _dyhController.scrollController = ScrollController();
    _dyhController.returnTopController = Get.find<ReturnTopController>(
        tag: widget.id + widget.title + widget.random);

    _dyhController.returnTopController?.index.listen((index) {
      if ((index == 0 && widget.type == 'all') ||
          (index == 1 && widget.type == 'square')) {
        _dyhController.animateToTop();
      }
    });
  }

  @override
  void dispose() {
    _dyhController.scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_dyhController);
  }
}
