import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../utils/storage_util.dart';

class SearchPageController extends GetxController {
  Box searchHistory = GStorage.searchHistory;
  RxList historyList = [].obs;

  @override
  void onInit() {
    super.onInit();
    _getData();
  }

  Future<void> _getData() async {
    historyList.value = searchHistory.get('searchHistory') ?? [];
  }

  void handleSearch(String value, [bool isDelete = false]) {
    List list = historyList.where((data) => data != value).toList();
    if (!isDelete) {
      list.insert(0, value);
    }
    historyList.value = list;
    searchHistory.put('searchHistory', list);
  }

  void clearAll() {
    historyList.value = [];
    searchHistory.put('searchHistory', []);
  }
}
