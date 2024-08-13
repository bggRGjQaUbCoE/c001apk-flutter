import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/coolpic/coolpic_content.dart';
import '../../pages/home/return_top_controller.dart';
import '../../utils/device_util.dart';

class CoolpicPage extends StatefulWidget {
  const CoolpicPage({super.key});

  @override
  State<CoolpicPage> createState() => _CoolpicPageState();
}

class _CoolpicPageState extends State<CoolpicPage>
    with TickerProviderStateMixin {
  String _title = Get.parameters['title'] ?? '';

  late final TabController _tabController =
      TabController(vsync: this, length: 3);
  late final ReturnTopController _returnTopController;

  late final String _random = DeviceUtil.randHexString(8);

  @override
  void initState() {
    super.initState();
    try {
      _title = Uri.decodeComponent(_title);
    } catch (e) {
      print(e.toString());
    }
    _returnTopController =
        Get.put(ReturnTopController(), tag: _title + _random);
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
          tabs: ['精选', '热门', '最新'].map((title) => Tab(text: title)).toList(),
          onTap: (index) {
            if (!_tabController.indexIsChanging) {
              _returnTopController.setIndex(index);
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['recommend', 'hot', 'newest']
            .map((type) => CoolpicContent(
                  random: _random,
                  type: type,
                  title: _title,
                ))
            .toList(),
      ),
    );
  }
}
