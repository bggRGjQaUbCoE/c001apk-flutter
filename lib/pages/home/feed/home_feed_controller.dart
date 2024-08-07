import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;

class HomeFeedNewController extends CommonController {
  HomeFeedNewController({
    required this.tabType,
    required this.installTime,
    this.url,
    this.title,
  });

  final TabType tabType;
  final String installTime;
  int firstLaunch = 1;
  final String? url;
  final String? title;

  @override
  Future<LoadingState> customFetchData() {
    return tabType == TabType.FEED
        ? NetworkRepo.getHomeFeed(
            page: page,
            firstLaunch: firstLaunch,
            installTime: installTime,
            firstItem: firstItem,
            lastItem: lastItem,
          )
        : NetworkRepo.getDataList(
            url: url!,
            title: title!,
            subTitle: '',
            firstItem: firstItem,
            lastItem: lastItem,
            page: page,
          );
  }
}
