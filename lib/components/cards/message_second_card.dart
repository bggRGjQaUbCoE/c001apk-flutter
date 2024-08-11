import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/cards/message_first_card.dart'
    show messageFirstCardRow;
import '../../pages/history/history_page.dart' show HistoryType;
import '../../pages/ffflist/ffflist_page.dart' show FFFListType;

Widget messageSeconfCard(bool isLogin, BuildContext context) {
  return Material(
    clipBehavior: Clip.hardEdge,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    color: Theme.of(context).colorScheme.onInverseSurface,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        messageFirstCardRow(
          context,
          null,
          [
            '本地收藏',
            '浏览历史',
            '我的常去',
          ],
          [
            () => Get.toNamed(
                  '/history',
                  arguments: {'type': HistoryType.Favorite},
                ),
            () => Get.toNamed(
                  '/history',
                  arguments: {'type': HistoryType.History},
                ),
            isLogin
                ? () => Get.toNamed(
                      '/ffflist',
                      arguments: {'type': FFFListType.RECENT},
                    )
                : () {},
          ],
          [
            Icons.archive_outlined,
            Icons.history,
            Icons.my_location,
          ],
        ),
        messageFirstCardRow(
          context,
          null,
          [
            '我的收藏',
            '我的赞',
            '我的回复',
          ],
          [
            isLogin
                ? () => Get.toNamed(
                      '/ffflist',
                      arguments: {'type': FFFListType.COLLECTION},
                    )
                : () {},
            isLogin
                ? () => Get.toNamed(
                      '/ffflist',
                      arguments: {'type': FFFListType.LIKE},
                    )
                : () {},
            isLogin
                ? () => Get.toNamed(
                      '/ffflist',
                      arguments: {'type': FFFListType.REPLY},
                    )
                : () {},
          ],
          [
            Icons.star_border,
            Icons.favorite_border,
            Icons.messenger_outline,
          ],
        ),
      ],
    ),
  );
}
