import '../../../logic/model/feed/datum.dart';
import '../../../logic/network/network_repo.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/common/common_controller.dart';

class Reply2ReplyController extends CommonController {
  Reply2ReplyController({
    required this.originReply,
    required this.id,
  });

  final Datum originReply;
  final String id;

  @override
  LoadingState? handleExtraResponse() {
    if (page == 1) {
      footerState.value = LoadingState.empty();
      return LoadingState.success([originReply]);
    }
    return null;
  }

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    return page == 1 ? [originReply] + dataList : null;
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getReply2Reply(
      id: id,
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

  void updateReply(Datum data, dynamic id) {
    List<Datum> replyList = loadingState.value is Success
        ? (loadingState.value as Success).response
        : [];
    int index = replyList.indexWhere((reply) => reply.id == id);
    replyList.insert(index + 1, data);
    loadingState.value = LoadingState.success(replyList);
  }
}
