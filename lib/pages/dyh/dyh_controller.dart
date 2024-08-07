import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class DyhController extends CommonController {
  DyhController({
    required this.type,
    required this.id,
  });

  final String type;
  final String id;

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getDyhDetail(
      dyhId: id,
      type: type,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }
}
