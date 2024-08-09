import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/common_body.dart';
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

  late final _homeFeedController = Get.put(
    HomeFeedNewController(
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
    ),
    tag: widget.tabType.name,
  );

  @override
  void dispose() {
    _homeFeedController.scrollController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _homeFeedController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _homeFeedController.scrollController = ScrollController();
    _homeFeedController.returnTopController =
        Get.find<ReturnTopController>(tag: 'home');

    _homeFeedController.returnTopController?.index.listen((index) {
      if (index == TabType.values.indexOf(widget.tabType)) {
        _homeFeedController.animateToTop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_homeFeedController);
  }
}
