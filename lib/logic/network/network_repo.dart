import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:get/get_connect/http/src/status/http_status.dart';

import '../../constants/constants.dart';
import '../../logic/model/feed/data_list_model.dart';
import '../../logic/model/feed/data_model.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/network/api.dart';
import '../../logic/network/request.dart';
import '../../logic/state/loading_state.dart';
import '../../utils/extensions.dart';
import '../../utils/storage_util.dart';
import '../../utils/token_util.dart';

class NetworkRepo {
  static Future<Response> postOSSUploadPrepare({
    required FormData data,
  }) async {
    return Request().post(Api.getDataFromUrl('/v6/upload/ossUploadPrepare'),
        data: data,
        options: Options(contentType: Headers.multipartFormDataContentType));
  }

  static Future<Response> sendMessage({
    required dynamic uid,
    required FormData data,
  }) async {
    return Request().post(
      Api.getDataFromUrl('/v6/message/send'),
      queryParameters: {
        'uid': uid,
      },
      data: data,
    );
  }

  static Future<Response> getImageUrl({
    required dynamic id,
  }) async {
    return Request().get(
      Api.getDataFromUrl('/v6/message/showImage'),
      queryParameters: {
        'id': id,
        'type': 's',
      },
      options: Options(followRedirects: false),
    );
  }

  static Future<Response> deleteMsg(
    String url, {
    dynamic ukey,
    dynamic id,
  }) async {
    return Request().get(
      Api.getDataFromUrl(url),
      queryParameters: {
        if (ukey != null) 'ukey': ukey,
        if (id != null) 'id': id,
      },
    );
  }

  static Future<LoadingState> messageOperation(
    String url, {
    String? ukey,
    String? uid,
    int? page,
    dynamic firstItem,
    dynamic lastItem,
  }) async {
    return getListData(
      () => Request().get(
        Api.getDataFromUrl(url),
        queryParameters: {
          if (ukey != null) 'ukey': ukey,
          if (uid != null) 'uid': uid,
          if (page != null) 'page': page,
          if (firstItem != null) 'firstItem': firstItem,
          if (lastItem != null) 'lastItem': lastItem,
        },
      ),
    );
  }

  static Future<Response> getFollow(
    String url, {
    String? tag,
    String? id,
  }) async {
    return Request().get(
      Api.getDataFromUrl(url),
      queryParameters: {
        if (tag != null) 'tag': tag,
        if (id != null) 'id': id,
      },
    );
  }

  static Future<Response> postLikeDeleteFollow(
    String url, {
    dynamic id,
    dynamic uid,
    FormData? data,
  }) async {
    return Request().post(
      Api.getDataFromUrl(url),
      queryParameters: {
        if (id != null) 'id': id,
        if (uid != null) 'uid': uid,
      },
      data: data,
    );
  }

  static Future<Response> postRequestValidate(
    FormData data,
  ) async {
    return Request().post(
      Api.postRequestValidate,
      data: data,
    );
  }

