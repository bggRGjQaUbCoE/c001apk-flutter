import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class CoolpicController extends CommonController {
  CoolpicController({
    required this.type,
    required this.title,
  });

  final String type;
  final String title;

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getCoolPic(
      tag: title,
      type: type,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }
}
