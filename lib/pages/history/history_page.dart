import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/feed_card.dart';
import '../../pages/history/history_controller.dart';

// ignore: constant_identifier_names
enum HistoryType { Favorite, History }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryType _type = Get.arguments['type'];

  late final _controller = Get.put(
    HistoryController(type: _type),
    tag: _type.name,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(_type.name),
          actions: _controller.dataList.isNotEmpty
              ? [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                            '确定清除全部${_type == HistoryType.Favorite ? '收藏' : '浏览历史'}？'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              _controller.clearAll();
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear All',
                  )
                ]
              : null,
          bottom: const PreferredSize(
              preferredSize: Size.zero, child: Divider(height: 1)),
        ),
        body: _controller.dataList.isNotEmpty
            ? ListView.separated(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10 + MediaQuery.of(context).padding.bottom,
                ),
                itemCount: _controller.dataList.length,
                itemBuilder: (_, index) => FeedCard(
                  isHistory: true,
                  data: _controller.dataList[index],
                  onDelete: (id) {
                    _controller.onDeleteFeed(_controller.dataList[index].id);
                  },
                ),
                separatorBuilder: (_, index) => const SizedBox(height: 10),
              )
            : const Center(
                child: Text('EMPTY'),
              ),
      ),
    );
  }
}
