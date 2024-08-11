import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../pages/blacklist/black_list_page.dart' show BlackListType;
import '../../utils/storage_util.dart';

class BlackListController extends GetxController {
  BlackListController({required this.type});
  final BlackListType type;

  late final String key = type == BlackListType.User
      ? BlackListBoxKey.userBlackList
      : BlackListBoxKey.topicBlackList;
  late final Box blackList = GStorage.blackList;
  RxList<String> dataList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _getData();
  }

  Future<void> _getData() async {
    dataList.value = blackList.get(key, defaultValue: <String>[]);
  }

  void handleData(String value, [bool isDelete = false]) {
    if (!isDelete && dataList.contains(value)) {
      SmartDialog.showToast('已存在');
      return;
    }
    if (isDelete) {
      dataList.value = dataList.where((data) => data != value).toList();
    } else {
      dataList.value = [value] + dataList;
    }
    blackList.put(key, dataList);
  }

  void clearAll() {
    dataList.value = <String>[];
    blackList.put(key, <String>[]);
  }
}
