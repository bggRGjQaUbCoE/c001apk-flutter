import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class NotificationController extends CommonController {
  NotificationController({
    required this.url,
  });

  final String url;

  @override
  List<Datum>? handleUnique(List<Datum> dataList) {
    return null;
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getDataListFromUrl(
      url: url,
      data: {
        'page': page,
        if (firstItem != null) 'firstItem': firstItem,
        if (lastItem != null) 'lastItem': lastItem,
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}
