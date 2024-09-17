import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../pages/ffflist/ffflist_page.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.data});

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed('ffflist', arguments: {
        'id': data.id.toString(),
        'title': data.title,
        'type': FFFListType.COLLECTION_ITEM,
      }),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            clipNetworkImage(
              data.coverPic ?? '',
              radius: 8,
              width: 53,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title ?? ''),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      child: Row(
                        children: [
                          Text(data.isOpenTitle ?? ''),
                          const SizedBox(width: 10),
                          Text('${data.followNum}人关注'),
                          const SizedBox(width: 10),
                          Text('${data.itemNum}个内容'),
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
