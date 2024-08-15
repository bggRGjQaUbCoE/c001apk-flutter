import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../logic/model/feed/data_list_model.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/login/login_response.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/common/common_controller.dart';
import '../../utils/extensions.dart';

class ChatController extends CommonController {
  ChatController({
    required this.ukey,
  });

  final String ukey;

  late final editingController = TextEditingController();
  RxBool showEmojiPanel = false.obs;

  @override
  Future<LoadingState> customGetData() {
    return NetworkRepo.messageOperation('/v6/message/chat',
        ukey: ukey, page: page, firstItem: firstItem, lastItem: lastItem);
  }

  @override
  void onInit() {
    super.onInit();
    onGetData();
  }

  @override
  List<Datum>? handleResponse(List<Datum> dataList) {
    return dataList.reversed.toList();
  }

  Future<void> onGetImageUrl(dynamic id) async {
    try {
      await NetworkRepo.getImageUrl(id: id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 302) {
        String? imageUrl = e.response?.headers['Location']?.firstOrNull;
        if (!imageUrl.isNullOrEmpty) {
          List<Datum> dataList = (loadingState.value as Success).response;
          dataList = dataList.map((data) {
            if (data.id == id) {
              return data..messagePic = imageUrl;
            } else {
              return data;
            }
          }).toList();
          loadingState.value = LoadingState.success(dataList);
        }
      } else {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> onDeleteMsg(dynamic id) async {
    try {
      Response response =
          await NetworkRepo.deleteMsg('/v6/message/delete', ukey: ukey, id: id);
      LoginResponse data = LoginResponse.fromJson(response.data);
      if (!data.message.isNullOrEmpty) {
        SmartDialog.showToast(data.message!);
      } else if (data.data != null) {
        List<Datum> dataList = (loadingState.value as Success).response;
        dataList = dataList.where((data) => data.id != id).toList();
        loadingState.value = LoadingState.success(dataList);
        SmartDialog.showToast(data.data!);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> onSendMessage(dynamic uid) async {
    try {
      SmartDialog.showLoading();
      Response response = await NetworkRepo.sendMessage(
        uid: uid,
        data: FormData.fromMap(
          {
            'message': editingController.text,
            // 'message_pic': '',
          },
        ),
      );
      DataListModel data = DataListModel.fromJson(response.data);
      if (!data.message.isNullOrEmpty) {
        SmartDialog.dismiss();
        SmartDialog.showToast(data.message!);
      } else {
        SmartDialog.dismiss();
        List<Datum> dataList = loadingState.value is Success
            ? (loadingState.value as Success).response
            : <Datum>[];
        dataList = (data.data ?? <Datum>[]) + dataList;
        loadingState.value = LoadingState.success(dataList);
        editingController.clear();
        await Future.delayed(const Duration(milliseconds: 500));
        await animateToTop();
      }
    } catch (e) {
      SmartDialog.dismiss();
      debugPrint(e.toString());
    }
  }

  void setShowEmoji(bool showEmojiPanel) {
    this.showEmojiPanel.value = showEmojiPanel;
  }
}
