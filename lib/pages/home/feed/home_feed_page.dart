import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/common_body.dart';
import '../../../pages/home/feed/home_feed_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;
import '../../../pages/home/return_top_controller.dart';
import '../../../providers/app_config_provider.dart';
import '../../feed/reply/reply_dialog.dart';

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
  late bool _showFab = _config.isLogin;

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
    _homeFeedController.scrollController?.removeListener(() {});
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

    _homeFeedController.scrollController?.addListener(() {
      setState(() => _showFab =
          _homeFeedController.scrollController?.position.userScrollDirection ==
              ScrollDirection.forward);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: _config.isLogin && widget.tabType == TabType.FEED
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showFab ? Offset.zero : const Offset(0, 2),
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet<dynamic>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const ReplyDialog(),
                  );
                },
                tooltip: 'Create Feed',
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: commonBody(_homeFeedController),
    );
  }
}
