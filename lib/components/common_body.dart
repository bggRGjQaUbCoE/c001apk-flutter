import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/footer.dart';
import '../components/item_card.dart';
import '../logic/model/feed/datum.dart';
import '../logic/state/loading_state.dart';
import '../pages/common/common_controller.dart';

Widget _bodyState(String text, Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10.0),
      child: Text(text),
    ),
  );
}

Widget buildBody(
  CommonController commonController,
  Function(bool) onGetData,
  Function(LoadingState) setLoadingState,
  Function(LoadingState) setFooterState, {
  bool isReply2Reply = false,
  dynamic uid,
}) {
  switch (commonController.loadingState) {
    case Empty():
      return _bodyState(
        'EMPTY',
        () {
          commonController.isEnd = false;
          setLoadingState(LoadingState.loading());
          onGetData(true);
        },
      );
    case Error():
      return _bodyState(
        (commonController.loadingState as Error).errMsg,
        () {
          commonController.isEnd = false;
          setLoadingState(LoadingState.loading());
          onGetData(true);
        },
      );
    case Success():
      var dataList =
          (commonController.loadingState as Success).response as List<Datum>;
      return ListView.separated(
        controller: commonController.scrollController,
        physics: AlwaysScrollableScrollPhysics(
          parent: isReply2Reply
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
            left: isReply2Reply ? 0 : 10,
            top: isReply2Reply ? 0 : 10,
            right: isReply2Reply ? 0 : 10,
            bottom: (isReply2Reply ? 0 : 10) +
                MediaQuery.of(Get.context!).padding.bottom),
        itemCount: dataList.length + 1,
        itemBuilder: (_, index) {
          if (index == dataList.length) {
            if (!commonController.isEnd && !commonController.isLoading) {
              onGetData(false);
            }
            return footerWidget(commonController.footerState!, () {
              commonController.isEnd = false;
              setFooterState(LoadingState.loading());
              onGetData(false);
            });
          } else {
            return itemCard(
              dataList[index],
              isReply2Reply: isReply2Reply,
              isTopReply: isReply2Reply && index == 0,
              uid: uid,
            );
          }
        },
        separatorBuilder: (_, index) => isReply2Reply
            ? const Divider(height: 1)
            : const SizedBox(height: 10),
      );
  }
  return Container(
    height: 80,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(10.0),
    child: const CircularProgressIndicator(),
  );
}
