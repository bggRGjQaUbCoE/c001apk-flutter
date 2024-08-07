import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class AppController extends CommonController {
  AppController({
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getDataList(
      url: url,
      title: title,
      subTitle: '',
      firstItem: firstItem,
      lastItem: lastItem,
      page: page,
    );
  }
}
