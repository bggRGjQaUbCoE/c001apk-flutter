import 'package:flutter/material.dart';

import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/home/return_top_controller.dart';

abstract class CommonController {
  int page = 1;
  String? firstItem;
  String? lastItem;
  bool isLoading = false;
  bool isEnd = false;

  void onReset() {
    page = 1;
    isEnd = false;
    firstItem = null;
    lastItem = null;
  }

  Future<LoadingState> customFetchData();

  void handleResponse(List<Datum> dataList) {}

  Future<LoadingState?> onGetData() async {
    if (!isLoading) {
      isLoading = true;
      LoadingState response = await customFetchData();
      if (response is Success) {
        page++;
        try {
          firstItem ??=
              (response.response as List<Datum>).firstOrNull?.id.toString();
          lastItem =
              (response.response as List<Datum>).lastOrNull?.id.toString();
          handleResponse(response.response as List<Datum>);
        } catch (e) {
          print('failed to get first or last id: ${e.toString()}');
        }
      } else {
        isEnd = true;
      }
      isLoading = false;
      return response;
    }
    return null;
  }

  LoadingState loadingState = LoadingState.loading();
  LoadingState footerState = LoadingState.loading();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  ScrollController? scrollController;
  ReturnTopController? returnTopController;

  void animateToTop() async {
    await scrollController?.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    returnTopController?.setIndex(999);
    refreshKey.currentState?.show();
  }
}
