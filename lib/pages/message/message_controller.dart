import '../../../logic/model/feed/datum.dart';
import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';

class MessageController extends CommonController {
  @override
  void handleResponse(List<Datum> dataList) {
    super.handleResponse(dataList);
    if (dataList.lastOrNull?.entityTemplate == 'noMoreDataCard') {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getDataListFromUrl(
      url: '/v6/notification/list',
      data: {
        'page': page,
        if (firstItem != null) 'firstItem': firstItem,
        if (lastItem != null) 'lastItem': lastItem,
      },
    );
  }
}
