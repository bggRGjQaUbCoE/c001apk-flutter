import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/topic/topic_content.dart';
import '../../pages/topic/topic_controller.dart';
import '../../pages/topic/topic_order_controller.dart';
import '../../utils/device_util.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';
import '../../pages/feed/reply/reply_dialog.dart';

// ignore: constant_identifier_names
enum TopicMenuItem { Copy, Share, Sort, Follow, Block }

// ignore: constant_identifier_names
enum TopicSortType { DEFAULT, DATELINE, HOT }

class TopicPage extends StatefulWidget {
  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> with TickerProviderStateMixin {
  String? _tag = Get.parameters['tag'];
  final String? _id = Get.parameters['id'];

  bool _shouldShowActions = false;

  TabController? _tabController;
  late final ReturnTopController _pageScrollController;
  late final TopicOrderController _topicOrderController;
  late final TopicController _topicController;

  late final String _random = DeviceUtil.randHexString(8);

  @override
  void initState() {
    super.initState();

    if (!_tag.isNullOrEmpty) {
      try {
        _tag = Uri.decodeComponent(_tag!);
      } catch (e) {
        debugPrint('topic: failed to decode tag: $_tag');
      }
    }

    _pageScrollController =
        Get.put(ReturnTopController(), tag: (_tag ?? _id!) + _random);
    _topicOrderController =
        Get.put(TopicOrderController(), tag: (_tag ?? _id!) + _random);
    _topicController =
        Get.put(TopicController(tag: _tag, id: _id), tag: '$_tag$_id$_random');
    _topicController.initialIndex.listen((initialIndex) {
      _tabController = TabController(
        vsync: this,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        length: _topicController.tabList!.length,
      );
      setShouldShowActions(initialIndex);
      _tabController?.addListener(() {
        setShouldShowActions(_tabController!.index);
      });
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(() {});
    _tabController?.dispose();
    Get.delete<ReturnTopController>(tag: (_tag ?? _id!) + _random);
    Get.delete<TopicOrderController>(tag: (_tag ?? _id!) + _random);
    Get.delete<TopicController>(tag: '$_tag$_id$_random');
    super.dispose();
  }

  void setShouldShowActions(int index) {
    _shouldShowActions = _topicController.entityType == 'product' &&
        _topicController.tabList![index].title == '讨论';
  }

  Widget _buildBody(LoadingState topicState) {
    switch (topicState) {
      case Empty():
        return GestureDetector(
          onTap: _topicController.onReGetTopicData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: _topicController.onReGetTopicData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(topicState.errMsg),
          ),
        );
    }
    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _topicController.topicState.value is Success
          ? Scaffold(
              floatingActionButton: GlobalData().isLogin &&
                      !_topicController.isBlocked
                  ? FloatingActionButton(
                      heroTag: null,
                      onPressed: () {
                        showModalBottomSheet<dynamic>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => ReplyDialog(
                            targetType: _topicController.entityType == 'topic'
                                ? 'tag'
                                : 'product_phone',
                            targetId: _topicController.id,
                            title: _topicController.title,
                          ),
                        );
                      },
                      tooltip: 'Create Feed',
                      child: const Icon(Icons.add),
                    )
                  : null,
              appBar: AppBar(
                title: Text(
                  _topicController.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                bottom: _topicController.isBlocked
                    ? const PreferredSize(
                        preferredSize: Size.zero, child: Divider(height: 1))
                    : TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabs: _topicController.tabList!
                            .map((item) => Tab(text: item.title.toString()))
                            .toList(),
                        onTap: (value) {
                          if (!_tabController!.indexIsChanging) {
                            _pageScrollController.setIndex(value);
                          }
                        },
                      ),
                actions: [
                  if (!_topicController.isBlocked)
                    IconButton(
                      onPressed: () => Get.toNamed('/search', parameters: {
                        'title': _topicController.title!,
                        'pageType': _topicController.entityType == 'topic'
                            ? 'tag'
                            : 'product_phone',
                        'pageParam': _topicController.entityType == 'topic'
                            ? _topicController.title!
                            : _topicController.id!,
                      }),
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                    ),
                  PopupMenuButton(
                    onSelected: (TopicMenuItem item) {
                      switch (item) {
                        case TopicMenuItem.Copy:
                          Utils.copyText(Utils.getShareUrl(
                            _topicController.entityType == 'topic'
                                ? _topicController.title!
                                : _topicController.id!,
                            _topicController.entityType == 'topic'
                                ? ShareType.t
                                : ShareType.product,
                          ));
                          break;
                        case TopicMenuItem.Share:
                          Share.share(Utils.getShareUrl(
                            _topicController.entityType == 'topic'
                                ? _topicController.title!
                                : _topicController.id!,
                            _topicController.entityType == 'topic'
                                ? ShareType.t
                                : ShareType.product,
                          ));
                          break;
                        case TopicMenuItem.Sort:
                          _showPopupMenu();
                          break;
                        case TopicMenuItem.Follow:
                          if (GlobalData().isLogin) {
                            if (_topicController.entityType == 'topic') {
                              _topicController.onGetFollow(
                                _topicController.isFollow,
                                _topicController.isFollow
                                    ? "/v6/feed/unFollowTag"
                                    : "/v6/feed/followTag",
                                tag: _topicController.title,
                              );
                            } else {
                              _topicController.postLikeDeleteFollow(
                                _topicController.id,
                                null,
                                isProduct: true,
                                isFollow: _topicController.isFollow,
                              );
                            }
                          }
                          break;
                        case TopicMenuItem.Block:
                          GStorage.onBlock(
                            _topicController.title!,
                            isUser: false,
                            isDelete: _topicController.isBlocked,
                          );
                          _topicController.isBlocked =
                              !_topicController.isBlocked;
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: TopicMenuItem.Copy,
                        child: Text(TopicMenuItem.Copy.name),
                      ),
                      PopupMenuItem(
                        value: TopicMenuItem.Share,
                        child: Text(TopicMenuItem.Share.name),
                      ),
                      if (_shouldShowActions)
                        PopupMenuItem(
                          value: TopicMenuItem.Sort,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(TopicMenuItem.Sort.name),
                              ),
                              const Icon(Icons.arrow_right)
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: TopicMenuItem.Follow,
                        child: Text(
                            _topicController.isFollow ? 'UnFollow' : 'Follow'),
                      ),
                      PopupMenuItem(
                        value: TopicMenuItem.Block,
                        child: Text(
                            _topicController.isBlocked ? 'UnBlock' : 'Block'),
                      ),
                    ],
                  ),
                ],
              ),
              body: _topicController.isBlocked
                  ? Center(
                      child: Text('${_topicController.title} is Blocked'),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: _topicController.tabList!
                          .map((item) => TopicContent(
                                random: _random,
                                tag: _topicController.tag,
                                id: _topicController.id,
                                index: _topicController.tabList!.indexOf(item),
                                entityType: _topicController.entityType!,
                                url: item.url.toString(),
                                title: item.title.toString(),
                              ))
                          .toList(),
                    ),
            )
          : Scaffold(
              appBar: AppBar(),
              body:
                  Center(child: _buildBody(_topicController.topicState.value)),
            ),
    );
  }

  void _showPopupMenu() async {
    final screenSize = MediaQuery.of(context).size;
    await showMenu(
      initialValue: _topicOrderController.topicSortType.value,
      context: context,
      position:
          RelativeRect.fromLTRB(screenSize.width, 0, 0, screenSize.height),
      items: TopicSortType.values
          .map((type) => PopupMenuItem(value: type, child: Text(type.name)))
          .toList(),
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _topicOrderController.setTopicSortType(value);
      }
    });
  }
}
