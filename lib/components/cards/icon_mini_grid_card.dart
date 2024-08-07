import 'package:flutter/material.dart';

import '../../components/cards/icon_mini_scroll_card.dart' show miniCardItem;
import '../../components/cards/title_card.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';

class IconMiniGridCard extends StatelessWidget {
  const IconMiniGridCard({super.key, required this.data});

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!data.title.isNullOrEmpty)
              TitleCard(
                title: data.title.toString(),
                url: data.url ?? '',
                bottomPadding: 5,
              ),
            ...List<int>.generate(data.entities!.length ~/ 2, (index) => index)
                .map((index) => _miniGridCardItem(
                      context,
                      data.entities![index * 2],
                      data.entities![index * 2 + 1],
                    )),
          ],
        ),
      ),
    );
  }

  Widget _miniGridCardItem(BuildContext context, Entity data1, Entity data2) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: miniCardItem(
            context,
            data1.logo.orEmpty,
            data1.title.orEmpty,
            data1.url.orEmpty,
            false,
            true,
            paddingH: 10,
          ),
        ),
        Expanded(
          flex: 1,
          child: miniCardItem(
            context,
            data2.logo.orEmpty,
            data2.title.orEmpty,
            data2.url.orEmpty,
            false,
            true,
            paddingH: 10,
          ),
        ),
      ],
    );
  }
}
