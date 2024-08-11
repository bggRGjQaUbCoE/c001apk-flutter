import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/cards/feed_reply_card.dart';
import '../../components/feed_article_body.dart';
import '../../components/footer.dart';
import '../../components/sliver_pinned_box_adapter.dart';
import '../../components/cards/feed_card.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/feed/feed_controller.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum FeedMenuItem { Copy, Share, Fav, Block, Report }

enum ReplySortType { def, dateline, hot, author }

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final _config = Provider.of<AppConfigProvider>(context);
  final String _id = Get.parameters['id'].orEmpty;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  late final _feedController = Get.put(
    FeedController(
      id: _id,
      recordHistory: _config.recordHistory,
    ),
    tag: _id,
  );

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

  Widget _buildFeedContent(LoadingState feedState) {
    switch (feedState) {
      case Empty():
        return GestureDetector(
          onTap: () {
            _feedController.setFeedState(LoadingState.loading());
            _feedController.getFeedData();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: () {
            _feedController.setFeedState(LoadingState.loading());
            _feedController.getFeedData();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(feedState.errMsg),
          ),
        );
      case Success():
        return _feedController.articleList.isNullOrEmpty
            ? FeedCard(
                data: feedState.response!,
                isFeedContent: true,
              )
            : SliverList.separated(
                itemCount: _feedController.articleList!.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return header(
                      context,
                      feedState.response!,
                      true,
                    );
                  } else if (index == _feedController.articleList!.length + 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: bottomInfo(
                        context,
                        feedState.response!,
                        true,
                        null,
                        isFeedArticle: true,
                      ),
                    );
                  } else {
                    return LayoutBuilder(builder: (_, constraints) {
                      return feedArticleBody(
                        constraints.maxWidth,
                        _feedController.articleList![index - 1],
                        _feedController.articleImgList!,
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
                    child: Text('共 ${_feedController.replyNum} 回复'),
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
                              _feedController.listType = 'lastupdate_desc';
                              _feedController.fromFeedAuthor = 0;
                              break;
                            case ReplySortType.dateline:
                              _feedController.listType = 'dateline_desc';
                              _feedController.fromFeedAuthor = 0;
                              break;
                            case ReplySortType.hot:
                              _feedController.listType = 'popular';
                              _feedController.fromFeedAuthor = 0;
                              break;
                            case ReplySortType.author:
                              _feedController.listType = '';
                              _feedController.fromFeedAuthor = 1;
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

  Widget _buildFeedReply(LoadingState replyState) {
    switch (replyState) {
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
              _feedController
                ..isEnd = false
                ..setLoadingState(LoadingState.loading())
                ..onGetData();
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              child: Text(replyState.errMsg),
            ),
          ),
        );
      case Success():
        List<Datum> dataList = replyState.response;
        return SliverPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          sliver: SliverList.separated(
            itemCount: dataList.length + 1,
            itemBuilder: (_, index) {
              if (index == dataList.length) {
                if (!_feedController.isEnd && !_feedController.isLoading) {
                  _feedController.onGetData(false);
                }
                return Obx(
                    () => footerWidget(_feedController.footerState.value, () {
                          _feedController
                            ..isEnd = false
                            ..setFooterState(LoadingState.loading())
                            ..onGetData(false);
                        }));
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
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: _feedController.feedTypeName.isNullOrEmpty
              ? null
              : Text(_feedController.feedTypeName!),
          actions: _feedController.feedState.value is Success
              ? [
                  PopupMenuButton(
                    onSelected: (FeedMenuItem item) {
                      switch (item) {
                        case FeedMenuItem.Copy:
                          Utils.copyText(
                              Utils.getShareUrl(_id, ShareType.feed));
                          break;
                        case FeedMenuItem.Share:
                          Share.share(Utils.getShareUrl(_id, ShareType.feed));
                          break;
                        case FeedMenuItem.Fav:
                          if (_feedController.isFav) {
                            GStorage.onDeleteFeed(_id, isHistory: false);
                          } else {
                            _feedController.onFav();
                          }
                          _feedController.isFav = !_feedController.isFav;
                          break;
                        case FeedMenuItem.Block:
                          GStorage.onBlock(
                            _feedController.feedUid.toString(),
                            isDelete: _feedController.isBlocked,
                          );
                          _feedController.isBlocked =
                              !_feedController.isBlocked;
                          break;
                        case FeedMenuItem.Report:
                          if (Utils.isSupportWebview()) {
                            Utils.report(_id, ReportType.Feed);
                          } else {
                            SmartDialog.showToast('not supported');
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => FeedMenuItem.values
                        .map((item) => PopupMenuItem<FeedMenuItem>(
                              value: item,
                              child: item == FeedMenuItem.Fav
                                  ? Text(
                                      _feedController.isFav ? 'UnFav' : 'Fav',
                                    )
                                  : item == FeedMenuItem.Block
                                      ? Text(
                                          _feedController.isBlocked
                                              ? 'UnBlock'
                                              : 'Block',
                                        )
                                      : Text(item.name),
                            ))
                        .toList(),
                  )
                ]
              : null,
        ),
        body: _feedController.feedState.value is Success
            ? RefreshIndicator(
                key: _refreshKey,
                onRefresh: () async {
                  _feedController.onReset();
                  await _feedController.onGetData();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _feedController.articleList.isNullOrEmpty
                        ? SliverToBoxAdapter(
                            child: _buildFeedContent(
                                _feedController.feedState.value))
                        : _buildFeedContent(_feedController.feedState.value),
                    _buildPinWidget(),
                    _buildFeedReply(_feedController.loadingState.value),
                  ],
                ),
              )
            : Center(
                child: _buildFeedContent(_feedController.loadingState.value)),
      ),
    );
  }
}
