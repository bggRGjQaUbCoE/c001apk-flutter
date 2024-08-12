import 'package:flutter/material.dart';

import '../../../utils/emoji_util.dart';

class EmotePanel extends StatelessWidget {
  const EmotePanel({super.key, required this.index, required this.onClick});
  final int index;
  final Function(String emoji) onClick;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10 + MediaQuery.of(context).padding.bottom),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      children: (EmojiUtil.emojiMap.keys.toList()..removeRange(0, 4))
          .map(
            (emoji) => Material(
              child: InkWell(
                onTap: () => onClick(emoji),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  padding: const EdgeInsets.all(8),
                  child:
                      Image.asset('assets/emojis/${EmojiUtil.emojiMap[emoji]}'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
