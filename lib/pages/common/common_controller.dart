import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';

abstract class CommonController extends GetxController {
  int page = 1;
  String? firstItem;
  String? lastItem;
  bool isLoading = false;
  bool isEnd = false;

  Rx<LoadingState> loadingState = LoadingState.loading().obs;
  Rx<LoadingState> footerState = LoadingState.loading().obs;
  GlobalKey<RefreshIndicatorState>? refreshKey;
  ScrollController? scrollController;
  ReturnTopController? returnTopController;

  List<Datum>? handleResponse(List<Datum> dataList) {
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
}
