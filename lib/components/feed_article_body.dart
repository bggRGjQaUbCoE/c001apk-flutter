import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../components/html_text.dart';
import '../components/imageview.dart';
import '../logic/model/feed_article/feed_article.dart';
import '../utils/extensions.dart';
import '../utils/utils.dart';

Widget feedArticleBody(
  double maxWidth,
  FeedArticle data,
  List<String> picArr,
) {
  switch (data.type) {
    case 'title':
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: htmlText(
          data.title.orEmpty,
          fontSize: 17,
          isBold: true,
        ),
      );
    case 'text':
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onLongPress: () {
            Get.toNamed('/copy', parameters: {'text': data.message.orEmpty});
            HapticFeedback.mediumImpact();
          },
          child: htmlText(
            data.message.orEmpty,
            fontSize: 16,
          ),
        ),
      );
    case 'image':
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            image(
              maxWidth - 32,
              picArr,
              isFeedArticle: true,
              articleImg: data.url.orEmpty,
            ),
            if (!data.description.isNullOrEmpty)
              Text(
                data.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(Get.context!).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              )
          ],
        ),
      );
    case 'shareUrl':
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: () => Utils.onOpenLink(data.url.orEmpty),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Ink(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Theme.of(Get.context!).colorScheme.onInverseSurface,
            ),
            padding: const EdgeInsets.all(10),
            child: Text(data.title.orEmpty),
          ),
        ),
      );
  }
  return const SizedBox();
}
