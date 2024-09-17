import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';

import '../../components/cards/title_card.dart';
import '../../components/self_sized_horizontal_list.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class IconScrollCard extends StatelessWidget {
  const IconScrollCard({super.key, required this.data});

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = (constraints.maxWidth - 55) / 4.5;
      return Ink(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!data.title.isNullOrEmpty)
              TitleCard(
                title: data.title.toString(),
                url: data.url ?? '',
                bottomPadding: 5,
              ),
            SelfSizedHorizontalList(
              gapSize: 0,
              itemCount: data.entities!.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              childBuilder: (index) =>
                  _scrollCardItem(width, data.entities![index]),
            )
          ],
        ),
      );
    });
  }

  Widget _scrollCardItem(double width, Entity data) {
    return InkWell(
      onTap: () => Utils.onOpenLink(data.url.orEmpty, data.title),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        margin: const EdgeInsets.all(5),
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            clipNetworkImage(
              data.userAvatar.orEmpty,
              isAvatar: true,
              width: width - 10,
              height: width - 10,
            ),
            const SizedBox(height: 5),
            Text(
              data.username.orEmpty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
