import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/search_history_card.dart';
import '../../pages/search/search_page_controller.dart';
import '../../utils/extensions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final String? _title = Get.parameters['title'];
  final String? _pageType = Get.parameters['pageType'];
  final String? _pageParam = Get.parameters['pageParam'];
  bool _shouldShowClearBtn = false;

  late final _searchPageController = Get.put(SearchPageController());

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onSearch(String text) async {
    if (text.isNotEmpty) {
      _searchPageController.handleSearch(text);
      await Get.toNamed('/searchResult', parameters: {
        'keyword': text,
        if (!_title.isNullOrEmpty) 'title': _title!,
        if (!_pageType.isNullOrEmpty) 'pageType': _pageType!,
        if (!_pageParam.isNullOrEmpty) 'pageParam': _pageParam!,
      });
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _focusNode,
          onTap: () => _focusNode.requestFocus(),
          controller: _controller,
          style: const TextStyle(fontSize: 18),
          onChanged: (_) =>
              setState(() => _shouldShowClearBtn = _controller.text.isNotEmpty),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search${!_title.isNullOrEmpty ? ' in $_title' : ''}',
            hintStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          textInputAction: TextInputAction.search,
          autofocus: true,
          onSubmitted: (value) {
            onSearch(value);
          },
        ),
        actions: [
          if (_shouldShowClearBtn)
            IconButton(
              onPressed: () {
                _controller.clear();
                _focusNode.requestFocus();
                setState(() => _shouldShowClearBtn = false);
              },
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
            ),
          IconButton(
            onPressed: () {
              onSearch(_controller.text);
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.zero,
          child: Divider(height: 1),
        ),
      ),
      body: Obx(() => _searchPageController.historyList.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Expanded(
                      flex: 1,
                      child: Text(
                        '搜索历史',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('确定清除全部搜索历史？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      _searchPageController.clearAll();
                                    },
                                    child: const Text('确定'),
                                  )
                                ],
                              )),
                      icon: const Icon(Icons.clear_all),
                    )
                  ],
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10 + MediaQuery.of(context).padding.bottom,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _searchPageController.historyList
                        .map(
                          (text) => SearchHistoryCard(
                            text: text,
                            onTap: () {
                              _controller.text = text;
                              setState(() => _shouldShowClearBtn = true);
                              onSearch(text);
                            },
                            onLongPress: () =>
                                _searchPageController.handleSearch(text, true),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            )
          : const SizedBox()),
    );
  }
}
