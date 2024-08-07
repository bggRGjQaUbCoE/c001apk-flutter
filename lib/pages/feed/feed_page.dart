import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/cards/feed_reply_card.dart';
import '../../components/feed_article_body.dart';
import '../../components/footer.dart';
import '../../components/sliver_pinned_box_adapter.dart';
import '../../components/cards/feed_card.dart';
import '../../logic/model/feed_article/feed_article.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum FeedMenuItem { Copy, Share, Fav, Block, Report }

enum ReplySortType { def, dateline, hot, author }

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  LoadingState _feedState = LoadingState.loading();
  LoadingState _replyState = LoadingState.loading();
  LoadingState _footerState = LoadingState.loading();
  String? _feedTypeName;
  int? _feedUid;
  String? _feedUsername;
  int? _replyNum;

  List<FeedArticle>? _articleList;
  List<String>? _articleImgList;

  String _listType = 'lastupdate_desc';
  int _page = 1;
  String? _firstItem;
  String? _lastItem;
  final int _discussMode = 1;
  final String _feedType = 'feed';
  final int _blockStatus = 0;
  int _fromFeedAuthor = 0;

  bool _isLoading = false;
  bool _isEnd = false;

  final String _id = Get.parameters['id'].orEmpty;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  static const List<(ReplySortType, String)> _shirtSizeOptions =
      <(ReplySortType, String)>[
    (ReplySortType.def, '默认'),
    (ReplySortType.dateline, '最新'),
    (ReplySortType.hot, '热门'),
    (ReplySortType.author, '楼主'),
  ];
  Set<ReplySortType> _segmentedButtonSelection = <ReplySortType>{
    ReplySortType.def
  };

  Future<void> _getFeedData() async {
    LoadingState<dynamic> response =
        await NetworkRepo.getDataFromUrl(url: '/v6/feed/detail?id=$_id');
    if (response is Success) {
      if (mounted) {
        Datum data = (response.response as Datum);
        if (data.messageRawOutput != 'null') {
          List<dynamic> jsonList = jsonDecode(data.messageRawOutput!);
          _articleList = jsonList
              .map((json) => FeedArticle.fromJson(json))
              .where(
                  (item) => ['text', 'image', 'shareUrl'].contains(item.type))
              .toList();
          if (!data.title.isNullOrEmpty) {
            _articleList!
                .insert(0, FeedArticle(type: 'title', title: data.title));
          }
          if (!data.messageCover.isNullOrEmpty) {
            _articleList!
                .insert(0, FeedArticle(type: 'image', url: data.messageCover));
          }
          _articleImgList = _articleList!
              .where((item) => item.type == 'image')
              .map((item) => item.url.orEmpty)
              .toList();
        }
        _feedUsername = data.userInfo?.username;
        _feedUid = data.uid;
        _feedTypeName = data.feedTypeName;
        _replyNum = data.replynum;
        setState(() {
          _feedState = LoadingState.success(data);
        });
      }
      _getFeedReply(true);
    } else {
      if (mounted) {
        setState(() => _feedState = response);
      }
    }
  }

  Future<void> _getFeedReply([bool isRefresh = false]) async {
    if (!_isLoading) {
      _isLoading = true;
      LoadingState<dynamic> response = await NetworkRepo.getFeedReply(
        id: _id,
        listType: _listType,
        page: _page,
        firstItem: _firstItem,
        lastItem: _lastItem,
        discussMode: _discussMode,
        feedType: _feedType,
        blockStatus: _blockStatus,
        fromFeedAuthor: _fromFeedAuthor,
      );
      if (response is Success) {
        _page++;
        var originList = response.response as List<Datum>;
        _firstItem = originList.firstOrNull?.id.toString();
        _lastItem = originList.lastOrNull?.id.toString();
        var filterList = originList.where((item) {
          return item.entityType == 'feed_reply';
        }).toList();
        if (mounted) {
          setState(() {
            _replyState = LoadingState.success(
                isRefresh || _replyState is! Success
                    ? filterList
                    : (_replyState as Success).response + filterList);
            _footerState = LoadingState.loading();
          });
        }
      } else {
        _isEnd = true;
        if (isRefresh) {
          if (mounted) {
            setState(() => _replyState = response);
          }
        } else {
          if (mounted) {
            setState(() => _footerState = response);
          }
        }
      }
      _isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _getFeedData();
  }

  void _onReGetFeedData() {
    if (mounted) {
      setState(() => _feedState = LoadingState.loading());
    }
    _getFeedData();
  }

  Future<void> _onRefreshReply() async {
    _page = 1;
    _firstItem = null;
    _lastItem = null;
    _isEnd = false;
    await _getFeedReply(true);
  }

  Widget _buildFeedContent() {
    switch (_feedState) {
      case Empty():
        return GestureDetector(
          onTap: _onReGetFeedData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: _onReGetFeedData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text((_feedState as Error).errMsg),
          ),
        );
      case Success():
        return _articleList.isNullOrEmpty
            ? FeedCard(
                data: (_feedState as Success).response!,
                isFeedContent: true,
              )
            : SliverList.separated(
                itemCount: _articleList!.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return header(
                      context,
                      (_feedState as Success).response!,
                      true,
                    );
                  } else if (index == _articleList!.length + 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: bottomInfo(
                        context,
                        (_feedState as Success).response!,
                        true,
                        null,
                        isFeedArticle: true,
                      ),
                    );
                  } else {
                    return LayoutBuilder(builder: (_, constraints) {
                      return feedArticleBody(
                        constraints.maxWidth,
                        _articleList![index - 1],
                        _articleImgList!,
                      );
                    });
                  }
                },
                separatorBuilder: (_, index) => const SizedBox(height: 12),
              );
    }
    return const CircularProgressIndicator();
  }

  Widget _buildPinWidget() {
    return SliverPinnedBoxAdapter(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Text('共 $_replyNum 回复'),
                  ),
                  SegmentedButton<ReplySortType>(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                    showSelectedIcon: false,
                    selected: _segmentedButtonSelection,
                    segments: _shirtSizeOptions
                        .map<ButtonSegment<ReplySortType>>(
                            ((ReplySortType, String) shirt) {
                      return ButtonSegment<ReplySortType>(
                          value: shirt.$1, label: Text(shirt.$2));
                    }).toList(),
                    onSelectionChanged: (Set<ReplySortType> newSelection) {
                      if (mounted) {
                        setState(() {
                          _segmentedButtonSelection = newSelection;
                          switch (newSelection.first) {
                            case ReplySortType.def:
                              _listType = 'lastupdate_desc';
                              _fromFeedAuthor = 0;
                              break;
                            case ReplySortType.dateline:
                              _listType = 'dateline_desc';
                              _fromFeedAuthor = 0;
                              break;
                            case ReplySortType.hot:
                              _listType = 'popular';
                              _fromFeedAuthor = 0;
                              break;
                            case ReplySortType.author:
                              _listType = '';
                              _fromFeedAuthor = 1;
                              break;
                          }
                          _refreshKey.currentState?.show();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedReply() {
    switch (_replyState) {
      case Empty():
        return SliverToBoxAdapter(
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() => _replyState = LoadingState.loading());
              }
              _onRefreshReply();
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              child: Text((_replyState as Error).errMsg),
            ),
          ),
        );
      case Success():
        List<Datum> dataList = (_replyState as Success).response as List<Datum>;
        return SliverPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          sliver: SliverList.separated(
            itemCount: dataList.length + 1,
            itemBuilder: (_, index) {
              if (index == dataList.length) {
                if (!_isEnd && !_isLoading) {
                  _getFeedReply();
                }
                return footerWidget(_footerState, () {
                  _isEnd = false;
                  if (mounted) {
                    setState(() => _footerState = LoadingState.loading());
                  }
                  _getFeedReply();
                });
              } else {
                return FeedReplyCard(
                  data: dataList[index],
                );
              }
            },
            separatorBuilder: (_, index) => const Divider(height: 1),
          ),
        );
    }
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: _feedTypeName.isNullOrEmpty ? null : Text(_feedTypeName!),
        actions: _feedState is Success
            ? [
                PopupMenuButton(
                  onSelected: (FeedMenuItem item) {
                    switch (item) {
                      case FeedMenuItem.Copy:
                        Utils.copyText(Utils.getShareUrl(_id, ShareType.feed));
                        break;
                      case FeedMenuItem.Share:
                        Share.share(Utils.getShareUrl(_id, ShareType.feed));
                        break;
                      case FeedMenuItem.Fav:
                        SmartDialog.showToast('todo: fav');
                        break;
                      case FeedMenuItem.Block:
                        SmartDialog.showToast('todo: block');
                        break;
                      case FeedMenuItem.Report:
                        Utils.report(_id, ReportType.Feed);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => FeedMenuItem.values
                      .map((item) => PopupMenuItem<FeedMenuItem>(
                            value: item,
                            child: Text(item.name),
                          ))
                      .toList(),
                )
              ]
            : null,
      ),
      body: _feedState is Success
          ? RefreshIndicator(
              key: _refreshKey,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              onRefresh: () async {
                await _onRefreshReply();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _articleList.isNullOrEmpty
                      ? SliverToBoxAdapter(child: _buildFeedContent())
                      : _buildFeedContent(),
                  _buildPinWidget(),
                  _buildFeedReply(),
                ],
              ),
            )
          : Center(child: _buildFeedContent()),
    );
  }
}
