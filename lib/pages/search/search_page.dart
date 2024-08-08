import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onSearch(String text) async {
    await Get.toNamed('/searchResult', parameters: {
      'keyword': text,
      if (!_title.isNullOrEmpty) 'title': _title!,
      if (!_pageType.isNullOrEmpty) 'pageType': _pageType!,
      if (!_pageParam.isNullOrEmpty) 'pageParam': _pageParam!,
    });
    _focusNode.requestFocus();
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
            if (value.isNotEmpty) {
              onSearch(value);
            }
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
              if (_controller.text.isNotEmpty) {
                onSearch(_controller.text);
              }
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
      body: const Center(child: Text('search history')),
    );
  }
}
