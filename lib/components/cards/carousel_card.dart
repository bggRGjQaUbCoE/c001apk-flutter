import 'dart:async';

import 'package:c001apk_flutter/components/network_image.dart';
import 'package:flutter/material.dart';

import '../../logic/model/feed/entity.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

class CarouselCard extends StatefulWidget {
  const CarouselCard({super.key, required this.dataList});

  final List<Entity> dataList;

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  int _currentPage = 0;
  late List<Entity> _filterList;
  late PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _filterList = widget.dataList.where((item) {
      return item.url?.startsWith('http') == false;
    }).toList();

    if (_filterList.length != 1) {
      _filterList.insert(0, _filterList.last);
      _filterList.add(_filterList[1]);
    }

    _controller = PageController(initialPage: _filterList.length == 1 ? 0 : 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _filterList.length,
              pageSnapping: true,
              onPageChanged: (index) async {
                if (_filterList.length != 1) {
                  if (index == _filterList.length - 1) {
                    _timer?.cancel();
                    _timer = Timer(const Duration(milliseconds: 500), () {
                      _controller.jumpToPage(1);
                    });
                  } else if (index == 0) {
                    _timer?.cancel();
                    _timer = Timer(const Duration(milliseconds: 500), () {
                      _controller.jumpToPage(_filterList.length - 2);
                    });
                  } else {
                    _timer?.cancel();
                  }
                  setState(() => _currentPage = _filterList.length == 1
                      ? index
                      : index == 0
                          ? _filterList.length - 3
                          : index == _filterList.length - 1
                              ? 0
                              : index - 1);
                }
              },
              itemBuilder: (context, page) {
                return GestureDetector(
                  onTap: () => Utils.onOpenLink(
                    _filterList[page].url.orEmpty,
                    _filterList[page].title,
                  ),
                  child: networkImage(
                    _filterList[page].pic.orEmpty,
                    fit: BoxFit.cover,
                    borderRadius: null,
                  ),
                );
              },
            ),
            if (_filterList.length != 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 5, right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      _filterList.length == 1 ? 1 : _filterList.length - 2,
                      (index) {
                    return GestureDetector(
                      onTap: () {
                        _controller.animateToPage(
                          index + 1,
                          duration: const Duration(milliseconds: 255),
                          curve: Curves.ease,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withAlpha(128),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
