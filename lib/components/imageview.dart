import 'dart:math';

import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/nine_grid_view.dart';
import '../constants/constants.dart';
import '../utils/utils.dart';

Widget image(
  double maxWidth,
  List<String> picArr, {
  bool isFeedArticle = false,
  String? articleImg,
}) {
  double imageWidth = (maxWidth - 2 * 5) / 3;
  double imageHeight = imageWidth;
  if (isFeedArticle || picArr.length == 1) {
    List<double> imageLp =
        Utils.getImageLp(isFeedArticle ? articleImg! : picArr[0]);
    double ratioWH = imageLp[0] / imageLp[1];
    double ratioHW = imageLp[1] / imageLp[0];
    double maxRatio = 22 / 9;
    imageWidth = isFeedArticle
        ? maxWidth
        : ratioWH > 1.5
            ? maxWidth
            : (ratioWH >= 1 || (imageLp[1] > imageLp[0] && ratioHW < 1.5))
                ? 2 * imageWidth
                : imageWidth;
    imageHeight = imageWidth * min(ratioHW, maxRatio);
  }
  return NineGridView(
    bigImageWidth: imageWidth,
    bigImageHeight: imageHeight,
    space: 5,
    height: isFeedArticle || picArr.length == 1 ? imageHeight : null,
    width: isFeedArticle || picArr.length == 1 ? imageWidth : maxWidth,
    itemCount: isFeedArticle ? 1 : picArr.length,
    itemBuilder: (context, index) => GestureDetector(
      onTap: () {
        Map<dynamic, dynamic> arguments = {
          "imgList": picArr,
          "initialPage": isFeedArticle
              ? picArr.indexOf(articleImg!)
              : picArr.indexOf(picArr[index]),
        };
        Get.toNamed('/imageview', arguments: arguments);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              networkImage(
                isFeedArticle
                    ? '$articleImg${Constants.SUFFIX_THUMBNAIL}'
                    : '${picArr[index]}${Constants.SUFFIX_THUMBNAIL}',
                width: imageWidth,
                height: imageHeight,
                fit: isFeedArticle || picArr.length == 1
                    ? BoxFit.fill
                    : BoxFit.cover,
              ),
              if ((articleImg ?? picArr[index]).endsWith(Constants.SUFFIX_GIF))
                _badge(context, 'GIF'),
              if (!(articleImg ?? picArr[index])
                      .endsWith(Constants.SUFFIX_GIF) &&
                  _isLongImage(articleImg ?? picArr[index]))
                _badge(context, '长图'),
            ],
          ),
        ),
      ),
    ),
  );
}

bool _isLongImage(String url) {
  List<double> imageLp = Utils.getImageLp(url);
  return imageLp[1] / imageLp[0] >= 22 / 9;
}

Widget _badge(BuildContext context, String title) {
  return Container(
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4)),
    child: Text(
      title,
      style: TextStyle(
        height: 1,
        fontSize: 12,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      strutStyle: const StrutStyle(
        height: 1,
        leading: 0,
        fontSize: 12,
      ),
    ),
  );
}
