import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../utils/download_util.dart';
import '../../utils/utils.dart';

class ImageViewPage extends StatefulWidget {
  const ImageViewPage({super.key});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  late int _initialPage;
  final _currentPageStream = StreamController<int>();
  late List<String> _imgList;
  late final _pageController = PageController(initialPage: _initialPage);

  @override
  void dispose() {
    _currentPageStream.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    int initialPage = Get.arguments['initialPage'] ?? 0;
    _initialPage = initialPage < 0 ? 0 : initialPage;
    _imgList = Get.arguments['imgList'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          initialData: _initialPage,
          stream: _currentPageStream.stream,
          builder: (_, snapshot) =>
              Text('${snapshot.data! + 1}/${_imgList.length}'),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      clipBehavior: Clip.hardEdge,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text(
                              'Save',
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              DownloadUtils.downloadImg(
                                  [_imgList[_initialPage]]);
                              Get.back();
                            },
                          ),
                          if (_imgList.length != 1)
                            ListTile(
                              title: const Text(
                                'Save All',
                                style: TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                DownloadUtils.downloadImg(_imgList);
                                Get.back();
                              },
                            ),
                          ListTile(
                            title: const Text(
                              'Share',
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              Utils.onShareImg(_imgList[_initialPage]);
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Copy',
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              Utils.copyText(_imgList[_initialPage]);
                              Get.back();
                            },
                          ),
                          if (Utils.isDesktop)
                            ListTile(
                              title: const Text(
                                'Open In Browser',
                                style: TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                Utils.launchURL(_imgList[_initialPage]);
                                Get.back();
                              },
                            ),
                        ],
                      ),
                    );
                  });
            },
            child: PhotoViewGallery.builder(
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(_imgList[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: _imgList[index]),
                );
              },
              itemCount: _imgList.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ),
                ),
              ),
              // backgroundDecoration: widget.backgroundDecoration,
              pageController: _pageController,
              onPageChanged: (index) {
                _initialPage = index;
                _currentPageStream.add(index);
              },
            ),
          ),
          if (Utils.isDesktop && _imgList.length != 1)
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: () {
                  _pageController.animateToPage(
                    _pageController.page!.round() - 1,
                    duration: const Duration(milliseconds: 255),
                    curve: Curves.ease,
                  );
                },
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5)),
              ),
            ),
          if (Utils.isDesktop && _imgList.length != 1)
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () {
                  _pageController.animateToPage(
                    _pageController.page!.round() + 1,
                    duration: const Duration(milliseconds: 255),
                    curve: Curves.ease,
                  );
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }
}
