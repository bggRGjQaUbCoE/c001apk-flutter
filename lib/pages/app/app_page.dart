import 'dart:math';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:share_plus/share_plus.dart';

import '../../components/cards/app_info_card.dart';
import '../../components/sticky_sliver_to_box_adapter.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/app/app_content.dart';
import '../../pages/app/app_controller.dart';
import '../../pages/feed/reply/reply_dialog.dart';
import '../../pages/home/return_top_controller.dart';
import '../../utils/device_util.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum AppMenuItem { Copy, Share, Follow, Block }

enum AppType { reply, dateline, hot }

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with TickerProviderStateMixin {
  final String _packageName = Get.parameters['packageName'].orEmpty;
  String? _url;

  late ReturnTopController _returnTopController;

  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController =
      TabController(vsync: this, length: 3);
  final _tabs =
      ['最近回复', '最新发布', '热度排序'].map((title) => Tab(text: title)).toList();

  late final String _random = DeviceUtil.randHexString(8);

  @override
  void initState() {
    super.initState();
    _returnTopController =
        Get.put(ReturnTopController(), tag: _packageName + _random);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(() {});
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
                      '${controller.appName}-$versionName-$versionCode.apk',
                    );
                  } else {
                    _url = await Utils.onGetDownloadUrl(
                      controller.appName!,
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
      tag: _packageName + _random,
      init: AppController(packageName: _packageName),
      initState: (state) {
        _scrollController.addListener(() {
          state.controller?.scrollRatio.value =
              min(1.0, _scrollController.offset.round() / 75.0);
        });
      },
      builder: (controller) => Scaffold(
        floatingActionButton: Obx(
          () => controller.appState.value is Success &&
                  GlobalData().isLogin &&
                  !controller.isBlocked &&
                  controller.commentStatus == 1
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet<dynamic>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ReplyDialog(
                        title: controller.appName,
                        targetType: 'apk',
                        targetId:
                            '${1000000000 + int.parse(controller.id ?? '4599')}',
                      ),
                    );
                  },
                  tooltip: 'Create Feed',
                  child: const Icon(Icons.add),
                )
              : const SizedBox(),
        ),
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 56),
          child: Obx(
            () => AppBar(
              surfaceTintColor: Colors.transparent,
              title: !controller.appName.isNullOrEmpty &&
                      controller.scrollRatio.value == 1
                  ? Text(controller.appName!)
                  : null,
              actions: controller.appState.value is Success
                  ? [
                      if (!controller.isBlocked &&
                          controller.commentStatus == 1)
                        IconButton(
                          onPressed: () => Get.toNamed('/search', parameters: {
                            'title': controller.appName!,
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
                            case AppMenuItem.Follow:
                              if (GlobalData().isLogin) {
                                controller.onGetFollow(
                                  controller.isFollow,
                                  controller.isFollow
                                      ? '/v6/apk/unFollow'
                                      : '/v6/apk/follow',
                                  id: controller.id,
                                );
                              }
                              break;
                            case AppMenuItem.Block:
                              GStorage.onBlock(
                                controller.appName,
                                isUser: false,
                                isDelete: controller.isBlocked,
                              );
                              controller.isBlocked = !controller.isBlocked;
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            AppMenuItem.values
                                .map((item) => PopupMenuItem<AppMenuItem>(
                                      value: item,
                                      child: Text(
                                        item == AppMenuItem.Block
                                            ? (controller.isBlocked
                                                ? 'UnBlock'
                                                : 'Block')
                                            : item == AppMenuItem.Follow
                                                ? (controller.isFollow
                                                    ? 'UnFollow'
                                                    : 'Follow')
                                                : item.name,
                                      ),
                                    ))
                                .toList(),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        body: Obx(
          () => controller.appState.value is Success
              ? ExtendedNestedScrollView(
                  controller: _scrollController,
                  onlyOneScrollInBody: true,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildAppInfo(controller),
                      ),
                      if (!controller.isBlocked &&
                          controller.commentStatus == 1)
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
                      if (controller.isBlocked || controller.commentStatus != 1)
                        const SliverToBoxAdapter(
                          child: Divider(height: 1),
                        ),
                    ];
                  },
                  body: !controller.isBlocked && controller.commentStatus == 1
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
                                        random: _random,
                                        packageName: _packageName,
                                        appType: item,
                                        id: controller.id!,
                                      ))
                                  .toList(),
                            ),
                          );
                        })
                      : Center(
                          child: Text(controller.isBlocked
                              ? '${controller.appName} is Blocked'
                              : controller.commentStatusText!),
                        ),
                )
              : Center(child: _buildAppInfo(controller)),
        ),
      ),
    );
  }
}
