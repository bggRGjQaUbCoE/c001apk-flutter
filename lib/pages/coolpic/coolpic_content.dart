import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../pages/coolpic/coolpic_controller.dart';
import '../../pages/home/return_top_controller.dart';

class CoolpicContent extends StatefulWidget {
  const CoolpicContent({
    super.key,
    required this.type,
    required this.title,
  });

  final String type;
  final String title;

  @override
  State<CoolpicContent> createState() => _CoolpicContentState();
}

class _CoolpicContentState extends State<CoolpicContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _coolpicController = Get.put(
    CoolpicController(type: widget.type, title: widget.title),
    tag: widget.type + widget.title,
  );

  @override
  void initState() {
    super.initState();

    _coolpicController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _coolpicController.scrollController = ScrollController();
    _coolpicController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.title);

    _coolpicController.returnTopController?.index.listen((index) {
      if ((index == 0 && widget.type == 'recommend') ||
          (index == 1 && widget.type == 'hot') ||
          (index == 2 && widget.type == 'newest')) {
        _coolpicController.animateToTop();
      }
    });
  }

  @override
  void dispose() {
    _coolpicController.scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_coolpicController);
  }
}
