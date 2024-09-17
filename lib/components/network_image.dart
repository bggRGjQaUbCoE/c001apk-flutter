import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget networkImage(
  String imageUrl, {
  BoxFit? fit,
  double? width,
  double? height,
  bool isAvatar = false,
  ImageWidgetBuilder? imageBuilder,
  BorderRadiusGeometry? borderRadius =
      const BorderRadius.all(Radius.circular(12)),
}) {
  Widget placeHolder(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.25),
        borderRadius: borderRadius,
      ),
      child: Icon(
        isAvatar ? Icons.person : Icons.all_inclusive,
        color: Theme.of(context).colorScheme.outline,
        size: width != null && width < 35
            ? width - 5
            : width != null && width < 70
                ? width - 10
                : 45,
      ),
    );
  }

  return CachedNetworkImage(
    fit: fit,
    width: width,
    height: height,
    imageUrl: imageUrl,
    imageBuilder: imageBuilder,
    placeholder: (context, url) => placeHolder(context),
    errorWidget: (context, url, error) => placeHolder(context),
    fadeOutDuration: const Duration(milliseconds: 200),
    fadeInDuration: const Duration(milliseconds: 200),
  );
}

Widget clipNetworkImage(
  String imageUrl, {
  BoxFit? fit,
  double? radius,
  double? width,
  double? height,
  bool isAvatar = false,
  ImageWidgetBuilder? imageBuilder,
  BorderRadiusGeometry? clipBorderRadius,
}) {
  return ClipRRect(
    borderRadius:
        clipBorderRadius ?? BorderRadius.circular(isAvatar ? 50 : radius ?? 12),
    child: networkImage(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      isAvatar: isAvatar,
      imageBuilder: imageBuilder,
      borderRadius: null,
    ),
  );
}
