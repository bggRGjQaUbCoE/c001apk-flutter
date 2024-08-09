import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/feed/reply_2_reply_controller.dart';

class Reply2ReplyPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: id,
      init: Reply2ReplyController(originReply: originReply, id: id),
      dispose: (state) {
        state.controller?.scrollController?.dispose();
      },
      builder: (controller) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            middle: Text(
              '共 $replynum 回复',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )),
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => controller.loadingState.value is Success
                ? buildBody(
                    controller,
                    isReply2Reply: true,
                    uid: originReply.uid,
                  )
                : Center(
                    child: buildBody(
                      controller,
                      isReply2Reply: true,
                      uid: originReply.uid,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
