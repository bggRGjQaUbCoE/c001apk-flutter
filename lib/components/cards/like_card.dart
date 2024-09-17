import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/html_text.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/date_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class LikeCard extends StatelessWidget {
  const LikeCard({super.key, required this.data});

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/u/${data.likeUserInfo?.uid ?? ''}'),
                child: clipNetworkImage(
                  data.likeUserInfo?.userAvatar ?? '',
                  isAvatar: true,
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: Text(data.likeUserInfo?.username ?? '')),
              Text(
                DateUtil.fromToday(data.likeTime),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text('赞了你的${data.infoHtml}'),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => Utils.onOpenLink(data.url ?? ''),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (!data.pic.isNullOrEmpty) ...[
                    clipNetworkImage(
                      data.pic!,
                      radius: 8,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
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
                          '@${data.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        htmlText(data.message ?? '', fontSize: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
