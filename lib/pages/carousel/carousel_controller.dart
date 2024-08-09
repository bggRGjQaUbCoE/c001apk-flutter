import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class CarouselController extends CommonController {
  CarouselController({
    required this.isInit,
    required this.url,
    required this.title,
  });
  final bool isInit;
  final String url;
  final String title;

  RxInt tabSize = 0.obs;
  Datum? iconTabLinkGridCard;
  String? pageTitle;
  bool _isChecked = false;

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    if (isInit && !_isChecked) {
      _isChecked = true;
      iconTabLinkGridCard = dataList.firstWhereOrNull(
          (item) => item.entityTemplate == 'iconTabLinkGridCard');
      if (iconTabLinkGridCard != null) {
        tabSize.value = iconTabLinkGridCard!.entities!.length;
      }
      pageTitle = dataList.lastOrNull?.extraDataArr?.pageTitle;
    }
    return null;
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getDataList(
      url: url,
      title: title,
      subTitle: '',
      firstItem: firstItem,
      lastItem: lastItem,
      page: page,
      inCluldeConfigCard: isInit,
    );
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}
