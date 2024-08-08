import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/topic/topic_controller.dart';
import '../../pages/topic/topic_order_controller.dart';
import '../../pages/topic/topic_page.dart' show TopicSortType;

class TopicContent extends StatefulWidget {
  const TopicContent({
    super.key,
    required this.tag,
    required this.id,
    required this.index,
    required this.entityType,
    required this.url,
    required this.title,
  });

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

  late final _topicController = TopicController(
    url: widget.url,
    title: widget.title,
  );

  late final TopicOrderController _topicOrderController;

  @override
  void initState() {
    super.initState();

    _topicController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _topicController.scrollController = ScrollController();
    _topicController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.tag ?? widget.id);

    _topicController.returnTopController?.index.listen((index) {
      if (index == widget.index) {
        _topicController.animateToTop();
      }
    });

    if (widget.entityType == 'product' && widget.title == '讨论') {
      _topicOrderController =
          Get.find<TopicOrderController>(tag: widget.tag ?? widget.id);
      _topicOrderController.topicSortType.listen((type) {
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
        if (_topicController.loadingState is Success) {
          _topicController.animateToTop();
        } else {
          setState(
              () => _topicController.loadingState = LoadingState.loading());
          _onGetData();
        }
      });
    }

    _onGetData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _topicController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _topicController.loadingState = responseState;
        } else if (responseState is Success &&
            _topicController.loadingState is Success) {
          _topicController.loadingState = LoadingState.success(
              (_topicController.loadingState as Success).response +
                  responseState.response);
        } else {
          _topicController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _topicController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _topicController.loadingState = state),
      (state) => setState(() => _topicController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _topicController.loadingState is Success
        ? RefreshIndicator(
            key: _topicController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _topicController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
