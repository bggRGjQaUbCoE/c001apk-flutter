import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/footer.dart';
import '../../components/item_card.dart';
import '../../constants/constants.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';

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

  Datum? iconTabLinkGridCard;
  bool _checked = false;

  TabController? _tabController;

  LoadingState? _loadingState = LoadingState.loading();
  LoadingState? _footerState = LoadingState.loading();

  String? _firstItem;
  String? _lastItem;
  int _page = 1;

  bool _isEnd = false;
  bool _isLoading = false;

  String? _pageTitle;

  @override
  void initState() {
    super.initState();

    _isInit = widget.isInit ?? Get.parameters['isInit'] == '1';
    _url = widget.url ?? Get.parameters['url'] ?? '';
    _title = widget.title ?? Get.parameters['title'] ?? '';

    _onGetData(true);
  }

  @override
  void dispose() {
    _loadingState = null;
    _footerState = null;
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _onGetData([bool isRefresh = false]) async {
    if (!_isLoading) {
      _isLoading = true;
      LoadingState response = await NetworkRepo.getDataList(
        url: _url,
        title: _title,
        subTitle: '',
        firstItem: _firstItem,
        lastItem: _lastItem,
        page: _page,
      );
      if (response is Success) {
        _page++;
        List<Datum> originList = response.response as List<Datum>;
        if (!_checked) {
          _checked = true;
          iconTabLinkGridCard = originList.firstWhereOrNull(
              (item) => item.entityTemplate == 'iconTabLinkGridCard');
          if (iconTabLinkGridCard != null) {
            _tabController = TabController(
              vsync: this,
              length: iconTabLinkGridCard!.entities!.length,
            );
          }
          _pageTitle = originList.lastOrNull?.extraDataArr?.pageTitle;
        }
        _firstItem = originList.firstOrNull?.id.toString();
        _lastItem = originList.lastOrNull?.id.toString();
        List<Datum> filterList = originList.where((item) {
          return Constants.entityTypeList.contains(item.entityType) ||
              Constants.entityTemplateList.contains(item.entityTemplate);
        }).toList();
        setState(() {
          _loadingState = LoadingState.success(
              isRefresh || _loadingState is! Success
                  ? filterList
                  : ((_loadingState as Success).response + filterList));
          _footerState = LoadingState.loading();
        });
      } else {
        _isEnd = true;
        if (isRefresh) {
          setState(() => _loadingState = response);
        } else {
          setState(() => _footerState = response);
        }
      }
      _isLoading = false;
    }
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _firstItem = null;
    _lastItem = null;
    await _onGetData(true);
  }

  Widget _buildBody(LoadingState loadingState) {
    switch (loadingState) {
      case Empty():
        return GestureDetector(
          onTap: () {
            setState(() => _loadingState = LoadingState.loading());
            _onRefresh();
          },
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: () {
            setState(() => _loadingState = LoadingState.loading());
            _onRefresh();
          },
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(loadingState.errMsg),
          ),
        );
      case Success():
        List<Datum> dataList = loadingState.response as List<Datum>;
        return ListView.separated(
          // controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom),
          itemCount: dataList.length + 1,
          itemBuilder: (_, index) {
            if (index == dataList.length) {
              if (!_isEnd && !_isLoading) {
                _onGetData();
              }
              return footerWidget(_footerState!, () {
                _isEnd = false;
                setState(() => _footerState = LoadingState.loading());
                _onGetData();
              });
            } else {
              return itemCard(
                dataList[index],
                isHomeCard: widget.isHomeCard,
              );
            }
          },
          separatorBuilder: (_, index) => const SizedBox(height: 10),
        );
    }
    return Container(
      height: 80,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10.0),
      child: const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loadingState is Success
        ? _isInit
            ? Scaffold(
                appBar: AppBar(
                  title: Text(_pageTitle ?? _title),
                  bottom: iconTabLinkGridCard == null
                      ? const PreferredSize(
                          preferredSize: Size.zero,
                          child: Divider(height: 1),
                        )
                      : TabBar(
                          isScrollable: true,
                          controller: _tabController,
                          tabs: iconTabLinkGridCard!.entities!
                              .map((item) => Tab(text: item.title))
                              .toList()),
                ),
                body: iconTabLinkGridCard == null
                    ? RefreshIndicator(
                        backgroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                        onRefresh: () async {
                          await _onRefresh();
                        },
                        child: _buildBody(_loadingState!),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: iconTabLinkGridCard!.entities!
                            .map(
                              (item) => CarouselPage(
                                isInit: false,
                                url: item.url,
                                title: item.title,
                              ),
                            )
                            .toList()),
              )
            : RefreshIndicator(
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                onRefresh: () async {
                  await _onRefresh();
                },
                child: _buildBody(_loadingState!),
              )
        : _isInit
            ? Scaffold(
                appBar: AppBar(),
                body: Center(child: _buildBody(_loadingState!)),
              )
            : Center(child: _buildBody(_loadingState!));
  }
}
