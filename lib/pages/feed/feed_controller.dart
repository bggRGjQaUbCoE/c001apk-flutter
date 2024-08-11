import 'dart:convert';

import 'package:get/get.dart';

import '../../logic/model/fav_history/fav_history.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed_article/feed_article.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/extensions.dart';
import '../../utils/storage_util.dart';

class FeedController extends CommonController {
  FeedController({required this.id, required this.recordHistory});
  final String id;
  final bool recordHistory;

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
  bool isFav = false;
  bool isBlocked = false;

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

      isFav = GStorage.checkFav(id);
      isBlocked = GStorage.checkUser(feedUid.toString());
      // todo: check
      if (recordHistory && !GStorage.checkHistory(id)) {
        GStorage.historyFeed.put(id, getFeed(data));
      }
    }
    feedState.value = response;
  }

  void onFav() {
    Datum data = (feedState.value as Success).response;
    GStorage.favFeed.put(id, getFeed(data));
  }

  FavHistoryItem getFeed(Datum data) {
    return FavHistoryItem(
      id: data.id.toString(),
      uid: data.uid.toString(),
      username: data.userInfo?.username,
      userAvatar: data.userInfo?.userAvatar,
      message: (data.message ?? '').length <= 150
          ? data.message
          : data.message!.substring(0, 150),
      device: data.deviceTitle,
      dateline: data.dateline.toString(),
      time: DateTime.now().microsecondsSinceEpoch,
    );
  }

  @override
  void onInit() {
    super.onInit();
    getFeedData();
  }

  void onBlockReply(dynamic uid, dynamic id) {
    List<Datum> replyList = (loadingState.value as Success).response;
    if (id != null) {
      replyList = replyList.map((reply) {
        if (reply.id == id) {
          return reply
            ..replyRows =
                reply.replyRows!.where((reply) => reply.uid != uid).toList();
        } else {
          return reply;
        }
      }).toList();
    } else {
      replyList = replyList.where((reply) => reply.uid != uid).toList();
    }
    loadingState.value = LoadingState.success(replyList);
  }
}
