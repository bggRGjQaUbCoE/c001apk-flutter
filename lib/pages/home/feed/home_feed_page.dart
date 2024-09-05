import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';

import '../../../components/common_body.dart';
import '../../../pages/home/feed/home_feed_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;
import '../../../pages/home/return_top_controller.dart';
import '../../../utils/global_data.dart';
import '../../../utils/storage_util.dart';
import '../../../utils/utils.dart';
import '../../feed/reply/reply_page.dart';

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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late final bool isLogin = GlobalData().isLogin;
  AnimationController? _fabAnimationCtr;
  late bool _isFabVisible = true;

  late final followType = GStorage.followType;

  late final _homeFeedController = Get.put(
    HomeFeedController(
      tabType: widget.tabType,
      installTime: GStorage.installTime,
      url: switch (widget.tabType) {
        TabType.FOLLOW => Utils.getFollowUrl(followType),
        TabType.HOT => '/page?url=V9_HOME_TAB_RANKING',
        TabType.COOLPIC => '/page?url=V11_FIND_COOLPIC',
        _ => null,
      },
      title: switch (widget.tabType) {
        TabType.FOLLOW => Utils.getFollowTitle(followType),
        TabType.HOT => '热榜',
        TabType.COOLPIC => '酷图',
        _ => null,
      },
      followType: widget.tabType == TabType.FOLLOW ? GStorage.followType : null,
    ),
    tag: widget.tabType.name,
  );

  @override
  void dispose() {
    _homeFeedController.scrollController?.removeListener(() {});
    _homeFeedController.scrollController?.dispose();
    _fabAnimationCtr?.dispose();
    Get.delete<HomeFeedController>(
      tag: widget.tabType.name,
    );
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

    if (isLogin) {
      _fabAnimationCtr = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300));
      _fabAnimationCtr?.forward();
      _homeFeedController.scrollController?.addListener(() {
        final ScrollDirection? direction =
            _homeFeedController.scrollController?.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          _showFab();
        } else if (direction == ScrollDirection.reverse) {
          _hideFab();
        }
      });
    }
  }

  void _showFab() {
    if (!_isFabVisible) {
      _isFabVisible = true;
      _fabAnimationCtr?.forward();
    }
  }

  void _hideFab() {
    if (_isFabVisible) {
      _isFabVisible = false;
      _fabAnimationCtr?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton:
          GlobalData().isLogin && widget.tabType == TabType.FEED
              ? SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 2),
                    end: const Offset(0, 0),
                  ).animate(CurvedAnimation(
                    parent: _fabAnimationCtr!,
                    curve: Curves.easeInOut,
                  )),
                  child: FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      Navigator.of(context).push(
                        GetDialogRoute(
                          pageBuilder:
                              (buildContext, animation, secondaryAnimation) {
                            return const ReplyPage();
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.linear;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                      // showModalBottomSheet<dynamic>(
                      //   context: context,
                      //   isScrollControlled: true,
                      //   builder: (context) => const ReplyDialog(),
                      // );
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
