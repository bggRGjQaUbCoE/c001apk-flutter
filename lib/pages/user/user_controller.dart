import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class UserController extends CommonController {
  UserController({
    required this.uid,
  });

  late String uid;
  String? username;

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    if (dataList.lastOrNull?.entityTemplate == 'noMoreDataCard') {
      isEnd = true;
      footerState.value = LoadingState.empty();
    }
    return null;
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getUserFeed(
      uid: uid,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }

  Rx<LoadingState> userState = LoadingState.loading().obs;

  void setUserState(LoadingState userState) {
    this.userState.value = userState;
  }

  Future<void> onGetUserData() async {
    LoadingState response =
        await NetworkRepo.getDataFromUrl(url: '/v6/user/space?uid=$uid');
    if (response is Success) {
      uid = (response.response as Datum).uid.toString();
      username = (response.response as Datum).username;
      onGetData();
    }
    userState.value = response;
  }

  @override
  void onInit() {
    super.onInit();
    onGetUserData();
  }
}
