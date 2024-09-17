import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/check_update/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class AppUpdateCard extends StatefulWidget {
  const AppUpdateCard({
    super.key,
    required this.data,
    required this.versionName,
    required this.versionCode,
  });

  final Datum data;
  final String? versionName;
  final String? versionCode;

  @override
  State<StatefulWidget> createState() => _AppUpdateCardState();
}

class _AppUpdateCardState extends State<AppUpdateCard> {
  int _maxLines = 2;
  String? _url;
  late final _name =
      '${widget.data.title}-${widget.data.apkversionname}-${widget.data.apkversioncode}.apk';

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: Alignment.topCenter,
      curve: Curves.linearToEaseOut,
      duration: const Duration(milliseconds: 500),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () => Get.toNamed('/apk/${widget.data.packageName}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                clipNetworkImage(
                  widget.data.logo.orEmpty,
                  radius: 8,
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.data.title.orEmpty,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.data.pkgBitType == 1
                                          ? '32位'
                                          : [
                                              2,
                                              3
                                            ].contains(widget.data.pkgBitType)
                                              ? '64位'
                                              : '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${widget.versionName}(${widget.versionCode}) > ${widget.data.apkversionname}(${widget.data.apkversioncode})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              if (!_url.isNullOrEmpty) {
                                Utils.onDownloadFile(_url!, _name);
                              } else {
                                _url = await Utils.onGetDownloadUrl(
                                  widget.data.title!,
                                  widget.data.packageName!,
                                  widget.data.id!,
                                  widget.data.apkversionname!,
                                  widget.data.apkversioncode!,
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              visualDensity: const VisualDensity(
                                  horizontal: -2, vertical: -2),
                            ),
                            child: const Text('下载'),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateUtil.fromToday(widget.data.lastupdate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.data.apksize.orEmpty,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(
                            () => _maxLines = _maxLines == 2 ? 999 : 2),
                        child: Text(
                          widget.data.changelog ?? 'no changelog',
                          maxLines: _maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
