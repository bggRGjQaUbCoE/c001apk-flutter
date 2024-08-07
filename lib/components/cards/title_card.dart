import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
    required this.title,
    required this.url,
    this.bottomPadding = 0,
  });

  final String title;
  final String url;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: bottomPadding),
      child: GestureDetector(
        onTap: () {
          if (url.isNotEmpty) {
            Utils.onOpenLink(url, title);
          }
        },
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (url.isNotEmpty)
              Icon(
                Icons.keyboard_arrow_right_outlined,
                color: Theme.of(context).colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}
