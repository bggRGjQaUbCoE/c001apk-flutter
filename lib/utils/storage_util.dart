import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class GStorage {
  static late final Box<dynamic> searchHistory;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    searchHistory = await Hive.openBox('searchHistory');
  }

  static void regAdapter() {}

  static Future<void> close() async {
    searchHistory.compact();
    searchHistory.close();
  }
}
