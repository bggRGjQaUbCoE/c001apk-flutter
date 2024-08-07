import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../logic/network/network_repo.dart';
import '../../../logic/model/feed/datum.dart';
import '../../../logic/model/feed/tab_list.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/home/return_top_controller.dart';
import '../../../pages/topic/topic_content.dart';
import '../../../pages/topic/topic_order_controller.dart';
import '../../../utils/extensions.dart';
import '../../../utils/utils.dart';

// ignore: constant_identifier_names
enum TopicMenuItem { Copy, Share, Sort, Block }

// ignore: constant_identifier_names
enum TopicSortType { DEFAULT, DATELINE, HOT }

class TopicPage extends StatefulWidget {
  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage>
    with SingleTickerProviderStateMixin {
  String? _tag = Get.parameters['tag'];
  String? _id = Get.parameters['id'];
  String? _title;
  String? _entityType;
  List<TabList>? _tabList;

  LoadingState _topicState = LoadingState.loading();
  bool _shouldShowActions = false;

  TabController? _tabController;
  late final ReturnTopController _pageScrollController;
  late final TopicOrderController _topicOrderController;

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

    _getTopicData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void setShouldShowActions(int index) {
    _shouldShowActions =
        _entityType == 'product' && _tabList![index].title == '讨论';
  }

  Future<void> _getTopicData() async {
    LoadingState<dynamic> response = await NetworkRepo.getDataFromUrl(
      url: !_tag.isNullOrEmpty
          ? '/v6/topic/newTagDetail'
          : !_id.isNullOrEmpty
              ? '/v6/product/detail'
              : '',
      data: {
        if (!_tag.isNullOrEmpty) 'tag': _tag,
        if (!_id.isNullOrEmpty) 'id': _id!,
      },
    );
    if (response is Success) {
      _id = (response.response as Datum).id.toString();
      _title = (response.response as Datum).title;
      _entityType = (response.response as Datum).entityType;
      _tabList = (response.response as Datum).tabList;
      String selectedTab = (response.response as Datum).selectedTab!;
      int initialIndex =
          _tabList!.map((item) => item.pageName).toList().indexOf(selectedTab);
      _tabController = TabController(
        vsync: this,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
        length: _tabList!.length,
      );
      setShouldShowActions(initialIndex);
      _tabController?.addListener(() {
        setState(() => setShouldShowActions(_tabController!.index));
      });
      setState(() {
        _topicState = LoadingState.success(response.response);
      });
    } else {
      setState(() => _topicState = response);
    }
  }

  void _onReGetTopicData() {
    setState(() => _topicState = LoadingState.loading());
    _getTopicData();
  }

  Widget _buildBody() {
    switch (_topicState) {
      case Empty():
        return GestureDetector(
          onTap: _onReGetTopicData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: _onReGetTopicData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text((_topicState as Error).errMsg),
          ),
        );
    }
    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return _topicState is Success
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                _title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabList!
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
                    'title': _title!,
                    'pageType':
                        _entityType == 'topic' ? 'tag' : 'product_phone',
                    'pageParam': _entityType == 'topic' ? _title! : _id!,
                  }),
                  icon: const Icon(Icons.search),
                ),
                PopupMenuButton(
                  onSelected: (TopicMenuItem item) {
                    switch (item) {
                      case TopicMenuItem.Copy:
                        Utils.copyText(Utils.getShareUrl(
                          _entityType == 'topic' ? _title! : _id!,
                          _entityType == 'topic'
                              ? ShareType.t
                              : ShareType.product,
                        ));
                        break;
                      case TopicMenuItem.Share:
                        Share.share(Utils.getShareUrl(
                          _entityType == 'topic' ? _title! : _id!,
                          _entityType == 'topic'
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
              children: _tabList!
                  .map((item) => TopicContent(
                        tag: _tag,
                        id: _id,
                        index: _tabList!.indexOf(item),
                        entityType: _entityType!,
                        url: item.url.toString(),
                        title: item.title.toString(),
                      ))
                  .toList(),
            ),
          )
        : Scaffold(
            appBar: AppBar(),
            body: Center(child: _buildBody()),
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
