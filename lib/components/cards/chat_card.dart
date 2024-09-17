import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/html_text.dart';
import '../../components/no_splash_factory.dart';
import '../../logic/model/feed/datum.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.data,
    required this.isLeft,
    required this.onGetImageUrl,
    required this.onLongPress,
    required this.onViewImage,
  });

  final Datum data;
  final bool isLeft;
  final Function() onGetImageUrl;
  final Function() onLongPress;
  final Function() onViewImage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth - 142;
      return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplashFactory(),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment:
                isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLeft) ...[
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/u/${data.messageUid}');
                  },
                  child: clipNetworkImage(
                    data.fromUserAvatar ?? '',
                    isAvatar: true,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (!data.message.isNullOrEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLeft
                          ? Theme.of(context).colorScheme.onInverseSurface
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: isLeft
                            ? const Radius.circular(4)
                            : const Radius.circular(12),
                        topRight: isLeft
                            ? const Radius.circular(12)
                            : const Radius.circular(4),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: htmlText(data.message!),
                  ),
                ),
              if (!data.messagePic.isNullOrEmpty)
                _chatImage(context, maxWidth / 2),
              if (!isLeft) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/u/${data.fromuid}');
                  },
                  child: clipNetworkImage(
                    data.fromUserAvatar ?? '',
                    isAvatar: true,
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _chatImage(BuildContext context, double width) {
    if (data.messagePic!.startsWith('http')) {
      List<double> imageLp =
          Utils.getImageLp(data.messagePic!.split('?').first);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        width: width,
        height: width * imageLp[1] / imageLp[0],
        child: GestureDetector(
          onTap: onViewImage,
          child: clipNetworkImage(
            data.messagePic!,
            radius: 12,
            fit: BoxFit.fill,
          ),
        ),
      );
    } else {
      onGetImageUrl();
      List<double> imageLp = Utils.getImageLp(data.messagePic!);
      return Container(
        width: width,
        height: width * imageLp[1] / imageLp[0],
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.onInverseSurface,
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
      );
    }
  }
}
