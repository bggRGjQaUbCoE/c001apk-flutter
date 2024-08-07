import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response;
import 'package:share_plus/share_plus.dart';

import '../../components/cards/app_info_card.dart';
import '../../components/nested_tab_bar_view.dart';
import '../../components/sticky_sliver_to_box_adapter.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/app/app_content.dart';
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

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  final String _packageName = Get.parameters['packageName'].orEmpty;
  String? _id;
  String? _appName;
  int? _commentStatus;
  String? _commentStatusText;
  late final String _entityType;
  String? _url;

  LoadingState _appState = LoadingState.loading();

  double _scrollRatio = 0;

  late ReturnTopController _pageScrollController;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final _tabs =
      ['最近回复', '最新发布', '热度排序'].map((title) => Tab(text: title)).toList();

  @override
  void initState() {
    super.initState();
    _pageScrollController = Get.put(ReturnTopController(), tag: _packageName);
    _tabController =
        TabController(vsync: this, length: AppMenuItem.values.length);
    _scrollController.addListener(() {
      setState(() =>
          _scrollRatio = min(1.0, _scrollController.offset.round() / 75.0));
    });
    _getAppData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getAppData() async {
    LoadingState<dynamic> response =
        await NetworkRepo.getAppInfo(id: _packageName);
    if (response is Success) {
      _id = (response.response as Datum).id.toString();
      _commentStatus = (response.response as Datum).commentStatus;
      _commentStatusText = (response.response as Datum).commentStatusText;
      _entityType = (response.response as Datum).entityType.orEmpty;
      setState(() {
        _appState = LoadingState.success(response.response);
        _appName = (response.response as Datum).title;
      });
    } else {
      setState(() => _appState = response);
    }
  }

  void _onReGetUserData() {
    setState(() => _appState = LoadingState.loading());
    _getAppData();
  }

  Widget _buildAppInfo() {
    switch (_appState) {
      case Empty():
        return GestureDetector(
          onTap: _onReGetUserData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: _onReGetUserData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text((_appState as Error).errMsg),
          ),
        );
      case Success():
        return AppInfoCard(
          data: (_appState as Success).response!,
          onDownloadApk: _entityType == 'apk'
              ? (id, versionName, versionCode) async {
                  if (!_url.isNullOrEmpty) {
                    Utils.onDownloadFile(
                      _url!,
                      '$_appName-$versionName-$versionCode.apk',
                    );
                  } else {
                    _url = await Utils.onGetDownloadUrl(
                      _appName.orEmpty,
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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: _appName != null && _scrollRatio == 1 ? Text(_appName!) : null,
        actions: _appState is Success
            ? [
                if (_commentStatus == 1)
                  IconButton(
                    onPressed: () => Get.toNamed('/search', parameters: {
                      'title': _appName!,
                      'pageType': 'apk',
                      'pageParam': _id!,
                    }),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                PopupMenuButton(
                  onSelected: (AppMenuItem item) {
                    switch (item) {
                      case AppMenuItem.Copy:
                        Utils.copyText(Utils.getShareUrl(_id!, ShareType.apk));
                        break;
                      case AppMenuItem.Share:
                        Share.share(Utils.getShareUrl(_id!, ShareType.apk));
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
      body: _appState is Success
          ? NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildAppInfo(),
                  ),
                  if (_commentStatus == 1)
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: StickySliverToBoxAdapter(
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: TabBar(
                            controller: _tabController,
                            tabs: _tabs,
                            onTap: (index) {
                              if (!_tabController.indexIsChanging) {
                                _pageScrollController.setIndex(index);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  if (_commentStatus != 1)
                    const SliverToBoxAdapter(
                      child: Divider(height: 1),
                    ),
                ];
              },
              body: _commentStatus == 1
                  ? LayoutBuilder(builder: (context, _) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: NestedScrollView.sliverOverlapAbsorberHandleFor(
                                      context)
                                  .layoutExtent ??
                              0,
                        ),
                        child: NestedTabBarView(
                          controller: _tabController,
                          children: AppType.values
                              .map((item) => AppContent(
                                    packageName: _packageName,
                                    appType: item,
                                    id: _id!,
                                  ))
                              .toList(),
                        ),
                      );
                    })
                  : Center(child: Text(_commentStatusText!)),
            )
          : Center(child: _buildAppInfo()),
    );
  }
}
