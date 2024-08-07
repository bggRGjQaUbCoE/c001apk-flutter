import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../components/self_sized_horizontal_list.dart';
import '../../logic/model/feed/entity.dart';
import '../../utils/utils.dart';

class ImageSquareScrollCard extends StatelessWidget {
  const ImageSquareScrollCard({super.key, required this.dataList});

  final List<Entity> dataList;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = (constraints.maxWidth - 40) / 5;
      return SelfSizedHorizontalList(
        gapSize: 10,
        padding: null,
        itemCount: dataList.length,
        childBuilder: (index) => _imageSquareScrollCardItem(
          width,
          dataList[index],
        ),
      );
    });
  }

  Widget _imageSquareScrollCardItem(double width, Entity data) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: SizedBox(
        width: width,
        height: width,
        child: GestureDetector(
          onTap: () => Utils.onOpenLink(data.url.toString(), data.title),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: data.pic.toString(),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Color(0x8D000000),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Center(
                child: Text(
                  data.title.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFFEEEEEE)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
