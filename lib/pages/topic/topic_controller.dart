import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';

class TopicController extends CommonController {
  TopicController({
    required this.url,
    required this.title,
  });

  late String url;
  late String title;

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
