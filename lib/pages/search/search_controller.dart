import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class SearchController extends CommonController {
  SearchController({
    required this.type,
    required this.keyword,
    required this.pageType,
    required this.pageParam,
  });

  final String type;
  String feedType = 'all';
  String sort = 'default';
  final String keyword;
  int isStrict = 0;
  final String? pageType;
  final String? pageParam;

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getSearch(
      type: type,
      feedType: feedType,
      sort: sort,
      searchValue: keyword,
      isStrict: isStrict,
      pageType: pageType,
      pageParam: pageParam,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }
}
