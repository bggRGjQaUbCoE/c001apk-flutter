import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/nine_grid_view.dart';
import '../../utils/utils.dart';

Widget image(
  double maxWidth,
  List<String> picArr, {
  EdgeInsets padding = EdgeInsets.zero,
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
    padding: padding,
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
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            width: imageWidth,
            height: imageHeight,
            imageUrl:
                isFeedArticle ? '$articleImg.s.jpg' : '${picArr[index]}.s.jpg',
            fit: picArr.length == 1 ? BoxFit.fill : BoxFit.cover,
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
    ),
  );
}
