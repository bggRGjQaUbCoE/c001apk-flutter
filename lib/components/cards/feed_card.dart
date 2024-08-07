import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../components/cards/icon_mini_scroll_card.dart' show miniCardItem;
import '../../components/html_text.dart';
import '../../components/icon_text.dart';
import '../../components/imageview.dart';
import '../../components/no_splash_factory.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.data,
    this.isFeedContent = false,
  });

  final Datum data;
  final bool isFeedContent;

  void _onViewFeed() {
    Get.toNamed('/feed/${data.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          isFeedContent ? null : Theme.of(context).colorScheme.onInverseSurface,
      borderRadius:
          isFeedContent ? null : const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        highlightColor: isFeedContent ? Colors.transparent : null,
        splashColor: isFeedContent ? Colors.transparent : null,
        splashFactory: isFeedContent ? NoSplashFactory() : null,
        onTap: isFeedContent ? null : _onViewFeed,
        onLongPress: () =>
            Get.toNamed('/copy', parameters: {'text': data.message.orEmpty}),
        borderRadius: isFeedContent ? null : BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.only(bottom: isFeedContent ? 12 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(context, data, isFeedContent),
              ..._message(),
              if (!data.picArr.isNullOrEmpty)
                LayoutBuilder(builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  return image(
                    maxWidth,
                    data.picArr!,
                    padding: EdgeInsets.only(
                      left: isFeedContent ? 16 : 10,
                      top: 10,
                      right: isFeedContent ? 16 : 10,
                    ),
                  );
                }),
              if (!data.replyRows.isNullOrEmpty) _hotReply(context),
              bottomInfo(context, data, isFeedContent, _onViewFeed),
              if (data.targetRow != null || !data.relationRows.isNullOrEmpty)
                _rows(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hotReply(BuildContext context) {
    var reply = data.replyRows![0];
    var replyPic = reply.picArr.isNullOrEmpty
        ? ''
        : ''' <a class="feed-forward-pic" href=${reply.pic}>查看图片(${reply.picArr!.length})</a>''';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          onTap: _onViewFeed,
          onLongPress: () =>
              Get.toNamed('/copy', parameters: {'text': reply.message.orEmpty}),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: htmlText(
              """<a class="feed-link-uname" href="/u/${reply.uid}">${reply.userInfo?.username}</a>: ${reply.message}$replyPic""",
              fontSize: 14,
              onShowTotalReply: _onViewFeed,
              picArr: reply.picArr,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rows(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isFeedContent ? 16 : 10,
        top: 10,
        right: isFeedContent ? 16 : 10,
      ),
      child: Wrap(
        spacing: 5.0,
        runSpacing: 5.0,
        children: [
          if (data.targetRow != null)
            miniCardItem(
              context,
              data.targetRow!.logo!.orEmpty,
              data.targetRow!.title.orEmpty,
              data.targetRow!.url.orEmpty,
              isFeedContent ? false : true,
              false,
            ),
          if (!data.relationRows.isNullOrEmpty)
            ...data.relationRows!.map(
              (item) => miniCardItem(
                context,
                item.logo.orEmpty,
                item.title.orEmpty,
                item.url.orEmpty,
                isFeedContent ? false : true,
                false,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _message() {
    return [
      if (!data.messageTitle.isNullOrEmpty)
        Padding(
          padding: EdgeInsets.only(
            left: isFeedContent ? 16 : 10,
            top: 5,
            right: isFeedContent ? 16 : 10,
          ),
          child: htmlText(
            data.messageTitle.orEmpty,
            fontSize: 16,
            isBold: true,
          ),
        ),
      Padding(
        padding: EdgeInsets.only(
          left: isFeedContent ? 16 : 10,
          top: 5,
          right: isFeedContent ? 16 : 10,
        ),
        child: htmlText(
          data.message.orEmpty,
          fontSize: 16,
          onClick: _onViewFeed,
        ),
      )
    ];
  }
}

Widget header(
  BuildContext context,
  Datum data,
  bool isFeedContent,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.only(
            left: isFeedContent ? 16 : 10,
            top: isFeedContent ? 12 : 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: GestureDetector(
                  onTap: () => Get.toNamed('/u/${data.uid}'),
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(data.userAvatar.orEmpty),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.userInfo?.username ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFeedContent || !data.infoHtml.isNullOrEmpty) ...[
                          Text(
                            isFeedContent
                                ? DateUtil.fromToday(data.dateline)
                                : Utils.parseHtmlString(data.infoHtml.orEmpty),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (!data.deviceTitle.isNullOrEmpty)
                          Flexible(
                            flex: 1,
                            child: IconText(
                              icon: Icons.smartphone,
                              text: Utils.parseHtmlString(
                                  data.deviceTitle.orEmpty),
                              onTap: null,
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      if (!isFeedContent && data.isStickTop == 1)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(
              width: 1.25,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: Text(
            '置顶',
            style: TextStyle(
              height: 1,
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            strutStyle: const StrutStyle(
              leading: 0,
              height: 1,
              fontSize: 12,
            ),
          ),
        ),
      if (!isFeedContent)
        IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (context) {
              return _MorePanel(
                id: data.id.toString(),
                uid: data.uid.toString(),
              );
            },
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          color: Theme.of(context).colorScheme.outline,
        ),
    ],
  );
}

Widget bottomInfo(
  BuildContext context,
  Datum data,
  bool isFeedContent,
  Function()? onViewFeed, {
  bool isFeedArticle = false,
}) {
  return Padding(
    padding: EdgeInsets.only(
      left: isFeedContent ? 16 : 10,
      top: isFeedArticle ? 0 : 10,
      right: isFeedContent ? 16 : 10,
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            isFeedContent
                ? !data.ipLocation.isNullOrEmpty
                    ? '发布于 ${data.ipLocation}'
                    : ''
                : DateUtil.fromToday(data.dateline),
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
          onTap: isFeedContent ? null : onViewFeed,
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
    ),
  );
}

enum PanelAction { copy, block, report }

class _MorePanel extends StatelessWidget {
  const _MorePanel({required this.id, required this.uid});

  final String id;
  final String uid;

  Future<dynamic> menuActionHandler(PanelAction type) async {
    switch (type) {
      case PanelAction.copy:
        Utils.copyText('https://www.coolapk.com/feed/$id');
        Get.back();
        break;
      case PanelAction.block:
        Get.back();
        // todo: block
        SmartDialog.showToast('todo');
        break;
      case PanelAction.report:
        Get.back();
        Utils.report(id, ReportType.Feed);
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
          ListTile(
            onTap: () async => await menuActionHandler(PanelAction.copy),
            minLeadingWidth: 0,
            leading: const Icon(Icons.copy_outlined, size: 19),
            title: Text('Copy', style: Theme.of(context).textTheme.titleSmall),
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
        ],
      ),
    );
  }
}
