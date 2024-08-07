import 'package:flutter/material.dart';

import '../../components/cards/message_first_card.dart'
    show messageFirstCardRow;

Widget messageSeconfCard(BuildContext context) {
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
            Icons.star_border,
            Icons.favorite_border,
            Icons.messenger_outline,
          ],
        ),
      ],
    ),
  );
}
