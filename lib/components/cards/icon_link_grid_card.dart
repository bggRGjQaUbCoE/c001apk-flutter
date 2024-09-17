import 'package:c001apk_flutter/components/network_image.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class IconLinkGridCard extends StatefulWidget {
  const IconLinkGridCard({super.key, required this.dataList});

  final List<Entity> dataList;

  @override
  State<IconLinkGridCard> createState() => _IconLinkGridCardState();
}

class _IconLinkGridCardState extends State<IconLinkGridCard> {
  late int _page;
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _page = widget.dataList.length ~/ 5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpandablePageView.builder(
            controller: _controller,
            itemCount: _page,
            pageSnapping: true,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, page) {
              return Row(
                children: [
                  _iconLinkGridCardItem(widget.dataList[page * 5]),
                  _iconLinkGridCardItem(widget.dataList[page * 5 + 1]),
                  _iconLinkGridCardItem(widget.dataList[page * 5 + 2]),
                  _iconLinkGridCardItem(widget.dataList[page * 5 + 3]),
                  _iconLinkGridCardItem(widget.dataList[page * 5 + 4]),
                ],
              );
            },
          ),
          if (_page != 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_page, (index) {
                  return GestureDetector(
                    onTap: () {
                      _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 255),
                        curve: Curves.ease,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2.5),
                      width: _currentPage == index ? 10 : 7,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        shape: BoxShape.rectangle,
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(128),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _iconLinkGridCardItem(Entity data) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () => Utils.onOpenLink(data.url.orEmpty, data.title),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              networkImage(
                data.pic.orEmpty,
                height: 30,
                width: 30,
                borderRadius: BorderRadius.circular(8),
              ),
              Text(
                data.title.orEmpty,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
