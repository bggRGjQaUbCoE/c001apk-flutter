import 'package:flutter/material.dart' hide CarouselController;
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/carousel/carousel_controller.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({
    super.key,
    this.isInit,
    this.url,
    this.title,
    this.isHomeCard = false,
  });

  final bool? isInit;
  final String? url;
  final String? title;
  final bool isHomeCard;

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage>
    with TickerProviderStateMixin {
  late bool _isInit;
  late String _url;
  late String _title;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _isInit = widget.isInit ?? Get.parameters['isInit'] == '1';
    _url = widget.url ?? Get.parameters['url'] ?? '';
    _title = widget.title ?? Get.parameters['title'] ?? '';
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: _url + _title,
      init: CarouselController(isInit: _isInit, url: _url, title: _title)
        ..tabSize.listen((size) {
          _tabController = TabController(length: size, vsync: this);
        }),
      dispose: (state) {
        state.controller?.scrollController?.dispose();
      },
      builder: (controller) => Obx(
        () => controller.loadingState.value is Success
            ? _isInit
                ? Scaffold(
                    appBar: AppBar(
                      title: Text(controller.pageTitle ?? _title),
                      bottom: controller.iconTabLinkGridCard == null
                          ? const PreferredSize(
                              preferredSize: Size.zero,
                              child: Divider(height: 1),
                            )
                          : TabBar(
                              isScrollable: true,
                              controller: _tabController,
                              tabs: controller.iconTabLinkGridCard!.entities!
                                  .map((item) => Tab(text: item.title))
                                  .toList()),
                    ),
                    body: controller.iconTabLinkGridCard == null
                        ? commonBody(
                            controller,
                            isHomeCard: widget.isHomeCard,
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: controller.iconTabLinkGridCard!.entities!
                                .map(
                                  (item) => CarouselPage(
                                    isInit: false,
                                    url: item.url,
                                    title: item.title,
                                  ),
                                )
                                .toList()),
                  )
                : commonBody(
                    controller,
                    isHomeCard: widget.isHomeCard,
                  )
            : _isInit
                ? Scaffold(
                    appBar: AppBar(),
                    body: Center(
                      child: commonBody(
                        controller,
                        isHomeCard: widget.isHomeCard,
                      ),
                    ),
                  )
                : Center(
                    child: commonBody(
                      controller,
                      isHomeCard: widget.isHomeCard,
                    ),
                  ),
      ),
    );
  }
}
