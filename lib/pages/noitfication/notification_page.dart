import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../pages/noitfication/notification_controller.dart';

// ignore: constant_identifier_names
enum NotificationType { AT, COMMENT, LIKE, FOLLOW, MESSAGE }

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationType type = Get.arguments['type'];
  late final String _title = switch (type) {
    NotificationType.AT => '@我的动态',
    NotificationType.COMMENT => '@我的评论',
    NotificationType.LIKE => '我收到的赞',
    NotificationType.FOLLOW => '好友关注',
    NotificationType.MESSAGE => '私信',
  };
  late final _notificationController = Get.put(
    NotificationController(
      url: switch (type) {
        NotificationType.AT => '/v6/notification/atMeList',
        NotificationType.COMMENT => '/v6/notification/atCommentMeList',
        NotificationType.LIKE => '/v6/notification/feedLikeList',
        NotificationType.FOLLOW => '/v6/notification/contactsFollowList',
        NotificationType.MESSAGE => '/v6/message/list',
      },
    ),
    tag: type.name,
  );

  @override
  void dispose() {
    _notificationController.scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        bottom: const PreferredSize(
          preferredSize: Size.zero,
          child: Divider(height: 1),
        ),
      ),
      body: commonBody(_notificationController),
    );
  }
}
