import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key, required this.data, this.onDownloadApk});

  final Datum data;
  final Function(int, String, int)? onDownloadApk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Map<dynamic, dynamic> arguments = {
                "imgList": [data.logo.toString()],
              };
              Get.toNamed('/imageview', arguments: arguments);
            },
            child: clipNetworkImage(
              data.logo.toString(),
              radius: 18,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '版本: ${data.apkversionname}(${data.apkversioncode})',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '大小: ${data.apksize}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '更新时间: ${data.lastupdate != null ? DateUtil.fromToday(data.lastupdate) : 'null'}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (data.entityType == 'apk')
                      FilledButton.tonal(
                        onPressed: () {
                          if (onDownloadApk != null) {
                            onDownloadApk!(
                              data.id,
                              data.apkversionname ?? '',
                              data.apkversioncode,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          visualDensity: const VisualDensity(
                            horizontal: -2,
                            vertical: -2,
                          ),
                        ),
                        child: const Text('下载'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
