import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../utils/storage_util.dart';

class SearchPageController extends GetxController {
  Box searchHistory = GStorage.searchHistory;
  RxList historyList = [].obs;

  @override
  void onInit() {
    super.onInit();
    historyList.value = searchHistory.get('searchHistory') ?? [];
  }

  void handleSearch(String text, [bool isDelete = false]) {
    List list = historyList.where((e) => e != text).toList();
    if (!isDelete) {
      list.insert(0, text);
    }
    historyList.value = list;
    searchHistory.put('searchHistory', list);
  }

  void clearAll() {
    historyList.value = [];
    searchHistory.put('searchHistory', []);
  }
}
