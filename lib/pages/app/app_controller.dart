import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../utils/storage_util.dart';

class AppController extends GetxController {
  AppController({required this.packageName});
  final String packageName;

  late final String? id;
  late final int? commentStatus;
  late final String? commentStatusText;
  late final String? entityType;

  Rx<LoadingState> appState = LoadingState.loading().obs;
  RxString appName = ''.obs;

  bool isBlocked = false;

  Future<void> _getAppData() async {
    LoadingState response = await NetworkRepo.getAppInfo(id: packageName);
    if (response is Success) {
      id = (response.response as Datum).id.toString();
      commentStatus = (response.response as Datum).commentStatus;
      commentStatusText = (response.response as Datum).commentStatusText;
      entityType = (response.response as Datum).entityType ?? '';
      appState.value = LoadingState.success(response.response);
      appName.value = (response.response as Datum).title ?? '';
      isBlocked = GStorage.checkTopic(appName.value);
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
}
