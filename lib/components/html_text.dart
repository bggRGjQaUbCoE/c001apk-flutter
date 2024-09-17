import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import '../utils/emoji_util.dart';
import '../utils/extensions.dart';
import '../utils/storage_util.dart';
import '../utils/utils.dart';

Widget htmlText(
  String html, {
  double fontSize = 15,
  bool isBold = false,
  List<String>? picArr,
  Function? onClick,
  Function? onShowTotalReply,
  Function? onViewFan,
}) {
  String? htmlConvert;
  if (GStorage.showEmoji) {
    RegExp regExp = RegExp('\\[[^\\]]+\\]');
    htmlConvert = html.replaceAll('\n', '<br/>').replaceAllMapped(
      regExp,
      (match) {
        String matchedString = match.group(0) ?? '';
        String? src = EmojiUtil.emojiMap[matchedString];
        if (!src.isNullOrEmpty) {
          return '<img src="$src">';
        } else {
          return matchedString;
        }
      },
    );
  }

  return HtmlWidget(
    htmlConvert ?? html,
    onTapUrl: (url) {
      if (url.isEmpty) {
        if (onClick != null) {
          onClick();
        }
      } else if (url.contains('/feed/replyList')) {
        if (onShowTotalReply != null) {
          onShowTotalReply();
        }
      } else if (url.contains('image.coolapk.com')) {
        Map<dynamic, dynamic> arguments = {
          "imgList": !picArr.isNullOrEmpty ? picArr : [url],
        };
        Get.toNamed('/imageview', arguments: arguments);
      } else if (url == '/contacts/fans') {
        if (onViewFan != null) {
          onViewFan();
        }
      } else {
        Utils.onOpenLink(url, null);
      }
      return true;
    },
    textStyle: TextStyle(
      fontSize: fontSize,
      height: 1.5,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    ),
    customStylesBuilder: (element) {
      switch (element.localName) {
        case 'a':
          return {'text-decoration': 'none'};
      }
      return null;
    },
    customWidgetBuilder: (element) {
      switch (element.localName) {
        case 'img':
          {
            double size =
                MediaQuery.of(Get.context!).textScaler.scale(fontSize);
            String src = element.attributes['src'] ?? '';
            return InlineCustomWidget(
              alignment: PlaceholderAlignment.middle,
              child: src.endsWith('icon')
                  ? Icon(
                      size: size * 1.3,
                      Icons.photo_outlined,
                      color: Theme.of(Get.context!).colorScheme.primary,
                    )
                  : src.endsWith('png')
                      ? Image.asset(
                          'assets/emojis/$src',
                          width: size * 1.3,
                          height: size * 1.3,
                        )
                      : src.startsWith('http')
                          ? networkImage(
                              src,
                              width: size * 1.3,
                              height: size * 1.3,
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(Get.context!)
                                      .colorScheme
                                      .primary,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Text(
                                src,
                                style: TextStyle(
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize - 4,
                                  color: Theme.of(Get.context!)
                                      .colorScheme
                                      .primary,
                                ),
                                strutStyle: StrutStyle(
                                  height: 1,
                                  leading: 0,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize - 4,
                                ),
                              ),
                            ),
            );
          }
      }
      return null;
    },
  );
}
