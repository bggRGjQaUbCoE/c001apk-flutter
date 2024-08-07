import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../../constants/constants.dart';
import '../../../logic/network/network_repo.dart';
import '../../../utils/extensions.dart';

// ignore: constant_identifier_names
enum ReportType { Feed, Reply, User }

enum ShareType { feed, u, apk, t, product }

class Utils {
  static const platform = MethodChannel('samples.flutter.dev/channel');

  static String getShareUrl(String id, ShareType type) {
    return 'https://www.coolapk1s.com/${type.name}/$id';
  }

  static void report(String id, ReportType reportType) {
    String c = reportType == ReportType.User ? 'user' : 'feed';
    String type = switch (reportType) {
      ReportType.Feed => '&type=feed',
      ReportType.Reply => '&type=feed_reply',
      ReportType.User => '',
    };
    Get.toNamed(
      '/webview',
      parameters: {
        'url': 'https://m.coolapk.com/mp/do?c=$c&m=report$type&id=$id',
      },
    );
  }

  static bool isSupportWebview() {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  static Future<void> onShareImg(String url) async {
    SmartDialog.showLoading();
    var response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    final temp = await getTemporaryDirectory();
    SmartDialog.dismiss();
    final String imgName = url.split('/').last;
    var path = '${temp.path}/$imgName';
    File(path).writeAsBytesSync(response.data);
    Share.shareXFiles([XFile(path)], subject: url);
  }

  static void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    SmartDialog.showToast('已复制');
  }

  static List<double> getImageLp(String url) {
    double imgWidth = 1;
    double imgHeight = 1;
    int at = url.lastIndexOf("@");
    int x = url.lastIndexOf("x");
    int dot = url.lastIndexOf(".");
    if (at != -1 && x != -1 && dot != -1) {
      try {
        imgWidth = double.parse(url.substring(at + 1, x));
        imgHeight = double.parse(url.substring(x + 1, dot));
      } catch (e) {
        print(e.toString());
      }
    }
    return [imgWidth, imgHeight];
  }

  static Future<String?> onGetDownloadUrl(
    String appName,
    String packageName,
    int id,
    String versionName,
    int versionCode,
  ) async {
    try {
      await NetworkRepo.getAppDownloadUrl(
        packageName: packageName,
        id: id,
        versionCode: versionCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 302) {
        String? url = e.response?.headers['Location']?.firstOrNull;
        if (!url.isNullOrEmpty) {
          onDownloadFile(
            url!,
            '$appName-$versionName-$versionCode.apk',
          );
          return url;
        } else {
          SmartDialog.showToast('failed to get url');
        }
      } else {
        SmartDialog.showToast('request failed: ${e.message}');
      }
    }
    return null;
  }

  static void onDownloadFile(String url, String name) async {
    Clipboard.setData(ClipboardData(text: url));
    if (Platform.isAndroid) {
      if (!await platform.invokeMethod(
        'downloadApk',
        {
          'url': url,
          'name': name,
        },
      )) {
        Utils.launchURL(url);
      }
    } else {
      Utils.launchURL(url);
    }
  }

  static void onOpenLink(
    String url, [
    String? title,
    bool needConvert = false,
  ]) {
    if (url.isEmpty) {
      return;
    }
    String path = url;
    if (needConvert) {
      if (url.startsWith(Constants.PREFIX_COOLMARKET)) {
        path = url.replaceFirst(Constants.PREFIX_COOLMARKET, '/');
      } else {
        Uri uri = Uri.parse(url);
        if (uri.host.contains(Constants.CHANNEL)) {
          path = '${uri.path}?${uri.query}';
        }
      }
    }
    if (path.startsWith(Constants.PREFIX_FEED)) {
      Get.toNamed(
          '/feed/${path.replaceFirst(Constants.PREFIX_FEED, '').replaceAll('?', '&')}');
    } else if (path.startsWith(Constants.PREFIX_USER)) {
      String uid = path.replaceFirst(Constants.PREFIX_USER, '');
      try {
        uid = Uri.encodeComponent(uid);
      } catch (e) {
        print(e.toString());
      }
      Get.toNamed('/u/$uid');
    } else if (path.startsWith(Constants.PREFIX_APP)) {
      Get.toNamed('/apk/${path.replaceFirst(Constants.PREFIX_APP, '')}');
    } else if (path.startsWith(Constants.PREFIX_GAME)) {
      Get.toNamed('/apk/${path.replaceFirst(Constants.PREFIX_GAME, '')}');
    } else if (path.startsWith(Constants.PREFIX_TOPIC)) {
      String tag = path
          .replaceFirst(Constants.PREFIX_TOPIC, '')
          .replaceFirst(RegExp('\\?type=[A-Za-z0-9]+'), '');
      try {
        tag = Uri.encodeComponent(tag);
      } catch (e) {
        print(e.toString());
      }
      if (path.contains('type=8')) {
        Get.toNamed('/coolpic', parameters: {'title': tag});
      } else {
        Get.toNamed('/t/$tag');
      }
    } else if (path.startsWith(Constants.PREFIX_PRODUCT)) {
      Get.toNamed(
          '/product/${path.replaceFirst(Constants.PREFIX_PRODUCT, '')}');
    } else if (path.startsWith(Constants.PREFIX_CAROUSEL)) {
      Get.toNamed(
        '/carousel',
        parameters: {
          'url': path.replaceFirst(Constants.PREFIX_CAROUSEL, ''),
          'title': title.orEmpty,
          'isInit': '1',
        },
      );
    } else if (path.startsWith(Constants.PREFIX_CAROUSEL1)) {
      Get.toNamed(
        '/carousel',
        parameters: {
          'url': path.replaceFirst('#', ''),
          'title': title.orEmpty,
          'isInit': '1',
        },
      );
    } else if (path.startsWith(Constants.PREFIX_DYH)) {
      Get.toNamed(
        '/dyh',
        parameters: {
          'id': path.replaceFirst(Constants.PREFIX_DYH, ''),
          'title': title.orEmpty,
        },
      );
    } else {
      if (!needConvert) {
        onOpenLink(url, title, true);
      } else {
        if (url.startsWith(Constants.PREFIX_HTTP)) {
          if (isSupportWebview()) {
            // todo
            Get.toNamed('/webview', parameters: {'url': url});
          } else {
            launchURL(url);
          }
        } else {
          SmartDialog.showToast('unsupported url: $url');
        }
      }
    }
  }

