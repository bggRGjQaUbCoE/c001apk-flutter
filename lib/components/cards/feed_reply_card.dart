import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../components/html_text.dart';
import '../../components/icon_text.dart';
import '../../components/imageview.dart';
import '../../logic/model/feed/datum.dart';
import '../../pages/feed/reply/reply_2_reply_page.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class FeedReplyCard extends StatelessWidget {
  const FeedReplyCard({
    super.key,
    required this.data,
    this.isReply2Reply = false,
    this.isTopReply = false,
    this.uid,
  });

  final Datum data;
  final bool isReply2Reply;
  final bool isTopReply;
  final dynamic uid;

  @override
  Widget build(BuildContext context) {
    final isFeedReply = data.fetchType == 'feed_reply';
    return Material(
      color: !isFeedReply || (isReply2Reply && !isTopReply)
          ? Theme.of(context).colorScheme.onInverseSurface
          : Colors.transparent,
      borderRadius:
          !isFeedReply ? const BorderRadius.all(Radius.circular(12)) : null,
      child: InkWell(
        onTap: () {
          if (isFeedReply) {
            SmartDialog.showToast('todo: reply');
          } else {
            Utils.onOpenLink(data.url ?? '');
          }
        },
        onLongPress: () {
          Get.toNamed('/copy', parameters: {'text': data.message.toString()});
        },
        borderRadius:
            !isFeedReply ? const BorderRadius.all(Radius.circular(12)) : null,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () => showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (context) {
                          return _MorePanel(
                            id: data.id.toString(),
                            uid: data.uid.toString(),
                            reply: data..fetchType = 'feed_reply',
                          );
                        },
                      ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.outline,
                  )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: !isFeedReply ? 10 : 16,
                vertical: !isFeedReply ? 10 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/u/${data.uid}'),
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          data.userAvatar.toString(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _username(),
                        htmlText(data.message.toString()),
                        if (!data.picArr.isNullOrEmpty) ...[
                          const SizedBox(height: 10),
                          _image(),
                        ],
                        if (!isFeedReply &&
                            data.feed != null &&
                            !isReply2Reply) ...[
                          const SizedBox(height: 10),
                          _feed(context),
                        ],
                        const SizedBox(height: 10),
                        _bottomInfo(context),
                        if (!isReply2Reply &&
                            !data.replyRows.isNullOrEmpty) ...[
                          const SizedBox(height: 10),
                          _replyRows(context),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        return image(
          maxWidth,
          data.picArr!,
        );
      },
    );
  }

  Widget _username() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: htmlText(
        !isReply2Reply
            ? '${data.userInfo?.username}${data.uid == data.feedUid ? ' [楼主]' : ''}'
            : () {
                String replyTag = data.uid == data.feedUid
                    ? ' [楼主] '
                    : data.uid == uid && !isTopReply
                        ? ' [层主] '
                        : '';
                if (isTopReply) {
                  return '<a class="feed-link-uname" href="/u/${data.uid}">${data.userInfo?.username}$replyTag</a>';
                }
                String rReplyTag = data.ruid == data.feedUid
                    ? ' [楼主] '
                    : data.ruid == uid
                        ? ' [层主] '
                        : '';
                return data.ruid == 0
                    ? '<a class="feed-link-uname" href="/u/${data.uid}">${data.userInfo?.username}$replyTag</a>'
                    : '<a class="feed-link-uname" href="/u/${data.uid}">${data.userInfo?.username}$replyTag</a>回复<a class="feed-link-uname" href="/u/${data.rusername}">${data.rusername}$rReplyTag</a>';
              }(),
      ),
    );
  }

  Widget _feed(BuildContext context) {
    Datum feed = Datum.fromJson(data.feed);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: () => Utils.onOpenLink(feed.url ?? ''),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              if (!feed.pic.isNullOrEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: feed.pic!,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${feed.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      Utils.parseHtmlString(feed.message ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _replyRows(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.replyRows!.map((item) => _replyRowsItem(context, item)),
          if (data.replyRowsMore != null && data.replyRowsMore! > 0)
            InkWell(
              onTap: () {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Reply2ReplyPage(
                        id: data.id.toString(),
                        replynum: data.replynum,
                        originReply: data);
                  },
                );
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '查看更多回复(${data.replynum})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _replyRowsItem(BuildContext context, Datum reply) {
    return InkWell(
      onTap: () {
        SmartDialog.showToast('todo: reply');
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (context) {
            return _MorePanel(
              id: reply.id.toString(),
              uid: reply.uid.toString(),
              message: reply.message.toString(),
              fid: data.id.toString(),
              reply: reply,
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: htmlText(
          () {
            String replyTag = reply.uid == data.feedUid
                ? ' [楼主] '
                : reply.uid == data.uid
                    ? ' [层主] '
                    : '';
            String rReplyTag = reply.ruid == data.feedUid
                ? ' [楼主] '
                : reply.ruid == data.uid
                    ? ' [层主] '
                    : '';
            String rReplyUser = reply.ruid == data.uid
                ? ''
                : '<a class="feed-link-uname" href="/u/${reply.ruid}">${reply.rusername}$rReplyTag</a>';
            String replyPic = reply.picArr.isNullOrEmpty
                ? ''
                : ' <a class="feed-forward-pic" href=${reply.pic}>查看图片(${reply.picArr!.length})</a>';
            return '<a class="feed-link-uname" href="/u/${reply.uid}">${reply.userInfo?.username}$replyTag</a>回复$rReplyUser: ${reply.message}$replyPic';
          }(),
          fontSize: 14,
          onShowTotalReply: () => showCupertinoModalBottomSheet(
            context: context,
            builder: (context) {
              return Reply2ReplyPage(
                id: data.id.toString(),
                replynum: data.replynum,
                originReply: data,
              );
            },
          ),
          picArr: reply.picArr,
        ),
      ),
    );
  }

  Widget _bottomInfo(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            DateUtil.fromToday(data.dateline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        IconText(
          icon: Icons.message_outlined,
          text: data.replynum.toString(),
          onTap: null,
        ),
        const SizedBox(width: 10),
        IconText(
          icon: Icons.thumb_up_outlined,
          text: data.likenum.toString(),
          onTap: () {
            SmartDialog.showToast('todo: like');
          },
        ),
      ],
    );
  }
}

enum PanelAction { copy, block, report, showReply }

class _MorePanel extends StatelessWidget {
  const _MorePanel({
    required this.id,
    required this.uid,
    this.message,
    this.fid,
    this.reply,
  });

  final String id;
  final String uid;
  final String? message;
  final String? fid;
  final Datum? reply;

  Future<dynamic> menuActionHandler(PanelAction type,
      {BuildContext? context, String? rid, String? frid}) async {
    switch (type) {
      case PanelAction.copy:
        Get.back();
        Get.toNamed('/copy', parameters: {'text': message.toString()});
        break;
      case PanelAction.block:
        Get.back();
        // todo: block
        SmartDialog.showToast('todo');
        break;
      case PanelAction.report:
        Get.back();
        Utils.report(id, ReportType.Reply);
        break;
      case PanelAction.showReply:
        Get.back();
        showCupertinoModalBottomSheet(
          context: context!,
          builder: (context) {
            return Reply2ReplyPage(
                id: id, replynum: reply!.replynum, originReply: reply!);
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              height: 35,
              child: Container(
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          if (message != null)
            ListTile(
              onTap: () async => await menuActionHandler(PanelAction.copy),
              minLeadingWidth: 0,
              leading: const Icon(Icons.copy, size: 19),
              title:
                  Text('Copy', style: Theme.of(context).textTheme.titleSmall),
            ),
          ListTile(
            onTap: () async => await menuActionHandler(PanelAction.block),
            minLeadingWidth: 0,
            leading: const Icon(Icons.block, size: 19),
            title: Text('Block', style: Theme.of(context).textTheme.titleSmall),
          ),
          if (Utils.isSupportWebview())
            ListTile(
              onTap: () async => await menuActionHandler(PanelAction.report),
              minLeadingWidth: 0,
              leading: const Icon(Icons.error_outline, size: 19),
              title:
                  Text('Report', style: Theme.of(context).textTheme.titleSmall),
            ),
          ListTile(
            onTap: () async => await menuActionHandler(PanelAction.showReply,
                context: context, rid: id, frid: fid),
            minLeadingWidth: 0,
            leading: const Icon(Icons.message_outlined, size: 19),
            title: Text('Show Reply',
                style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
