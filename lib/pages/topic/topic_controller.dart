import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/model/feed/tab_list.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/extensions.dart';
import '../../utils/storage_util.dart';

class TopicController extends CommonController {
  TopicController({required this.tag, required this.id});

  final String? tag;
  String? id;

  String? title;
  String? entityType;
  List<TabList>? tabList;
  RxInt initialIndex = 0.obs;
  Rx<LoadingState> topicState = LoadingState.loading().obs;

  bool isBlocked = false;
  bool isFollow = false;

  Future<void> _getTopicData() async {
    LoadingState<dynamic> response = await NetworkRepo.getDataFromUrl(
      url: !tag.isNullOrEmpty
          ? '/v6/topic/newTagDetail'
          : !id.isNullOrEmpty
              ? '/v6/product/detail'
              : '',
      data: {
        if (!tag.isNullOrEmpty) 'tag': tag,
        if (!id.isNullOrEmpty) 'id': id,
      },
    );
    if (response is Success) {
      Datum data = response.response;
      id = data.id.toString();
      title = data.title;
      entityType = data.entityType;
      tabList = data.tabList;
      String selectedTab = data.selectedTab!;
      initialIndex.value =
          tabList!.map((item) => item.pageName).toList().indexOf(selectedTab);

      isBlocked = GStorage.checkTopic(title!);
      isFollow = data.userAction?.follow == 1;

      topicState.value = LoadingState.success(response.response);
    } else {
      topicState.value = response;
    }
  }

  void onReGetTopicData() {
    topicState.value = LoadingState.loading();
    _getTopicData();
  }

  @override
  void onInit() {
    super.onInit();
    _getTopicData();
  }

  @override
  void handleGetFollow() {
    isFollow = !isFollow;
  }

  @override
  Future<LoadingState> customGetData() {
    // TODO: implement customGetData
    throw UnimplementedError();
  }
}
