import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../../components/html_text.dart';
import '../../components/imageview.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.data,
    this.onBlock,
    this.onDelete,
  });

  final Datum data;
  final Function(dynamic uid)? onBlock;
  final Function(dynamic id)? onDelete;

  @override
  Widget build(BuildContext context) {
    final isFollow = data.type == 'contacts_follow';
    return Material(
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: () {
          if (isFollow) {
            Utils.onOpenLink(data.url ?? '');
          } else {
            dom.Document document = parse(data.note);
            String? link = document
                .querySelectorAll('a[href]')
                .firstOrNull
                ?.attributes['href'];
            if (link != null) {
              Utils.onOpenLink(link);
            }
          }
        },
        onLongPress: () =>
            Get.toNamed('/copy', parameters: {'text': data.note ?? ''}),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                            uid: data.fromuid.toString(),
                            note: data.note ?? '',
                            onBlock: onBlock != null
                                ? () => onBlock!(data.uid)
                                : null,
                            onDelete: () {
                              if (onDelete != null) {
                                onDelete!(data.id);
                              }
                            },
                          );
                        },
                      ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.outline,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        Get.toNamed('/u/${data.fromuid ?? data.uid ?? ''}'),
                    child: clipNetworkImage(
                      data.fromUserAvatar ?? '',
                      isAvatar: true,
                      width: 30,
                      height: 30,
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
                        htmlText(data.fromusername ?? ''),
                        htmlText(
                          data.note ?? '',
                          onViewFan: isFollow
                              ? () => Get.toNamed('/u/${data.fromuid}')
                              : null,
                        ),
                        if (!data.picArr.isNullOrEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxWidth = constraints.maxWidth;
                                return image(
                                  maxWidth,
                                  data.picArr!,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          DateUtil.fromToday(data.dateline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
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
}

enum PanelAction { delete, block, report }

class _MorePanel extends StatelessWidget {
  const _MorePanel({
    required this.id,
    required this.uid,
    required this.note,
    required this.onBlock,
    required this.onDelete,
  });

  final String id;
  final String uid;
  final String note;
  final Function()? onBlock;
  final Function()? onDelete;

  Future<dynamic> menuActionHandler(PanelAction type,
      {BuildContext? context, String? rid, String? frid}) async {
    switch (type) {
      case PanelAction.delete:
        Get.back();
        if (onDelete != null) {
          onDelete!();
        }
        break;
      case PanelAction.block:
        Get.back();
        GStorage.onBlock(uid);
        if (onBlock != null) {
          onBlock!();
        }
        break;
      case PanelAction.report:
        Get.back();
        Utils.report(uid, ReportType.User);
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
            onTap: () async => await menuActionHandler(PanelAction.delete),
            minLeadingWidth: 0,
            leading: const Icon(Icons.delete_outline, size: 19),
            title:
                Text('Delete', style: Theme.of(context).textTheme.titleSmall),
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
