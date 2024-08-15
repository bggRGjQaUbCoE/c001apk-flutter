import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';
import '../../../pages/home/home_page.dart' show TabType;
import '../../../utils/storage_util.dart';
import '../../../utils/utils.dart';

class HomeFeedController extends CommonController {
  HomeFeedController({
    required this.tabType,
    required this.installTime,
    this.url,
    this.title,
    this.followType,
  });

  final TabType tabType;
  final String installTime;
  int firstLaunch = 1;
  String? url;
  String? title;
  int? followType;

  @override
  void onReset() {
    super.onReset();
    if (tabType == TabType.FOLLOW) {
      int followType = GStorage.followType;
      if (this.followType != followType) {
        this.followType = followType;
        url = Utils.getFollowUrl(followType);
        title = Utils.getFollowTitle(followType);
      }
    }
  }

  @override
  Future<LoadingState> customGetData() {
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

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}
