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
    required this.random,
    required this.searchContentType,
    required this.keyword,
    this.title,
    this.pageType,
    this.pageParam,
  });

  final String random;
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

  late final String _type = switch (widget.searchContentType) {
    SearchContentType.FEED => 'feed',
    SearchContentType.APP => 'apk',
    SearchContentType.GAME => 'game',
    SearchContentType.TOPIC => 'feedTopic',
    SearchContentType.PRODUCT => 'product',
    SearchContentType.USER => 'user',
  };

  late final _searchController = Get.put(
    SearchController(
      type: _type,
      keyword: widget.keyword,
      pageType: widget.pageType,
      pageParam: widget.pageParam,
    ),
    tag:
        '$_type${widget.keyword}${widget.pageType}${widget.pageParam}${widget.random}',
  );

  late final SearchOrderController _searchOrderController;

  @override
  void dispose() {
    _searchController.scrollController?.dispose();
    Get.delete<SearchController>(
      tag:
          '$_type${widget.keyword}${widget.pageType}${widget.pageParam}${widget.random}',
    );
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _searchController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _searchController.scrollController = ScrollController();
    _searchController.returnTopController = Get.find<ReturnTopController>(
        tag:
            '${widget.keyword}${widget.title}${widget.pageType}${widget.pageParam}${widget.random}');

    _searchController.returnTopController?.index.listen((index) {
      if (index == SearchContentType.values.indexOf(widget.searchContentType)) {
        _searchController.animateToTop();
      }
    });

    _searchOrderController = Get.find<SearchOrderController>(
        tag:
            '${widget.keyword}${widget.title}${widget.pageType}${widget.pageParam}${widget.random}');
    _searchOrderController.searchType.listen((type) {
      _searchController.feedType = switch (type) {
        SearchType.ALL => 'all',
        SearchType.FEED => 'feed',
        SearchType.ARTICLE => 'feedArticle',
        SearchType.COOLPIC => 'picture',
        SearchType.COMMENT => 'comment',
        SearchType.RATING => 'rating',
        SearchType.ANSWER => 'answer',
        SearchType.QUESTION => 'question',
        SearchType.VOTE => 'vote',
      };
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
  }

  void onOrderSearch() {
    if (_searchController.loadingState.value is Success) {
      _searchController.animateToTop();
    } else {
      _searchController.setLoadingState(LoadingState.loading());
      _searchController.onGetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return commonBody(_searchController);
  }
}
