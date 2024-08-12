import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../logic/model/fav_history/fav_history.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/user_info.dart';
import '../../pages/history/history_page.dart' show HistoryType;
import '../../utils/storage_util.dart';

class HistoryController extends GetxController {
  HistoryController({required this.type});
  final HistoryType type;

  late final Box favFeed = GStorage.favFeed;
  late final Box historyFeed = GStorage.historyFeed;

  RxList<Datum> dataList = <Datum>[].obs;

  Future<void> _getData() async {
    List<dynamic> list = type == HistoryType.Favorite
        ? favFeed.values.toList()
        : historyFeed.values.toList();
    if (list.isNotEmpty) {
      list.sort((a, b) =>
          (a as FavHistoryItem).time!.compareTo((b as FavHistoryItem).time!));
      list = list.reversed.toList();
    }
    dataList.value = list.isNotEmpty
        ? list
            .map((item) => Datum(
                  id: (item as FavHistoryItem).id,
                  uid: item.uid,
                  userInfo: UserInfo(username: (item).username),
                  userAvatar: (item).userAvatar,
                  message: item.message,
                  deviceTitle: item.device,
                  dateline: item.dateline,
                ))
            .toList()
        : <Datum>[];
  }

  @override
  void onInit() {
    super.onInit();
    _getData();
  }

  void clearAll() async {
    if (type == HistoryType.Favorite) {
      favFeed.clear();
    } else {
      historyFeed.clear();
    }
    dataList.value = <Datum>[];
  }

  onDeleteFeed(dynamic id) {
    GStorage.onDeleteFeed(
      id.toString(),
      isHistory: type == HistoryType.History,
    );
    dataList.value = dataList.where((data) => data.id != id).toList();
  }
}
