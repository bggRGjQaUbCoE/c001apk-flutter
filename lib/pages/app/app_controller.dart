import 'package:get/get.dart' hide Response;

import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/storage_util.dart';

class AppController extends CommonController {
  AppController({required this.packageName});
  final String packageName;

  late final String? id;
  late final int? commentStatus;
  late final String? commentStatusText;
  late final String? entityType;

  Rx<LoadingState> appState = LoadingState.loading().obs;
  String? appName;

  RxDouble scrollRatio = 0.0.obs;

  bool isBlocked = false;
  bool isFollow = false;

  Future<void> _getAppData() async {
    LoadingState response = await NetworkRepo.getAppInfo(id: packageName);
    if (response is Success) {
      Datum data = response.response as Datum;
      id = data.id.toString();
      commentStatus = data.commentStatus;
      commentStatusText = data.commentStatusText;
      entityType = data.entityType ?? '';
      appName = data.title;
      isFollow = data.userAction?.follow == 1;
      isBlocked = GStorage.checkTopic(appName!);
      appState.value = LoadingState.success(response.response);
    } else {
      appState.value = response;
    }
  }

  void regetData() {
    appState.value = LoadingState.loading();
    _getAppData();
  }

  @override
  void onInit() {
    super.onInit();
    _getAppData();
  }

  @override
  void handleGetFollow() {
    isFollow = !isFollow;
  }

  @override
  Future<LoadingState> customGetData() {
    // TODO: implement customGetData
    throw UnimplementedError();
  }
}
