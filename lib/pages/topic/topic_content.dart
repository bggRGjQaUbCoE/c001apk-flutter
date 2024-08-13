import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/topic/topic_content_controller.dart';
import '../../pages/topic/topic_order_controller.dart';
import '../../pages/topic/topic_page.dart' show TopicSortType;

class TopicContent extends StatefulWidget {
  const TopicContent({
    super.key,
    required this.random,
    required this.tag,
    required this.id,
    required this.index,
    required this.entityType,
    required this.url,
    required this.title,
  });

  final String random;
  final String? tag;
  final String? id;
  final int index;
  final String entityType;
  final String url;
  final String title;

  @override
  State<TopicContent> createState() => _TopicContentState();
}

class _TopicContentState extends State<TopicContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _topicController = Get.put(
    TopicContentController(
      url: widget.url,
      title: widget.title,
    ),
    tag: widget.url + widget.title + widget.random,
  );

  late final TopicOrderController? _topicOrderController;

  @override
  void dispose() {
    _topicController.scrollController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _topicController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _topicController.scrollController = ScrollController();
    _topicController.returnTopController = Get.find<ReturnTopController>(
        tag: (widget.tag ?? widget.id!) + widget.random);

    _topicController.returnTopController?.index.listen((index) {
      if (index == widget.index) {
        _topicController.animateToTop();
      }
    });

    if (widget.entityType == 'product' && widget.title == '讨论') {
      _topicOrderController = Get.find<TopicOrderController>(
          tag: (widget.tag ?? widget.id!) + widget.random);
      _topicOrderController?.topicSortType.listen((type) {
        _topicController.url =
            '/page?url=/product/feedList?type=feed&id=${widget.id}&';
        switch (type) {
          case TopicSortType.DEFAULT:
            _topicController.url = '${_topicController.url}ignoreEntityById=1';
            _topicController.title = '默认';
            break;
          case TopicSortType.DATELINE:
            _topicController.url =
                '${_topicController.url}ignoreEntityById=1&listType=dateline_desc';
            _topicController.title = '最新';
            break;
          case TopicSortType.HOT:
            _topicController.url = '${_topicController.url}listType=rank_score';
            _topicController.title = '热度';
            break;
        }
        if (_topicController.loadingState.value is Success) {
          _topicController.animateToTop();
        } else {
          _topicController.setLoadingState(LoadingState.loading());
          _topicController.onGetData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_topicController);
  }
}
