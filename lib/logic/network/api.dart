import '../../constants/constants.dart';

class Api {
  static const String getHomeFeed =
      '${Constants.URL_API2_SERVICE}/v6/main/indexV8';

  static String getDataList = '${Constants.URL_API_SERVICE}/v6/page/dataList';

  static String getDataFromUrl(String url) {
    return '${Constants.URL_API_SERVICE}$url';
  }

  static String getFeedReply =
      '${Constants.URL_API2_SERVICE}/v6/feed/replyList';

  static String getUserFeed = '${Constants.URL_API_SERVICE}/v6/user/feedList';

  static String getAppInfo = '${Constants.URL_API_SERVICE}/v6/apk/detail';

  static String getSearch = '${Constants.URL_API_SERVICE}/v6/search';

  static String checkLoginInfo =
      '${Constants.URL_API_SERVICE}/v6/account/checkLoginInfo';

  static String getAppsUpdate =
      '${Constants.URL_API_SERVICE}/v6/apk/checkUpdate';

  static String getDyhDetail =
      '${Constants.URL_API_SERVICE}/v6/dyhArticle/list';

  static String getCoolPic = '${Constants.URL_API_SERVICE}/v6/picture/list';

  static String getReply2Reply =
      '${Constants.URL_API_SERVICE}/v6/feed/replyList';

  static String getAppDownloadUrl =
      '${Constants.URL_API_SERVICE}/v6/apk/download';

  static String getLoginParam(String url) {
    return '${Constants.URL_ACCOUNT_SERVICE}$url';
  }

  static String onLogin =
      '${Constants.URL_ACCOUNT_SERVICE}/auth/loginByCoolApk';

  static String getProfile = '${Constants.URL_API_SERVICE}/v6/user/profile';

  static String checkCount =
      '${Constants.URL_API_SERVICE}/v6/notification/checkCount';
}
