import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';

import '../../components/self_sized_horizontal_list.dart';
import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class IconMiniScrollCard extends StatelessWidget {
  const IconMiniScrollCard({super.key, required this.dataList});

  final List<Entity> dataList;

  @override
  Widget build(BuildContext context) {
    return SelfSizedHorizontalList(
      gapSize: 10,
      padding: null,
      itemCount: dataList.length,
      childBuilder: (index) {
        return miniCardItem(
          context,
          dataList[index].logo ?? dataList[index].pic.orEmpty,
          dataList[index].title.orEmpty,
          dataList[index].url.orEmpty,
          false,
          false,
        );
      },
    );
  }
}

Widget miniCardItem(
  BuildContext context,
  String logo,
  String title,
  String url,
  bool isSurface,
  bool isGrid, {
  double paddingH = 6,
}) {
  double radius = isGrid ? 0.0 : 8.0;
  return Material(
    color: isSurface
        ? Theme.of(context).colorScheme.surface
        : isGrid
            ? Colors.transparent
            : Theme.of(context).colorScheme.onInverseSurface,
    borderRadius: BorderRadius.circular(radius),
    child: InkWell(
      onTap: () => Utils.onOpenLink(url, title),
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            clipNetworkImage(
              logo,
              radius: 4,
              height: 18,
              width: 18,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 4),
            Flexible(
              flex: 1,
              child: Text(
                title,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
