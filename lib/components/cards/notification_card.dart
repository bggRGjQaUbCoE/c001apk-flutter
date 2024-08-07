import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../../components/html_text.dart';
import '../../components/imageview.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.data,
  });

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: InkWell(
        onTap: () {
          dom.Document document = parse(data.note);
          String? link = document
              .querySelectorAll('a[href]')
              .firstOrNull
              ?.attributes['href'];
          if (link != null) {
            Utils.onOpenLink(link);
          }
        },
        onLongPress: () {
          // todo delete
        },
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
                            note: data.note ?? '',
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
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/u/${data.uid}'),
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          data.fromUserAvatar ?? '',
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
                        htmlText(data.fromusername ?? ''),
                        htmlText(data.note ?? ''),
                        if (!data.picArr.isNullOrEmpty)
                          LayoutBuilder(builder: (context, constraints) {
                            double maxWidth = constraints.maxWidth;
                            return image(
                              maxWidth,
                              data.picArr!,
                              padding: const EdgeInsets.only(top: 10),
                            );
                          }),
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

enum PanelAction { copy, block, report }

class _MorePanel extends StatelessWidget {
  const _MorePanel({
    required this.id,
    required this.note,
  });

  final String id;
  final String note;

  Future<dynamic> menuActionHandler(PanelAction type,
      {BuildContext? context, String? rid, String? frid}) async {
    switch (type) {
      case PanelAction.copy:
        Get.back();
        Get.toNamed('/copy', parameters: {'text': note});
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
            leading: const Icon(Icons.copy, size: 19),
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