  static final Random random = Random();

  static String parseHtmlString(String htmlString) {
    dom.Document document = html_parser.parse(htmlString);
    return _parseNode(document.body);
  }

  static String _parseNode(dom.Node? node) {
    if (node == null) {
      return '';
    }

    if (node is dom.Element) {
      if (node.localName == 'br') {
        return '\n';
      }
      return node.nodes.map(_parseNode).join('');
    } else if (node is dom.Text) {
      return node.text;
    }

    return '';
  }

  // static showToast(BuildContext context, String msg) {
  //   Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: Toast.LENGTH_SHORT,
  //     backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  //     textColor: Theme.of(context).colorScheme.onPrimaryContainer,
  //   );
  // }

  static launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        SmartDialog.showToast('Could not launch $url');
      }
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  static String numFormat(dynamic number) {
    if (number == null) {
      return '0';
    }
    if (number is String) {
      return number;
    }
    final String res = (number / 10000).toString();
    if (int.parse(res.split('.')[0]) >= 1) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else {
      return number.toString();
    }
  }

  static String timeFormat(dynamic time) {
    // 1小时内
    if (time is String && time.contains(':')) {
      return time;
    }
    if (time < 3600) {
      if (time == 0) {
        return '00:00';
      }
      final int minute = time ~/ 60;
      final double res = time / 60;
      if (minute != res) {
        return '${minute < 10 ? '0$minute' : minute}:${(time - minute * 60) < 10 ? '0${(time - minute * 60)}' : (time - minute * 60)}';
      } else {
        return '$minute:00';
      }
    } else {
      final int hour = time ~/ 3600;
      final String hourStr = hour < 10 ? '0$hour' : hour.toString();
      var a = timeFormat(time - hour * 3600);
      return '$hourStr:$a';
    }
  }

  // 完全相对时间显示
  static String formatTimestampToRelativeTime(timeStamp) {
    var difference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000));

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}年前';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 时间显示，刚刚，x分钟前
  static String dateFormat(timeStamp, {formatType = 'list'}) {
    if (timeStamp == 0 || timeStamp == null || timeStamp == '') {
      return '';
    }
    // 当前时间
    int time = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    // 对比
    int distance = (time - timeStamp).toInt();
    // 当前年日期
    String currentYearStr = 'MM月DD日 hh:mm';
    String lastYearStr = 'YY年MM月DD日 hh:mm';
    if (formatType == 'detail') {
      currentYearStr = 'MM-DD hh:mm';
      lastYearStr = 'YY-MM-DD hh:mm';
      return CustomStamp_str(
          timestamp: timeStamp,
          date: lastYearStr,
          toInt: false,
          formatType: formatType);
    }
    print('distance: $distance');
    if (distance <= 60) {
      return '刚刚';
    } else if (distance <= 3600) {
      return '${(distance / 60).floor()}分钟前';
    } else if (distance <= 43200) {
      return '${(distance / 60 / 60).floor()}小时前';
    } else if (DateTime.fromMillisecondsSinceEpoch(time * 1000).year ==
        DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).year) {
      return CustomStamp_str(
          timestamp: timeStamp,
          date: currentYearStr,
          toInt: false,
          formatType: formatType);
    } else {
      return CustomStamp_str(
          timestamp: timeStamp,
          date: lastYearStr,
          toInt: false,
          formatType: formatType);
    }
  }

  // 时间戳转时间
  static String CustomStamp_str(
      {int? timestamp, // 为空则显示当前时间
      String? date, // 显示格式，比如：'YY年MM月DD日 hh:mm:ss'
      bool toInt = true, // 去除0开头
      String? formatType}) {
    timestamp ??= (DateTime.now().millisecondsSinceEpoch / 1000).round();
    String timeStr =
        (DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)).toString();

    dynamic dateArr = timeStr.split(' ')[0];
    dynamic timeArr = timeStr.split(' ')[1];

    String YY = dateArr.split('-')[0];
    String MM = dateArr.split('-')[1];
    String DD = dateArr.split('-')[2];

    String hh = timeArr.split(':')[0];
    String mm = timeArr.split(':')[1];
    String ss = timeArr.split(':')[2];

    ss = ss.split('.')[0];

    // 去除0开头
    if (toInt) {
      MM = (int.parse(MM)).toString();
      DD = (int.parse(DD)).toString();
      hh = (int.parse(hh)).toString();
      mm = (int.parse(mm)).toString();
    }

    if (date == null) {
      return timeStr;
    }

    // if (formatType == 'list' && int.parse(DD) > DateTime.now().day - 2) {
    //   return '昨天';
    // }

    date = date
        .replaceAll('YY', YY)
        .replaceAll('MM', MM)
        .replaceAll('DD', DD)
        .replaceAll('hh', hh)
        .replaceAll('mm', mm)
        .replaceAll('ss', ss);
    if (int.parse(YY) == DateTime.now().year &&
        int.parse(MM) == DateTime.now().month) {
      // 当天
      if (int.parse(DD) == DateTime.now().day) {
        return '今天';
      }
    }
    return date;
  }

  static String makeHeroTag(v) {
    return v.toString() + random.nextInt(9999).toString();
  }

  static int duration(String duration) {
    List timeList = duration.split(':');
    int len = timeList.length;
    if (len == 2) {
      return int.parse(timeList[0]) * 60 + int.parse(timeList[1]);
    }
    if (len == 3) {
      return int.parse(timeList[0]) * 3600 +
          int.parse(timeList[1]) * 60 +
          int.parse(timeList[2]);
    }
    return 0;
  }

  static int findClosestNumber(int target, List<int> numbers) {
    int minDiff = 127;
    int closestNumber = 0; // 初始化为0，表示没有找到比目标值小的整数

    // 向下查找
    try {
      for (int number in numbers) {
        if (number < target) {
          int diff = target - number; // 计算目标值与当前整数的差值

          if (diff < minDiff) {
            minDiff = diff;
            closestNumber = number;
          }
        }
      }
    } catch (_) {}

    // 向上查找
    if (closestNumber == 0) {
      try {
        for (int number in numbers) {
          int diff = (number - target).abs();

          if (diff < minDiff) {
            minDiff = diff;
            closestNumber = number;
          }
        }
      } catch (_) {}
    }
    return closestNumber;
  }

  // 版本对比
  static bool needUpdate(localVersion, remoteVersion) {
    List<String> localVersionList = localVersion.split('.');
    List<String> remoteVersionList = remoteVersion.split('v')[1].split('.');
    for (int i = 0; i < localVersionList.length; i++) {
      int localVersion = int.parse(localVersionList[i]);
      int remoteVersion = int.parse(remoteVersionList[i]);
      if (remoteVersion > localVersion) {
        return true;
      } else if (remoteVersion < localVersion) {
        return false;
      }
    }
    return false;
  }

  // 时间戳转时间
  static tampToSeektime(number) {
    int hours = number ~/ 60;
    int minutes = number % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes';
  }

  static String appSign(
      Map<String, dynamic> params, String appkey, String appsec) {
    params['appkey'] = appkey;
    var searchParams = Uri(queryParameters: params).query;
    var sortedParams = searchParams.split('&')..sort();
    var sortedQueryString = sortedParams.join('&');

    var appsecString = sortedQueryString + appsec;
    var md5Digest = md5.convert(utf8.encode(appsecString));
    var md5String = md5Digest.toString(); // 获取MD5哈希值

    return md5String;
  }

  static List<int> generateRandomBytes(int minLength, int maxLength) {
    return List<int>.generate(random.nextInt(maxLength - minLength + 1),
        (_) => random.nextInt(0x60) + 0x20);
  }

  static String base64EncodeRandomString(int minLength, int maxLength) {
    List<int> randomBytes = generateRandomBytes(minLength, maxLength);
    return base64.encode(randomBytes);
  }
}