  static Future<Response> getValidateCaptcha() async {
    return Request().get(
      '${Constants.URL_API_SERVICE}/v6/account/captchaImage?${DateTime.now().microsecondsSinceEpoch ~/ 1000}&w=270=&h=113',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  static Future<Response> postCreateFeed(
    FormData data,
  ) async {
    return Request().post(
      Api.postCreateFeed,
      data: data,
    );
  }

  static Future<Response> postReply(
    FormData data,
    dynamic id,
    String type,
  ) async {
    return Request().post(
      Api.postReply,
      data: data,
      queryParameters: {'id': id, 'type': type},
    );
  }

  static Future<Response> checkCount() async {
    return Request().get(Api.checkCount);
  }

  static Future<Response> getProfile(String uid) async {
    return Request().get(Api.getProfile, queryParameters: {'uid': uid});
  }

  static Future<Response> onLogin(
    String requestHash,
    String account,
    String pwd,
    String captcha,
  ) async {
    return Request().post(Api.onLogin,
        data: FormData.fromMap({
          'submit': '1',
          'randomNumber': TokenUtils.createRandomNumber(),
          'requestHash': requestHash,
          'login': account,
          'password': pwd,
          'captcha': captcha,
          'code': '',
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  static Future<Response> getLoginParam(String url, [Options? options]) async {
    return Request().get(Api.getLoginParam(url), options: options);
  }

  static Future<LoadingState> getReply2Reply({
    required String id,
    required int page,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(Api.getReply2Reply, queryParameters: {
        'id': id,
        'page': page,
        'listType': '',
        'discussMode': 0,
        'feedType': 'feed_reply',
        'blockStatus': 0,
        'fromFeedAuthor': 0,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
      }),
    );
  }

  static Future<LoadingState> getCoolPic({
    required String tag,
    required String type,
    required int page,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(Api.getCoolPic, queryParameters: {
        'tag': tag,
        'type': type,
        'page': page,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
      }),
    );
  }

  static Future<LoadingState> getDyhDetail({
    required String dyhId,
    required String type,
    required int page,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(Api.getDyhDetail, queryParameters: {
        'dyhId': dyhId,
        'type': type,
        'page': page,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
      }),
    );
  }

  static Future<Response> getAppsUpdate(
    String pkgs,
  ) async {
    return Request().post(
      Api.getAppsUpdate,
      queryParameters: {'coolmarket_beta': '0'},
      data: FormData.fromMap({
        'pkgs': pkgs,
      }),
    );
  }

  static Future<Response> checkLoginInfo() async {
    return Request().get(Api.checkLoginInfo);
  }

  static Future<LoadingState> getSearch({
    required String type,
    required String feedType,
    required String sort,
    required String searchValue,
    required int isStrict,
    required String? pageType,
    required String? pageParam,
    required int page,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(Api.getSearch, queryParameters: {
        'type': type,
        'feedType': feedType,
        'sort': sort,
        'searchValue': searchValue,
        'isStrict': isStrict,
        if (!pageType.isNullOrEmpty) 'pageType': pageType,
        if (!pageParam.isNullOrEmpty) 'pageParam': pageParam,
        'page': page,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
        'showAnonymous': -1,
      }),
    );
  }

  static Future<Response> getAppDownloadUrl({
    required String packageName,
    required int id,
    required int versionCode,
  }) async {
    return Request().get(
      Api.getAppDownloadUrl,
      queryParameters: {
        'pn': packageName,
        'aid': id,
        'vc': versionCode,
        'extra': '',
      },
      options: Options(followRedirects: false),
    );
  }

  static Future<LoadingState> getAppInfo({
    required String id,
  }) async {
    return getData(
      () => Request().get(Api.getAppInfo, queryParameters: {
        'id': id,
        'installed': 1,
      }),
    );
  }

  static Future<LoadingState> getUserFeed({
    required String uid,
    required int page,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(Api.getUserFeed, queryParameters: {
        'uid': uid,
        'page': page,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
        'showAnonymous': 0,
        'isIncludeTop': 1,
        'showDoing': 0,
      }),
    );
  }

  static Future<LoadingState> getFeedReply({
    required String id,
    required String listType,
    required int page,
    required String? firstItem,
    required String? lastItem,
    required int discussMode,
    required String feedType,
    required int blockStatus,
    required int fromFeedAuthor,
  }) async {
    return getListData(
      () => Request().get(Api.getFeedReply, queryParameters: {
        'id': id,
        'listType': listType,
        'page': page,
        if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
        if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
        'discussMode': discussMode,
        'feedType': feedType,
        'blockStatus': blockStatus,
        'fromFeedAuthor': fromFeedAuthor,
      }),
    );
  }

  static Future<LoadingState> getDataFromUrl({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    return getData(
      () => Request().get(Api.getDataFromUrl(url), queryParameters: data),
    );
  }

  static Future<LoadingState> getDataListFromUrl({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    return getListData(
      () => Request().get(
        Api.getDataFromUrl(url),
        queryParameters: data,
      ),
    );
  }

  static Future<LoadingState> getHomeFeed({
    required int page,
    required int firstLaunch,
    required String installTime,
    required String? firstItem,
    required String? lastItem,
  }) async {
    return getListData(
      () => Request().get(
        Api.getHomeFeed,
        queryParameters: {
          'page': page,
          'firstLaunch': firstLaunch,
          'installTime': installTime,
          if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
          if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
          'ids': '',
        },
      ),
    );
  }

  static Future<LoadingState> getDataList({
    required String url,
    required String title,
    required String subTitle,
    required String? firstItem,
    required String? lastItem,
    required int page,
    bool inCluldeConfigCard = false,
  }) async {
    return getListData(
      () => Request().get(
        Api.getDataList,
        queryParameters: {
          'url': url,
          'title': title,
          'subTitle': subTitle,
          if (!firstItem.isNullOrEmpty) 'firstItem': firstItem,
          if (!lastItem.isNullOrEmpty) 'lastItem': lastItem,
          'page': page,
        },
      ),
      inCluldeConfigCard: inCluldeConfigCard,
    );
  }

  static Future<LoadingState> getData(
      Future<Response<dynamic>> Function() get) async {
    try {
      var response = await get();
      return handleDataResponse(response);
    } catch (err) {
      return LoadingState.error(err.toString());
    }
  }

  static Future<LoadingState> getListData(
    Future<Response<dynamic>> Function() get, {
    bool inCluldeConfigCard = false,
  }) async {
    try {
      var response = await get();
      return await handleListResponse(
        response,
        inCluldeConfigCard: inCluldeConfigCard,
      );
    } catch (err) {
      return LoadingState.error(err.toString());
    }
  }

  static Future<LoadingState> handleDataResponse(
      Response<dynamic> response) async {
    if (response.statusCode == HttpStatus.ok) {
      DataModel responseData = DataModel.fromJson(response.data);
      if (!responseData.message.isNullOrEmpty) {
        return LoadingState.error(response.data['message']);
      } else {
        if (responseData.data != null) {
          return LoadingState.success(responseData.data);
        } else {
          return LoadingState.empty();
        }
      }
    } else {
      return LoadingState.error('statusCode: ${response.statusCode}');
    }
  }

  static Future<LoadingState> handleListResponse(
    Response<dynamic> response, {
    bool inCluldeConfigCard = false,
  }) async {
    if (response.statusCode == HttpStatus.ok) {
      DataListModel responseData = DataListModel.fromJson(response.data);
      if (!responseData.message.isNullOrEmpty) {
        return LoadingState.error(response.data['message']);
      } else {
        if (!responseData.data.isNullOrEmpty) {
          List<String> userBlackList = GStorage.blackList
              .get(BlackListBoxKey.userBlackList, defaultValue: <String>[]);
          List<String> topicBlackList = GStorage.blackList
              .get(BlackListBoxKey.topicBlackList, defaultValue: <String>[]);
          List<Datum> filterList = responseData.data!.where((item) {
            return (Constants.entityTypeList.contains(item.entityType) ||
                    (Constants.entityTemplateList +
                            (inCluldeConfigCard ? ['configCard'] : []))
                        .contains(item.entityTemplate)) &&
                !userBlackList.contains(item.uid.toString()) &&
                topicBlackList.firstWhereOrNull((keyword) =>
                        '${item.tags},${item.ttitle},${item.relationRows?.getOrNull(0)?.title}'
                            .contains(keyword)) ==
                    null;
          }).toList();
          return LoadingState.success(filterList);
        } else {
          return LoadingState.empty();
        }
      }
    } else {
      return LoadingState.error('statusCode: ${response.statusCode}');
    }
  }
}
