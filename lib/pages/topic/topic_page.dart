import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/topic/topic_content.dart';
import '../../pages/topic/topic_controller.dart';
import '../../pages/topic/topic_order_controller.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum TopicMenuItem { Copy, Share, Sort, Block }

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

  @override
  void initState() {
    super.initState();

    if (!_tag.isNullOrEmpty) {
      try {
        _tag = Uri.decodeComponent(_tag!);
      } catch (e) {
        print('topic: failed to decode tag: $_tag');
      }
    }

    _pageScrollController = Get.put(ReturnTopController(), tag: _tag ?? _id);
    _topicOrderController = Get.put(TopicOrderController(), tag: _tag ?? _id);
    _topicController = Get.put(
      TopicController(tag: _tag, id: _id),
      tag: '$_tag$_id',
    );
    _topicController.initialIndex.listen((initialIndex) {
      _tabController = TabController(
        vsync: this,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        length: _topicController.tabList!.length,
      );
      setShouldShowActions(initialIndex);
      _tabController?.addListener(() {
        setState(() => setShouldShowActions(_tabController!.index));
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
              appBar: AppBar(
                title: Text(
                  _topicController.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                bottom: TabBar(
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
                        case TopicMenuItem.Block:
                          SmartDialog.showToast('todo: block');
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
                        value: TopicMenuItem.Block,
                        child: Text(TopicMenuItem.Block.name),
                      ),
                    ],
                  ),
                ],
              ),
              body: TabBarView(
                controller: _tabController,
                children: _topicController.tabList!
                    .map((item) => TopicContent(
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
