import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../pages/ffflist/ffflist_controller.dart';
import '../../pages/ffflist/ffflist_page.dart' show FFFListType;

class FFFListContent extends StatefulWidget {
  const FFFListContent({
    super.key,
    required this.uid,
    required this.id,
    required this.type,
  });

  final String? uid;
  final String? id;
  final FFFListType type;

  @override
  State<FFFListContent> createState() => _FFFListContentState();
}

class _FFFListContentState extends State<FFFListContent> {
  late final _fffController = Get.put(
    FFFListController(
      url: switch (widget.type) {
        FFFListType.FEED => '/v6/user/feedList?showAnonymous=0&isIncludeTop=1',
        FFFListType.FOLLOW => '/v6/user/followList',
        FFFListType.APK => '/v6/user/apkFollowList',
        FFFListType.USER_FOLLOW => '/v6/user/followList',
        FFFListType.FAN => '/v6/user/fansList',
        FFFListType.RECENT => '/v6/user/recentHistoryList',
        FFFListType.LIKE => '/v6/user/likeList',
        FFFListType.REPLY => '/v6/user/replyList',
        FFFListType.REPLYME => '/v6/user/replyToMeList',
        FFFListType.FAV => throw UnimplementedError(),
        FFFListType.HISTORY => throw UnimplementedError(),
        FFFListType.COLLECTION => '/v6/collection/list',
        FFFListType.COLLECTION_ITEM => '/v6/collection/itemList',
      },
      id: widget.id,
      uid: widget.uid,
      showDefault: widget.type == FFFListType.COLLECTION ? 0 : null,
    ),
    tag: '${widget.type.name}${widget.id}${widget.uid}',
  );

  @override
  void dispose() {
    _fffController.scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return commonBody(_fffController);
  }
}
