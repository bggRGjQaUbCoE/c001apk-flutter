import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/utils.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.data,
    required this.onPM,
  });

  final Datum data;
  final Function(dynamic id)? onPM;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.toNamed('/chat', parameters: {
          'ukey': data.ukey ?? '',
          'uid': data.messageUid.toString(),
          'username': data.messageUsername ?? '',
        });
        if (onPM != null) {
          onPM!(data.id);
        }
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed('/u/${data.messageUid}'),
              child: clipNetworkImage(
                data.messageUserAvatar ?? '',
                isAvatar: true,
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          data.messageUsername ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateUtil.fromToday(data.dateline),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          Utils.parseHtmlString(data.message ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data.unreadNum != null && data.unreadNum != 0)
                        Badge.count(count: data.unreadNum!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
