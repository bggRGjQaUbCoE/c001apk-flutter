import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../logic/model/app_info/app_info.dart';

class AppListController extends GetxController with StateMixin<List<AppInfo>> {
  static const platform = MethodChannel('samples.flutter.dev/channel');

  Future<void> onReload([bool isRefresh = false]) async {
    if (!isRefresh) {
      change(null, status: RxStatus.loading());
    }
    await _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    try {
      List<dynamic> installedApps =
          await platform.invokeMethod('getInstalledApps');
      List<AppInfo> parseList = AppInfo.parseList(installedApps);
      if (parseList.isNotEmpty) {
        change(parseList, status: RxStatus.success());
      } else {
        change(null, status: RxStatus.empty());
      }
    } on PlatformException catch (e) {
      change(null, status: RxStatus.error(e.message));
      return;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(milliseconds: 500));
    _getInstalledApps();
  }
}
