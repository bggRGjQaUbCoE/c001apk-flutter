import '../../../logic/model/feed/datum.dart';
import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';

class UserController extends CommonController {
  UserController({
    required this.uid,
  });

  late String uid;
  String? username;

  @override
  void handleResponse(List<Datum> dataList) {
    if (dataList.lastOrNull?.entityTemplate == 'noMoreDataCard') {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getUserFeed(
      uid: uid,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }

  LoadingState userState = LoadingState.loading();

  Future<LoadingState> onGetUserData() async {
    LoadingState<dynamic> loadingState =
        await NetworkRepo.getDataFromUrl(url: '/v6/user/space?uid=$uid');

    if (loadingState is Success) {
      uid = (loadingState.response as Datum).uid.toString();
      username = (loadingState.response as Datum).username;
    }

    return loadingState;
  }
}
