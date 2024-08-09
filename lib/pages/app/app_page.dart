import 'dart:math';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response;
import 'package:share_plus/share_plus.dart';

import '../../components/cards/app_info_card.dart';
import '../../components/sticky_sliver_to_box_adapter.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/app/app_content.dart';
import '../../pages/app/app_controller.dart';
import '../../pages/home/return_top_controller.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum AppMenuItem { Copy, Share, Block }

enum AppType { reply, dateline, hot }

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with TickerProviderStateMixin {
  final String _packageName = Get.parameters['packageName'].orEmpty;
  String? _url;

  double _scrollRatio = 0;

  late ReturnTopController _returnTopController;

  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController =
      TabController(vsync: this, length: 3);
  final _tabs =
      ['最近回复', '最新发布', '热度排序'].map((title) => Tab(text: title)).toList();

  @override
  void initState() {
    super.initState();
    _returnTopController = Get.put(ReturnTopController(), tag: _packageName);

    _scrollController.addListener(() {
      setState(() =>
          _scrollRatio = min(1.0, _scrollController.offset.round() / 75.0));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppInfo(AppController controller) {
    switch (controller.appState.value) {
      case Empty():
        return GestureDetector(
          onTap: controller.regetData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: controller.regetData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text((controller.appState.value as Error).errMsg),
          ),
        );
      case Success():
        return AppInfoCard(
          data: (controller.appState.value as Success).response!,
          onDownloadApk: controller.entityType == 'apk'
              ? (id, versionName, versionCode) async {
                  if (!_url.isNullOrEmpty) {
                    Utils.onDownloadFile(
                      _url!,
                      '${controller.appName.value}-$versionName-$versionCode.apk',
                    );
                  } else {
                    _url = await Utils.onGetDownloadUrl(
                      controller.appName.value,
                      _packageName,
                      id,
                      versionName,
                      versionCode,
                    );
                  }
                }
              : null,
        );
    }
    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: _packageName,
      init: AppController(packageName: _packageName),
      builder: (controller) => Obx(
        () => Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            title: controller.appName.value.isNotEmpty && _scrollRatio == 1
                ? Text(controller.appName.value)
                : const SizedBox(),
            actions: controller.appState.value is Success
                ? [
                    if (controller.commentStatus == 1)
                      IconButton(
                        onPressed: () => Get.toNamed('/search', parameters: {
                          'title': controller.appName.value,
                          'pageType': 'apk',
                          'pageParam': controller.id!,
                        }),
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                      ),
                    PopupMenuButton(
                      onSelected: (AppMenuItem item) {
                        switch (item) {
                          case AppMenuItem.Copy:
                            Utils.copyText(Utils.getShareUrl(
                                controller.id!, ShareType.apk));
                            break;
                          case AppMenuItem.Share:
                            Share.share(Utils.getShareUrl(
                                controller.id!, ShareType.apk));
                            break;
                          case AppMenuItem.Block:
                            SmartDialog.showToast('todo: Block');
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => AppMenuItem.values
                          .map((item) => PopupMenuItem<AppMenuItem>(
                                value: item,
                                child: Text(item.name),
                              ))
                          .toList(),
                    ),
                  ]
                : null,
          ),
          body: controller.appState.value is Success
              ? ExtendedNestedScrollView(
                  controller: _scrollController,
                  onlyOneScrollInBody: true,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildAppInfo(controller),
                      ),
                      if (controller.commentStatus == 1)
                        SliverOverlapAbsorber(
                          handle: ExtendedNestedScrollView
                              .sliverOverlapAbsorberHandleFor(context),
                          sliver: StickySliverToBoxAdapter(
                            child: Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: TabBar(
                                controller: _tabController,
                                tabs: _tabs,
                                onTap: (index) {
                                  if (!_tabController.indexIsChanging) {
                                    _returnTopController.setIndex(index);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      if (controller.commentStatus != 1)
                        const SliverToBoxAdapter(
                          child: Divider(height: 1),
                        ),
                    ];
                  },
                  body: controller.commentStatus == 1
                      ? LayoutBuilder(builder: (context, _) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: ExtendedNestedScrollView
                                          .sliverOverlapAbsorberHandleFor(
                                              context)
                                      .layoutExtent ??
                                  0,
                            ),
                            child: TabBarView(
                              controller: _tabController,
                              children: AppType.values
                                  .map((item) => AppContent(
                                        packageName: _packageName,
                                        appType: item,
                                        id: controller.id!,
                                      ))
                                  .toList(),
                            ),
                          );
                        })
                      : Center(child: Text(controller.commentStatusText!)),
                )
              : Center(child: _buildAppInfo(controller)),
        ),
      ),
    );
  }
}
