import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../pages/carousel/carousel_page.dart';
import '../../../pages/home/topic/controller.dart';
import '../../../pages/home/home_page.dart' show TabType;

class HomeTopicPage extends StatefulWidget {
  const HomeTopicPage({super.key, required this.tabType});

  final TabType tabType;

  @override
  State<HomeTopicPage> createState() => _HomeTopicPageState();
}

class _HomeTopicPageState extends State<HomeTopicPage> {
  late HomeTopicController _homeTopicController;
  late int _currentIndex;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabType == TabType.TOPIC ? 1 : 0;
    _controller = PageController(initialPage: _currentIndex);
    _homeTopicController = Get.put(
      HomeTopicController(tabType: widget.tabType),
      tag: widget.tabType.name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    Get.delete<HomeTopicController>(
      tag: widget.tabType.name,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _homeTopicController.obx(
      (data) {
        return Row(
          children: [
            Expanded(
              flex: 22,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: widget.tabType == TabType.TOPIC
                    ? data![0].entities!.length
                    : data!.length,
                itemBuilder: (context, index) => IntrinsicHeight(
                  child: InkWell(
                    onTap: () {
                      setState(() => _currentIndex = index);
                      _controller.jumpToPage(index);
                    },
                    child: Ink(
                      color: index == _currentIndex
                          ? Theme.of(context).colorScheme.onInverseSurface
                          : Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: double.infinity,
                            width: 3,
                            color: index == _currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                widget.tabType == TabType.TOPIC
                                    ? data[0].entities![index].title.toString()
                                    : data[index].title.toString(),
                                style: TextStyle(
                                  color: index == _currentIndex
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 78,
              child: Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.tabType == TabType.TOPIC
                      ? data[0].entities!.length
                      : data.length,
                  itemBuilder: (context, index) => CarouselPage(
                    isInit: false,
                    url: widget.tabType == TabType.TOPIC
                        ? data[0].entities![index].url
                        : data[index].url,
                    title: widget.tabType == TabType.TOPIC
                        ? data[0].entities![index].title
                        : data[index].title,
                    isHomeCard: true,
                  ),
                ),
              ),
            )
          ],
        );
      },
      onEmpty: GestureDetector(
        onTap: _homeTopicController.onReload,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: const Text('EMPTY'),
        ),
      ),
      onError: (error) => GestureDetector(
        onTap: _homeTopicController.onReload,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: Text(error ?? 'unknown error'),
        ),
      ),
    );
  }
}
