import 'package:flutter/material.dart';

import '../../components/common_body.dart';
import '../../components/nested_tab_bar_view.dart';
import '../../logic/state/loading_state.dart';
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
  late final _fffController = FFFListController(
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
  );

  @override
  void initState() {
    super.initState();

    _onGetData();
  }

  @override
  void dispose() {
    _fffController.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _fffController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _fffController.loadingState = responseState;
        } else if (responseState is Success &&
            _fffController.loadingState is Success) {
          _fffController.loadingState = LoadingState.success(
              (_fffController.loadingState as Success).response +
                  responseState.response);
        } else {
          _fffController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _fffController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _fffController.loadingState = state),
      (state) => setState(() => _fffController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    _fffController.scrollController ??=
        NestedInnerScrollController.maybeOf(context);
    return _fffController.loadingState is Success
        ? RefreshIndicator(
            key: _fffController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _fffController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
