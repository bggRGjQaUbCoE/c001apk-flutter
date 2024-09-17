import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../components/html_text.dart';
import '../../components/imageview.dart';
import '../../components/like_button.dart';
import '../../logic/model/feed/datum.dart';
import '../../pages/feed/reply2reply/reply_2_reply_page.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class FeedReplyCard extends StatelessWidget {
  const FeedReplyCard({
    super.key,
    required this.data,
    this.isReply2Reply = false,
    this.isTopReply = false,
    this.uid,
    this.onBlock,
    this.onReply,
    this.onDelete,
    this.onLike,
  });

  final Datum data;
  final bool isReply2Reply;
  final bool isTopReply;
  final dynamic uid;
  final Function(dynamic uid, dynamic id)? onBlock;
  final Function(dynamic id, dynamic uname, dynamic fid)? onReply;
  final Function(dynamic id, dynamic fid)? onDelete;
  final Function(dynamic id, dynamic like)? onLike;

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
          if (isFeedReply && onReply != null) {
            onReply!(
              data.id,
              data.userInfo?.username,
              null,
            );
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
                            id: data.id,
                            uid: data.uid,
                            reply: data..fetchType = 'feed_reply',
                            onBlock: onBlock != null
                                ? () => onBlock!(data.uid, null)
                                : null,
                            onDelete: onDelete != null
                                ? () => onDelete!(data.id, null)
                                : null,
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
                  GestureDetector(
                    onTap: () => Get.toNamed('/u/${data.uid}'),
                    child: clipNetworkImage(
                      data.userAvatar ?? '',
                      isAvatar: true,
                      height: 30,
                      width: 30,
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
                            (!data.replyRows.isNullOrEmpty ||
                                (data.replyRowsMore ?? 0) != 0)) ...[
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
            ? '${data.userInfo?.username}${data.uid == data.feedUid ? ' [楼主]' : ''}${!isReply2Reply && isTopReply ? ' [置顶]' : ''}'
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
                clipNetworkImage(
                  feed.pic!,
                  radius: 8,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
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
        if (onReply != null) {
          onReply!(
            reply.id,
            reply.userInfo?.username,
            data.id,
          );
        }
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (context) {
            return _MorePanel(
              id: reply.id,
              uid: reply.uid,
              message: reply.message.toString(),
              fid: data.id,
              reply: reply,
              onBlock:
                  onBlock != null ? () => onBlock!(reply.uid, data.id) : null,
              onDelete:
                  onDelete != null ? () => onDelete!(reply.id, data.id) : null,
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
        LikeButton(
          value: data.replynum,
          icon: Icons.message_outlined,
        ),
        LikeButton(
          value: data.likenum,
          icon: data.userAction?.like == 1
              ? Icons.thumb_up
              : Icons.thumb_up_alt_outlined,
          isLike: data.userAction?.like == 1,
          onClick: () {
            if (GlobalData().isLogin && onLike != null) {
              onLike!(data.id, data.userAction?.like);
            }
          },
        ),
      ],
    );
  }
}

enum PanelAction { copy, block, delete, report, showReply }

class _MorePanel extends StatelessWidget {
  const _MorePanel({
    required this.id,
    required this.uid,
    this.message,
    this.fid,
    this.reply,
    this.onBlock,
    this.onDelete,
  });

  final dynamic id;
  final dynamic uid;
  final String? message;
  final dynamic fid;
  final Datum? reply;
  final Function()? onBlock;
  final Function()? onDelete;

  Future<dynamic> menuActionHandler(PanelAction type,
      {BuildContext? context, dynamic rid, dynamic frid}) async {
    switch (type) {
      case PanelAction.copy:
        Get.back();
        Get.toNamed('/copy', parameters: {'text': message.toString()});
        break;
      case PanelAction.block:
        Get.back();
        GStorage.onBlock(uid);
        if (onBlock != null) {
          onBlock!();
        }
        break;
      case PanelAction.delete:
        Get.back();
        if (onDelete != null) {
          onDelete!();
        }
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
                id: id.toString(),
                replynum: reply!.replynum,
                originReply: reply!);
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
          if (uid.toString() == GlobalData().uid)
            ListTile(
              onTap: () async => await menuActionHandler(PanelAction.delete),
              minLeadingWidth: 0,
              leading: const Icon(Icons.delete_outline, size: 19),
              title:
                  Text('Delete', style: Theme.of(context).textTheme.titleSmall),
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
