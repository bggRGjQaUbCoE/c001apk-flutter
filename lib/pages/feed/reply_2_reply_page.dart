import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/common_body.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/feed/reply_2_reply_controller.dart';

class Reply2ReplyPage extends StatefulWidget {
  const Reply2ReplyPage({
    super.key,
    required this.id,
    required this.replynum,
    required this.originReply,
  });

  final String id;
  final dynamic replynum;
  final Datum originReply;

  @override
  State<Reply2ReplyPage> createState() => _Reply2ReplyPageState();
}

class _Reply2ReplyPageState extends State<Reply2ReplyPage> {
  late final _replyController = Reply2ReplyController(id: widget.id);

  @override
  void initState() {
    super.initState();

    _onGetData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _replyController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh && responseState is! Error) {
          if (responseState is Success) {
            _replyController.loadingState = LoadingState.success(
                [widget.originReply] + responseState.response);
          } else {
            _replyController.footerState = LoadingState.empty();
            _replyController.loadingState =
                LoadingState.success([widget.originReply]);
          }
        } else if (isRefresh) {
          _replyController.loadingState = responseState;
        } else if (responseState is Success &&
            _replyController.loadingState is Success) {
          _replyController.loadingState = LoadingState.success(
              (_replyController.loadingState as Success).response +
                  responseState.response);
        } else {
          _replyController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _replyController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _replyController.loadingState = state),
      (state) => setState(() => _replyController.footerState = state),
      isReply2Reply: true,
      uid: widget.originReply.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          middle: Text(
            '共 ${widget.replynum} 回复',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          )),
      child: SafeArea(
        bottom: false,
        child: _replyController.loadingState is Success
            ? _buildBody()
            : Center(child: _buildBody()),
      ),
    );
  }
}
