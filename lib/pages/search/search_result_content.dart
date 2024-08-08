import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../pages/search/search_controller.dart';
import '../../pages/search/search_order_controller.dart';
import '../../pages/search/search_result_page.dart'
    show SearchContentType, SearchSortType, SearchType;

class SearchResultContent extends StatefulWidget {
  const SearchResultContent({
    super.key,
    required this.searchContentType,
    required this.keyword,
    this.title,
    this.pageType,
    this.pageParam,
  });

  final SearchContentType searchContentType;
  final String keyword;
  final String? title;
  final String? pageType;
  final String? pageParam;

  @override
  State<SearchResultContent> createState() => _SearchResultContentState();
}

class _SearchResultContentState extends State<SearchResultContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _getType() {
    switch (widget.searchContentType) {
      case SearchContentType.FEED:
        return 'feed';
      case SearchContentType.APP:
        return 'apk';
      case SearchContentType.GAME:
        return 'game';
      case SearchContentType.TOPIC:
        return 'feedTopic';
      case SearchContentType.PRODUCT:
        return 'product';
      case SearchContentType.USER:
        return 'user';
    }
  }

  late final _searchController = SearchController(
    type: _getType(),
    keyword: widget.keyword,
    pageType: widget.pageType,
    pageParam: widget.pageParam,
  );

  late final SearchOrderController _searchOrderController;

  @override
  void initState() {
    super.initState();

    _searchController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _searchController.scrollController = ScrollController();
    _searchController.returnTopController = Get.find<ReturnTopController>(
        tag:
            '${widget.keyword}${widget.title}${widget.pageType}${widget.pageParam}');

    _searchController.returnTopController?.index.listen((index) {
      if (index == SearchContentType.values.indexOf(widget.searchContentType)) {
        _searchController.animateToTop();
      }
    });

    _searchOrderController = Get.find<SearchOrderController>(
        tag:
            '${widget.keyword}${widget.title}${widget.pageType}${widget.pageParam}');
    _searchOrderController.searchType.listen((type) {
      switch (type) {
        case SearchType.ALL:
          _searchController.feedType = 'all';
          break;
        case SearchType.FEED:
          _searchController.feedType = 'feed';
          break;
        case SearchType.ARTICLE:
          _searchController.feedType = 'feedArticle';
          break;
        case SearchType.COOLPIC:
          _searchController.feedType = 'picture';
          break;
        case SearchType.COMMENT:
          _searchController.feedType = 'comment';
          break;
        case SearchType.RATING:
          _searchController.feedType = 'rating';
          break;
        case SearchType.ANSWER:
          _searchController.feedType = 'answer';
          break;
        case SearchType.QUESTION:
          _searchController.feedType = 'question';
          break;
        case SearchType.VOTE:
          _searchController.feedType = 'vote';
          break;
      }
      onOrderSearch();
    });
    _searchOrderController.searchSortType.listen((type) {
      switch (type) {
        case SearchSortType.DATELINE:
          _searchController.sort = 'dateline';
          _searchController.isStrict = 0;
          break;
        case SearchSortType.DEFAULT:
          _searchController.sort = 'none';
          _searchController.isStrict = 0;
          break;

        case SearchSortType.HOT:
          _searchController.sort = 'hot';
          _searchController.isStrict = 0;
          break;
        case SearchSortType.REPLY:
          _searchController.sort = 'reply';
          _searchController.isStrict = 0;
          break;
        case SearchSortType.STRICT:
          _searchController.sort = '';
          _searchController.isStrict = 1;
          break;
      }
      onOrderSearch();
    });

    _onGetData();
  }

  void onOrderSearch() {
    if (_searchController.loadingState is Success) {
      _searchController.animateToTop();
    } else {
      setState(() => _searchController.loadingState = LoadingState.loading());
      _onGetData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _searchController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _searchController.loadingState = responseState;
        } else if (responseState is Success &&
            _searchController.loadingState is Success) {
          _searchController.loadingState = LoadingState.success(
              (_searchController.loadingState as Success).response +
                  responseState.response);
        } else {
          _searchController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _searchController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _searchController.loadingState = state),
      (state) => setState(() => _searchController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _searchController.loadingState is Success
        ? RefreshIndicator(
            key: _searchController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _searchController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
