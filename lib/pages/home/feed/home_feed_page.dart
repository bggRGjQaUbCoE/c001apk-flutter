import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/common_body.dart';
import '../../../components/nested_tab_bar_view.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/home/feed/home_feed_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;
import '../../../pages/home/return_top_controller.dart';
import '../../../providers/app_config_provider.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({
    super.key,
    required this.tabType,
  });

  final TabType tabType;

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _config = Provider.of<AppConfigProvider>(context, listen: false);

  late final _homeFeedController = HomeFeedNewController(
    tabType: widget.tabType,
    installTime: _config.installTime,
    url: switch (widget.tabType) {
      TabType.FOLLOW => '/page?url=V9_HOME_TAB_FOLLOW',
      TabType.HOT => '/page?url=V9_HOME_TAB_RANKING',
      TabType.COOLPIC => '/page?url=V11_FIND_COOLPIC',
      _ => null,
    },
    title: switch (widget.tabType) {
      TabType.FOLLOW => '全部关注',
      TabType.HOT => '热榜',
      TabType.COOLPIC => '酷图',
      _ => null,
    },
  );

  @override
  void initState() {
    super.initState();

    _homeFeedController.scrollController = NestedInnerScrollController();
    _homeFeedController.returnTopController =
        Get.find<ReturnTopController>(tag: 'home');

    _homeFeedController.returnTopController?.index.listen((index) {
      if (index == TabType.values.indexOf(widget.tabType)) {
        _homeFeedController.animateToTop();
      }
    });

    _onGetData();
  }

  @override
  void dispose() {
    _homeFeedController.scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _homeFeedController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _homeFeedController.loadingState = responseState;
        } else if (responseState is Success &&
            _homeFeedController.loadingState is Success) {
          _homeFeedController.loadingState = LoadingState.success(
              (_homeFeedController.loadingState as Success).response +
                  responseState.response);
        } else {
          _homeFeedController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _homeFeedController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _homeFeedController.loadingState = state),
      (state) => setState(() => _homeFeedController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _homeFeedController.loadingState is Success
        ? RefreshIndicator(
            key: _homeFeedController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _homeFeedController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
