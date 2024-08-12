import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../logic/model/feed/datum.dart';
import '../../logic/model/login/login_response.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';
import '../../utils/extensions.dart';

abstract class CommonController extends GetxController {
  int page = 1;
  String? firstItem;
  String? lastItem;
  bool isLoading = false;
  bool isEnd = false;

  Rx<LoadingState> loadingState = LoadingState.loading().obs;
  Rx<LoadingState> footerState = LoadingState.empty().obs;
  GlobalKey<RefreshIndicatorState>? refreshKey;
  ScrollController? scrollController;
  ReturnTopController? returnTopController;

  List<Datum>? handleResponse(List<Datum> dataList) {
    return dataList.unique((data) => data.entityId);
  }

  LoadingState? handleExtraResponse() {
    return null;
  }

  Future<LoadingState> customGetData();

  Future<void> onGetData([bool isRefresh = true]) async {
    if (!isLoading) {
      isLoading = true;
      LoadingState response = await customGetData();
      if (response is Success) {
        List<Datum> dataList = response.response;
        firstItem ??= dataList.firstOrNull?.id.toString();
        lastItem = dataList.lastOrNull?.id.toString();
        List<Datum>? handleList = handleResponse(dataList);
        if (handleList != null) {
          dataList = handleList;
        }
        loadingState.value = LoadingState.success(isRefresh
            ? dataList
            : (loadingState.value as Success).response + dataList);
        page++;
      } else {
        isEnd = true;
        LoadingState? extraResponse = handleExtraResponse();
        if (extraResponse != null) {
          response = extraResponse;
        }
        if (isRefresh) {
          loadingState.value = response;
        } else {
          footerState.value = response;
        }
      }
      isLoading = false;
    }
  }

  void onReset() {
    page = 1;
    isEnd = false;
    firstItem = null;
    lastItem = null;
    footerState.value = LoadingState.loading();
  }

  void setFooterState(LoadingState footerState) {
    this.footerState.value = footerState;
  }

  void setLoadingState(LoadingState loadingState) {
    this.loadingState.value = loadingState;
  }

  void animateToTop() async {
    await scrollController?.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    returnTopController?.setIndex(999);
    refreshKey?.currentState?.show();
  }

  void onBlock(dynamic uid) {
    List<Datum> dataList = (loadingState.value as Success).response;
    loadingState.value = LoadingState.success(
        dataList.where((item) => item.uid != uid).toList());
  }

  Future<void> onDeleteFeedOrReply(bool isFeed, dynamic id, dynamic fid) async {
    String url = isFeed ? '/v6/feed/deleteFeed' : '/v6/feed/deleteReply';
    try {
      Response response = await NetworkRepo.postLikeDeleteFollow(url, id: id);
      LoginResponse data = LoginResponse.fromJson(response.data);
      if (!data.message.isNullOrEmpty) {
        SmartDialog.showToast(data.message!);
      } else if (data.data == '删除成功') {
        List<Datum> dataList = (loadingState.value as Success).response;
        if (fid != null) {
          dataList = dataList.map((data) {
            if (data.id == fid) {
              return data
                ..replyRows =
                    data.replyRows!.where((data) => data.id != id).toList();
            } else {
              return data;
            }
          }).toList();
        } else {
          dataList = dataList.where((data) => data.id != id).toList();
        }
        loadingState.value = LoadingState.success(dataList);
        SmartDialog.showToast(data.data!);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
