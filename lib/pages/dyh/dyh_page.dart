import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/dyh/dyh_content.dart';
import '../../pages/home/return_top_controller.dart';
import '../../utils/device_util.dart';

class DyhPage extends StatefulWidget {
  const DyhPage({super.key});

  @override
  State<DyhPage> createState() => _DyhPageState();
}

class _DyhPageState extends State<DyhPage> with TickerProviderStateMixin {
  final String _id = Get.parameters['id'] ?? '';
  String _title = Get.parameters['title'] ?? '';

  late final TabController _tabController =
      TabController(vsync: this, length: 2);
  late final ReturnTopController _returnTopController;

  late final String _random = DeviceUtil.randHexString(8);

  @override
  void initState() {
    super.initState();
    try {
      _title = Uri.decodeComponent(_title);
    } catch (e) {
      debugPrint(e.toString());
    }
    _returnTopController =
        Get.put(ReturnTopController(), tag: _id + _title + _random);
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
        title: Text(_title),
        bottom: TabBar(
          controller: _tabController,
          tabs: ['精选', '广场'].map((title) => Tab(text: title)).toList(),
          onTap: (index) {
            if (!_tabController.indexIsChanging) {
              _returnTopController.setIndex(index);
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['all', 'square']
            .map((type) => DyhContent(
                  random: _random,
                  type: type,
                  id: _id,
                  title: _title,
                ))
            .toList(),
      ),
    );
  }
}
