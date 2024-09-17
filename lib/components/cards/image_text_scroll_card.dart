import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';

import '../../components/cards/title_card.dart';
import '../../components/self_sized_horizontal_list.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class ImageTextScrollCard extends StatelessWidget {
  const ImageTextScrollCard({super.key, required this.data});

  final Datum data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double width = constraints.maxWidth / 3 * 2;
      return Column(
        children: [
          if (!data.title.isNullOrEmpty)
            TitleCard(
              title: data.title.toString(),
              url: data.url ?? '',
              bottomPadding: 10,
            ),
          SelfSizedHorizontalList(
            gapSize: 10,
            padding: null,
            itemCount: data.entities!.length,
            childBuilder: (index) =>
                _imageTextScrollCard(context, width, data.entities![index]),
          ),
        ],
      );
    });
  }

  Widget _imageTextScrollCard(BuildContext context, double width, Entity data) {
    return SizedBox(
      width: width,
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () => Utils.onOpenLink(data.url.orEmpty, data.title),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              clipNetworkImage(
                data.pic.orEmpty,
                width: width,
                height: width / 2.22,
                fit: BoxFit.cover,
                clipBorderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  '${data.title}\n',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
