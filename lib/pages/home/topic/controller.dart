import 'package:get/get.dart';

import '../../../logic/network/network_repo.dart';
import '../../../logic/model/feed/datum.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/home/home_page.dart' show TabType;

class HomeTopicController extends GetxController with StateMixin<List<Datum>> {
  HomeTopicController({
    required this.tabType,
  });
  final TabType tabType;

  void onReload() {
    change(null, status: RxStatus.loading());
    getData();
  }

  Future<void> getData() async {
    LoadingState<dynamic> response = await NetworkRepo.getDataListFromUrl(
        url: tabType == TabType.TOPIC
            ? '/v6/page/dataList?url=V11_VERTICAL_TOPIC&title=话题&page=1'
            : '/v6/product/categoryList');
    switch (response) {
      case Empty():
        change(null, status: RxStatus.empty());
      case Error():
        change(null, status: RxStatus.error(response.errMsg));
      case Success():
        change(response.response, status: RxStatus.success());
    }
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }
}
