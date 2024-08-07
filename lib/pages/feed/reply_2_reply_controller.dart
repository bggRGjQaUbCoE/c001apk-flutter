import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';

class Reply2ReplyController extends CommonController {
  Reply2ReplyController({
    required this.id,
  });

  final String id;

  @override
  Future<LoadingState> customFetchData() {
    return NetworkRepo.getReply2Reply(
      id: id,
      page: page,
      firstItem: firstItem,
      lastItem: lastItem,
    );
  }
}
