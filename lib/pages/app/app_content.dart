import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../components/nested_tab_bar_view.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/app/app_controller.dart';
import '../../pages/app/app_page.dart' show AppType;
import '../../pages/home/return_top_controller.dart';

class AppContent extends StatefulWidget {
  const AppContent({
    super.key,
    required this.packageName,
    required this.appType,
    required this.id,
  });

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

  late final _appController = AppController(url: _url, title: _title);

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

    _appController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _appController.scrollController = NestedInnerScrollController();
    _appController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.packageName);

    _appController.returnTopController?.index.listen((index) {
      if (index == AppType.values.indexOf(widget.appType)) {
        _appController.animateToTop();
      }
    });

    _onGetData();
  }

  @override
  void dispose() {
    _appController.scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _appController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _appController.loadingState = responseState;
        } else if (responseState is Success &&
            _appController.loadingState is Success) {
          _appController.loadingState = LoadingState.success(
              (_appController.loadingState as Success).response +
                  responseState.response);
        } else {
          _appController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _appController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _appController.loadingState = state),
      (state) => setState(() => _appController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _appController.loadingState is Success
        ? RefreshIndicator(
            key: _appController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _appController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
