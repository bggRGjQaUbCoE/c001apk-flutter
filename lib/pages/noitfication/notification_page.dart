import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
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
  late final _notificationController = NotificationController(
    url: switch (type) {
      NotificationType.AT => '/v6/notification/atMeList',
      NotificationType.COMMENT => '/v6/notification/atCommentMeList',
      NotificationType.LIKE => '/v6/notification/feedLikeList',
      NotificationType.FOLLOW => '/v6/notification/contactsFollowList',
      NotificationType.MESSAGE => '/v6/message/list',
    },
  );

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _onGetData();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _notificationController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _notificationController.loadingState = responseState;
        } else if (responseState is Success &&
            _notificationController.loadingState is Success) {
          _notificationController.loadingState = LoadingState.success(
              (_notificationController.loadingState as Success).response +
                  responseState.response);
        } else {
          _notificationController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _notificationController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _notificationController.loadingState = state),
      (state) => setState(() => _notificationController.footerState = state),
    );
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
      body: _notificationController.loadingState is Success
          ? RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              onRefresh: () async {
                _notificationController.onReset();
                await _onGetData();
              },
              child: _buildBody(),
            )
          : Center(child: _buildBody()),
    );
  }
}
