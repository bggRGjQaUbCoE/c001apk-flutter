import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../pages/home/app/app_list_controller.dart';
import '../../../pages/home/return_top_controller.dart';
import '../../../utils/extensions.dart';
import '../../../utils/storage_util.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scrollController = ScrollController();
  final _appListController = Get.put(AppListController());
  final _returnTopController = Get.find<ReturnTopController>(tag: 'home');
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  late final bool _checkUpdate = GStorage.checkUpdate;
  AnimationController? _fabAnimationCtr;
  late bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();

    _returnTopController.index.listen((index) {
      if (index == 1 && _scrollController.hasClients) {
        _animateToTop();
      }
    });

    if (_checkUpdate) {
      _fabAnimationCtr = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300));
      _fabAnimationCtr?.forward();
      _scrollController.addListener(() {
        final ScrollDirection direction =
            _scrollController.position.userScrollDirection;
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

  void _animateToTop() async {
    _scrollController.animToTop();
    _returnTopController.setIndex(999);
    _refreshKey.currentState?.show();
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose;
    _fabAnimationCtr?.dispose();
    Get.delete<AppListController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _appListController.obx(
      (data) => RefreshIndicator(
        key: _refreshKey,
        onRefresh: () async {
          await _appListController.onReload(true);
        },
        child: Scaffold(
          floatingActionButton: _checkUpdate
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
                    onPressed: () => Get.toNamed('/appUpdate'),
                    tooltip: 'Update',
                    child: const Icon(Icons.update),
                  ),
                )
              : null,
          body: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: data!.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () => Get.toNamed('/apk/${data[index].packageName}'),
              leading: data[index].icon != null
                  ? Image.memory(
                      data[index].icon!,
                      height: 40,
                      width: 40,
                      filterQuality: FilterQuality.low,
                    )
                  : null,
              title: Text(data[index].appName),
              subtitle: Text(
                '${data[index].packageName}\n${data[index].versionName}(${data[index].versionCode})',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
        ),
      ),
      onEmpty: GestureDetector(
        onTap: _appListController.onReload,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: const Text('EMPTY'),
        ),
      ),
      onError: (error) => GestureDetector(
        onTap: _appListController.onReload,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: Text(error ?? 'unknown error'),
        ),
      ),
    );
  }
}
