import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../components/nested_tab_bar_view.dart';
import '../../pages/app/app_content_controller.dart';
import '../../pages/app/app_page.dart' show AppType;
import '../../pages/home/return_top_controller.dart';

class AppContent extends StatefulWidget {
  const AppContent({
    super.key,
    required this.random,
    required this.packageName,
    required this.appType,
    required this.id,
  });

  final String random;
  final String packageName;
  final AppType appType;
  final String id;

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _url = '/page?url=/feed/apkCommentList?id=';
  late final String _title;

  late final _appController = Get.put(
    AppContentController(
      appType: widget.appType,
      packageName: widget.packageName,
      url: _url,
      title: _title,
    ),
    tag: widget.id + widget.appType.name + widget.random,
  );

  @override
  void initState() {
    super.initState();

    switch (widget.appType) {
      case AppType.reply:
        _url = '$_url${widget.id}';
        _title = '最近回复';
        break;
      case AppType.dateline:
        _url = '$_url${widget.id}&sort=dateline_desc';
        _title = '最新发布';
        break;
      case AppType.hot:
        _url = '$_url${widget.id}&sort=popular';
        _title = '热度排序';
        break;
    }
    _appController.scrollController = NestedInnerScrollController();
    _appController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _appController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.packageName + widget.random);
    _appController.returnTopController?.index.listen((index) {
      if (index == AppType.values.indexOf(widget.appType)) {
        _appController.animateToTop();
      }
    });
  }

  @override
  void dispose() {
    _appController.scrollController?.dispose();
    Get.delete<AppContentController>(
      tag: widget.id + widget.appType.name + widget.random,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_appController);
  }
}
