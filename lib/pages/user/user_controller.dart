import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/storage_util.dart';

class UserController extends CommonController {
  UserController({
    required this.uid,
  });

  late String uid;
  String? username;

  bool isBlocked = false;

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    if (dataList.lastOrNull?.entityTemplate == 'noMoreDataCard') {
      isEnd = true;
      footerState.value = LoadingState.empty();
    }
    return super.handleResponse(dataList);
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
      isBlocked = GStorage.checkUser(uid);
      if (!isBlocked) {
        onGetData();
      } else {
        setBlockedLoaidngState();
      }
    }
    userState.value = response;
  }

  @override
  void onBlock(uid) {
    super.onBlock(uid);
    isBlocked = true;
    setBlockedLoaidngState();
  }

  void setBlockedLoaidngState() {
    loadingState.value = LoadingState.error('$username is Blocked');
  }

  @override
  void onInit() {
    super.onInit();
    onGetUserData();
  }
}
