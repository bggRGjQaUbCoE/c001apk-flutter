import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class FFFListController extends CommonController {
  FFFListController({
    required this.url,
    this.uid,
    this.id,
    this.showDefault,
  });

  final String url;
  final String? uid;
  final String? id;
  final int? showDefault;

  @override
  Future<LoadingState> customFetchData() {
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
}
