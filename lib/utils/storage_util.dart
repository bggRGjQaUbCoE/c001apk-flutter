import 'dart:io';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../logic/model/fav_history/fav_history.dart';

class GStorage {
  static late final Box<dynamic> searchHistory;
  static late final Box<dynamic> historyFeed;
  static late final Box<dynamic> favFeed;
  static late final Box<dynamic> blackList;
  static late final Box<dynamic> settings;

  static void onDeleteFeed(String id, {bool isHistory = true}) {
    if (isHistory) {
      historyFeed.delete(id);
    } else {
      favFeed.delete(id);
    }
  }

  static bool checkFav(String id) {
    return favFeed.get(id) != null;
  }

  static bool checkHistory(String id) {
    return historyFeed.get(id) != null;
  }

  static bool checkUser(String uid) {
    List userBlackList =
        blackList.get(BlackListBoxKey.userBlackList, defaultValue: []);
    return userBlackList.contains(uid);
  }

  static bool checkTopic(String topic) {
    List topicBlackList =
        blackList.get(BlackListBoxKey.topicBlackList, defaultValue: []);
    return topicBlackList
            .firstWhereOrNull((keyword) => topic.contains(keyword)) !=
        null;
  }

  static void onBlock(
    String value, {
    bool isUser = true,
    bool isDelete = false,
    bool needToast = false,
  }) {
    List dataList = blackList.get(
      isUser ? BlackListBoxKey.userBlackList : BlackListBoxKey.topicBlackList,
      defaultValue: [],
    );
    if (!isDelete && dataList.contains(value)) {
      if (needToast) {
        SmartDialog.showToast('已存在');
      }
      return;
    }
    if (isDelete) {
      dataList = dataList.where((data) => data != value).toList();
    } else {
      dataList.insert(0, value);
    }
    blackList.put(
      isUser ? BlackListBoxKey.userBlackList : BlackListBoxKey.topicBlackList,
      dataList,
    );
  }

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    searchHistory = await Hive.openBox('searchHistory');
    historyFeed = await Hive.openBox('historyFeed');
    favFeed = await Hive.openBox('favFeed');
    blackList = await Hive.openBox('blackList');
    settings = await Hive.openBox('settings');
  }

  static void regAdapter() {
    Hive.registerAdapter(FavHistoryItemAdapter());
  }

  static Future<void> close() async {
    searchHistory.compact();
    searchHistory.close();
    historyFeed.compact();
    historyFeed.close();
    favFeed.compact();
    favFeed.close();
    blackList.compact();
    blackList.close();
    settings.compact();
    settings.close();
  }
}

class BlackListBoxKey {
  static const String userBlackList = 'userBlackList';
  static const String topicBlackList = 'topicBlackList';
}
