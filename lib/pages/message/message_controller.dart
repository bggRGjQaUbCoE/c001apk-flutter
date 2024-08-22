import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import '../../logic/model/check_count/check_count.dart';
import '../../logic/model/check_count/datum.dart' as checkcountdata;
import '../../logic/model/feed/data_model.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';

class MessageController extends CommonController {
  final RxList<int?> firstList = <int?>[].obs;
  final RxList<int?> thirdList = <int?>[].obs;

  Future<void> checkCount() async {
    try {
      Response response = await NetworkRepo.checkCount();
      checkcountdata.Datum? data = CheckCount.fromJson(response.data).data;
      thirdList.value = [
        data?.atme,
        data?.atcommentme,
        data?.feedlike,
        data?.contactsFollow,
        data?.message,
      ];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getProfile() async {
    try {
      Response response = await NetworkRepo.getProfile(GlobalData().uid);
      Datum? data = DataModel.fromJson(response.data).data;
      String username = data?.username ?? '';
      try {
        username = Uri.encodeComponent(username);
      } catch (e) {
        debugPrint(e.toString());
      }
      GStorage.setUserAvatar(data?.userAvatar ?? '');
      GStorage.setUsername(username);
      GStorage.setLevel(data?.level ?? 0);
      GStorage.setExp(data?.experience ?? 0);
      GStorage.setNextExp(data?.nextLevelExperience ?? 1);
      firstList.value = [data?.feed, data?.follow, data?.fans];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.getDataListFromUrl(
      url: '/v6/notification/list',
      data: {
        'page': page,
        if (firstItem != null) 'firstItem': firstItem,
        if (lastItem != null) 'lastItem': lastItem,
      },
    );
  }
}
