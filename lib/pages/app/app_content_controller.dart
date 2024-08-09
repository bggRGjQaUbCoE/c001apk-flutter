import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/app/app_page.dart' show AppType;
import '../../pages/common/common_controller.dart';

class AppContentController extends CommonController {
  AppContentController({
    required this.appType,
    required this.packageName,
    required this.url,
    required this.title,
  });

  final AppType appType;
  final String packageName;
  final String url;
  final String title;

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getDataList(
      url: url,
      title: title,
      subTitle: '',
      firstItem: firstItem,
      lastItem: lastItem,
      page: page,
    );
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}
