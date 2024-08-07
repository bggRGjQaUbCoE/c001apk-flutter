import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../pages/home/app/controller.dart';
import '../../../pages/home/return_top_controller.dart';
import '../../../providers/app_config_provider.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key});

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  final ScrollController _scrollController = ScrollController();
  final AppListController _appListController = Get.put(AppListController());
  final ReturnTopController _returnTopController =
      Get.find<ReturnTopController>(tag: 'home');
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late final _config = Provider.of<AppConfigProvider>(context, listen: false);
  late bool _showFab = _config.checkUpdate;

  @override
  void initState() {
    super.initState();

    _returnTopController.index.listen((index) {
      if (index == 1) {
        _animateToTop();
      }
    });

    _scrollController.addListener(() {
      setState(() => _showFab =
          _scrollController.position.userScrollDirection ==
              ScrollDirection.forward);
    });
  }

  void _animateToTop() async {
    await _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    _returnTopController.setIndex(999);
    _refreshKey.currentState?.show();
  }

  @override
  void dispose() {
    _scrollController.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _appListController.obx(
      (data) => RefreshIndicator(
        key: _refreshKey,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        onRefresh: () async {
          await _appListController.onReload(true);
        },
        child: Scaffold(
          floatingActionButton: _config.checkUpdate
              ? AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: _showFab ? Offset.zero : const Offset(0, 2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showFab ? 1 : 0,
                    child: FloatingActionButton(
                      onPressed: () => Get.toNamed('/appUpdate'),
                      tooltip: 'Update',
                      child: const Icon(Icons.update),
                    ),
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
