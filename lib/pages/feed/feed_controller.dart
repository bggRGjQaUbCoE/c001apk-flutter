import 'dart:convert';

import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed_article/feed_article.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/extensions.dart';

class FeedController extends CommonController {
  FeedController({required this.id});
  final String id;

  String listType = 'lastupdate_desc';
  final int _discussMode = 1;
  final String _feedType = 'feed';
  final int _blockStatus = 0;
  int fromFeedAuthor = 0;

  String? feedTypeName;
  int? feedUid;
  String? feedUsername;
  int? replyNum;

  List<FeedArticle>? articleList;
  List<String>? articleImgList;

  Rx<LoadingState> feedState = LoadingState.loading().obs;

  void setFeedState(LoadingState feedState) {
    this.feedState.value = feedState;
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getFeedReply(
      id: id,
      listType: listType,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
      discussMode: _discussMode,
      feedType: _feedType,
      blockStatus: _blockStatus,
      fromFeedAuthor: fromFeedAuthor,
    );
  }

  Future<void> getFeedData() async {
    LoadingState<dynamic> response =
        await NetworkRepo.getDataFromUrl(url: '/v6/feed/detail?id=$id');
    if (response is Success) {
      Datum data = (response.response as Datum);
      if (data.messageRawOutput != 'null') {
        List<dynamic> jsonList = jsonDecode(data.messageRawOutput!);
        articleList = jsonList
            .map((json) => FeedArticle.fromJson(json))
            .where((item) => ['text', 'image', 'shareUrl'].contains(item.type))
            .toList();
        if (!data.title.isNullOrEmpty) {
          articleList!.insert(0, FeedArticle(type: 'title', title: data.title));
        }
        if (!data.messageCover.isNullOrEmpty) {
          articleList!
              .insert(0, FeedArticle(type: 'image', url: data.messageCover));
        }
        articleImgList = articleList!
            .where((item) => item.type == 'image')
            .map((item) => item.url.orEmpty)
            .toList();
      }
      feedUsername = data.userInfo?.username;
      feedUid = data.uid;
      feedTypeName = data.feedTypeName;
      replyNum = data.replynum;
      onGetData();
    }
    feedState.value = response;
  }

  @override
  void onInit() {
    super.onInit();
    getFeedData();
  }
}
