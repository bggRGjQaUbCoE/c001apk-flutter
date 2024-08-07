// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../pages/home/return_top_controller.dart';
import '../../../pages/search/search_order_controller.dart';
import '../../../pages/search/search_result_content.dart';
import '../../../utils/extensions.dart';

enum SearchContentType { FEED, APP, GAME, TOPIC, PRODUCT, USER }

enum SearchMenuType { Type, Sort }

enum SearchType {
  ALL,
  FEED,
  ARTICLE,
  COOLPIC,
  COMMENT,
  RATING,
  ANSWER,
  QUESTION,
  VOTE,
}

enum SearchSortType { DATELINE, DEFAULT, HOT, REPLY, STRICT }

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  final String _keyword = Get.parameters['keyword'] ?? '';
  final String? _title = Get.parameters['title'];
  final String? _pageType = Get.parameters['pageType'];
  final String? _pageParam = Get.parameters['pageParam'];

  late final TabController _tabController;
  bool _shouldShowActions = true;

  late ReturnTopController _pageScrollController;
  late SearchOrderController _searchOrderController;

  @override
  void initState() {
    super.initState();

    _pageScrollController = Get.put(ReturnTopController(),
        tag: '$_keyword$_title$_pageType$_pageParam');
    _searchOrderController = Get.put(SearchOrderController(),
        tag: '$_keyword$_title$_pageType$_pageParam');

    _tabController = TabController(
      vsync: this,
      length: _title.isNullOrEmpty ? SearchContentType.values.length : 1,
    );
    _tabController.addListener(() {
      setState(() => _shouldShowActions = _tabController.index == 0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: GestureDetector(
          onTap: () => Get.back(),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _keyword,
              style: const TextStyle(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: !_title.isNullOrEmpty
                ? Text(
                    '$_pageType: $_title',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
          ),
        ),
        actions: _shouldShowActions
            ? [
                PopupMenuButton(
                  onSelected: (SearchMenuType item) {
                    switch (item) {
                      case SearchMenuType.Type:
                        _showPopupMenu(isSearchType: true);
                        break;
                      case SearchMenuType.Sort:
                        _showPopupMenu(isSearchSortType: true);
                        break;
                    }
                  },
                  itemBuilder: (context) => SearchMenuType.values
                      .map((item) => PopupMenuItem<SearchMenuType>(
                            value: item,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(item.name),
                                ),
                                const Icon(Icons.arrow_right)
                              ],
                            ),
                          ))
                      .toList(),
                )
              ]
            : null,
        bottom: _title.isNullOrEmpty
            ? TabBar(
                isScrollable: true,
                controller: _tabController,
                tabs: SearchContentType.values
                    .map((type) => Tab(
                          text: type.name,
                        ))
                    .toList(),
                onTap: (index) {
                  if (!_tabController.indexIsChanging) {
                    _pageScrollController.setIndex(index);
                  }
                },
              )
            : const PreferredSize(
                preferredSize: Size.zero,
                child: Divider(height: 1),
              ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _title.isNullOrEmpty
            ? SearchContentType.values
                .map((type) => SearchResultContent(
                      searchContentType: type,
                      keyword: _keyword,
                      title: _title,
                      pageType: _pageType,
                      pageParam: _pageParam,
                    ))
                .toList()
            : [
                SearchResultContent(
                  searchContentType: SearchContentType.FEED,
                  keyword: _keyword,
                  title: _title,
                  pageType: _pageType,
                  pageParam: _pageParam,
                )
              ],
      ),
    );
  }

  void _showPopupMenu({
    bool isSearchType = false,
    bool isSearchSortType = false,
  }) async {
    final screenSize = MediaQuery.of(context).size;
    await showMenu(
      initialValue: isSearchType
          ? _searchOrderController.searchType.value
          : isSearchSortType
              ? _searchOrderController.searchSortType.value
              : null,
      context: context,
      position:
          RelativeRect.fromLTRB(screenSize.width, 0, 0, screenSize.height),
      items: isSearchType
          ? SearchType.values
              .map((type) => PopupMenuItem(value: type, child: Text(type.name)))
              .toList()
          : SearchSortType.values
              .map((type) => PopupMenuItem(value: type, child: Text(type.name)))
              .toList(),
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        if (value is SearchType) {
          _searchOrderController.setSearchType(value);
        }
        if (value is SearchSortType) {
          _searchOrderController.setSearchSortType(value);
        }
      }
    });
  }
}
