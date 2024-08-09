// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../pages/carousel/carousel_page.dart';
import '../../pages/ffflist/ffflist_content.dart';
import '../../providers/app_config_provider.dart';

enum FFFListType {
  FEED,
  FOLLOW,
  APK,
  USER_FOLLOW,
  FAN,
  RECENT,
  LIKE,
  REPLY,
  REPLYME,
  FAV,
  HISTORY,
  COLLECTION,
  COLLECTION_ITEM
}

class FFFListPage extends StatefulWidget {
  const FFFListPage({super.key});

  @override
  State<FFFListPage> createState() => _FFFListPageState();
}

class _FFFListPageState extends State<FFFListPage>
    with TickerProviderStateMixin {
  late final _config = Provider.of<AppConfigProvider>(context);
  late final String? _uid = Get.arguments['uid'] ?? _config.uid;
  late final FFFListType _type = Get.arguments['type'];
  late final String? _id = Get.arguments['id'];
  late final String? _title = Get.arguments['title'];

  late final bool _isMe = _config.uid == _uid;

  late final _followList = ['用户', '话题', '数码', '应用'];
  late final _replyList = ['我的回复', '我收到的回复'];

  late final _tabList = _type == FFFListType.FOLLOW
      ? _followList
      : _type == FFFListType.REPLY
          ? _replyList
          : null;
  late final _tabController =
      TabController(length: _tabList!.length, vsync: this);

  late final _titleText = _title ??
      switch (_type) {
        FFFListType.FEED => '我的动态',
        FFFListType.FOLLOW => '我的关注',
        FFFListType.USER_FOLLOW => _isMe ? '我关注的人' : 'TA关注的人',
        FFFListType.FAN => _isMe ? '关注我的人' : 'TA的粉丝',
        FFFListType.RECENT => '我的常去',
        FFFListType.LIKE => '我的赞',
        FFFListType.REPLY => '我的回复',
        FFFListType.COLLECTION => '我的收藏',
        FFFListType.APK => '',
        FFFListType.REPLYME => '',
        FFFListType.FAV => '',
        FFFListType.HISTORY => '',
        FFFListType.COLLECTION_ITEM => '',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: _tabList != null
            ? TabBar(
                controller: _tabController,
                tabs: _tabList.map((item) => Tab(text: item)).toList())
            : const PreferredSize(
                preferredSize: Size.zero, child: Divider(height: 1)),
      ),
      body: _tabList != null
          ? TabBarView(
              controller: _tabController,
              children: _type == FFFListType.REPLY
                  ? List.generate(
                      2,
                      (index) => FFFListContent(
                          uid: _uid,
                          id: _id,
                          type: index == 0
                              ? FFFListType.REPLY
                              : FFFListType.REPLYME)).toList()
                  : List.generate(4, (index) {
                      if (index == 0 || index == 3) {
                        return FFFListContent(
                            uid: _uid,
                            id: _id,
                            type: index == 0
                                ? FFFListType.FOLLOW
                                : FFFListType.APK);
                      } else {
                        return CarouselPage(
                          isInit: false,
                          url: index == 1
                              ? '#/topic/userFollowTagList'
                              : '#/product/followProductList',
                          title: index == 1 ? '我关注的话题' : '我关注的数码吧',
                        );
                      }
                    }).toList())
          : FFFListContent(
              uid: _type == FFFListType.COLLECTION ? null : _uid,
              id: _id,
              type: _type,
            ),
    );
  }
}
