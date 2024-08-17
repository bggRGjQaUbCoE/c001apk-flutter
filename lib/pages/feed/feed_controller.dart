import 'dart:convert';

import 'package:get/get.dart';

import '../../logic/model/fav_history/fav_history.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/user_action.dart';
import '../../logic/model/feed_article/feed_article.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../pages/feed/feed_page.dart' show ReplySortType;
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

  Datum? topReply;
  Datum? _replyMe;

  Rx<LoadingState> feedState = LoadingState.loading().obs;
  bool isFav = false;
  bool isBlocked = false;

  Rx<ReplySortType> replySelection = ReplySortType.def.obs;

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
      if (!data.topReplyRows.isNullOrEmpty) {
        topReply = data.topReplyRows![0];
      }
      if (!data.replyMeRows.isNullOrEmpty) {
        _replyMe = data.replyMeRows![0];
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

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    List<Datum> filterList = dataList;
    if (page == 1 && listType == 'lastupdate_desc') {
      filterList = [
            if (topReply != null) topReply!,
            if (_replyMe != null) _replyMe!,
          ] +
          filterList;
    }
    List<String> userBlackList = GStorage.blackList
        .get(BlackListBoxKey.userBlackList, defaultValue: <String>[]);
    return filterList
        .unique((data) => data.entityId)
        .map((data) => data
          ..replyRows = !data.replyRows.isNullOrEmpty
              ? data.replyRows!
                  .where(
                      (reply) => !userBlackList.contains(reply.uid.toString()))
                  .toList()
              : null)
        .toList();
  }

  void updateReply(bool isReply, Datum data, dynamic id, dynamic fid) {
    List<Datum> replyList = loadingState.value is Success
        ? (loadingState.value as Success).response
        : [];
    if (isReply) {
      replyList = replyList.map((reply) {
        if (reply.id == (fid ?? id)) {
          return reply..replyRows = (reply.replyRows ?? []) + [data];
        } else {
          return reply;
        }
      }).toList();
    } else {
      replyList.insert(topReply == null ? 0 : 1, data);
    }
    loadingState.value = LoadingState.success(replyList);
  }

  @override
  bool handleLike(dynamic like, dynamic likenum) {
    Datum data = (feedState.value as Success).response;
    feedState.value = LoadingState.success(data
      ..likenum = likenum
      ..userAction = UserAction(like: like == 1 ? 0 : 1));
    return true;
  }
}
