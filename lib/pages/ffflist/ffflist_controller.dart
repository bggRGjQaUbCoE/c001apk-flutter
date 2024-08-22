import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../pages/ffflist/ffflist_page.dart' show FFFListType;

class FFFListController extends CommonController {
  FFFListController({
    required this.type,
    required this.url,
    this.uid,
    this.id,
    this.showDefault,
  });

  final FFFListType type;
  final String url;
  final String? uid;
  final String? id;
  final int? showDefault;

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getDataListFromUrl(
      url: url,
      data: {
        if (uid != null) 'uid': uid,
        if (id != null) 'id': id,
        if (showDefault != null) 'showDefault': showDefault,
        'page': page,
        if (firstItem != null) 'firstItem': firstItem,
        if (lastItem != null) 'lastItem': lastItem,
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }

  @override
  List<Datum>? handleUnique(List<Datum> dataList) {
    return [FFFListType.FOLLOW, FFFListType.FAN, FFFListType.USER_FOLLOW]
            .contains(type)
        ? null
        : super.handleUnique(dataList);
  }
}
