import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class MessageController extends CommonController {
  @override
  Future<LoadingState> customGetData() {
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
