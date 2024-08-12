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

Widget commonBody(
  CommonController commonController, {
  bool isHomeCard = false,
  bool isReply2Reply = false,
  dynamic uid,
}) {
  return Obx(
    () => commonController.loadingState.value is Success
        ? RefreshIndicator(
            key: commonController.refreshKey,
            onRefresh: () async {
              commonController.onReset();
              await commonController.onGetData();
            },
            child: buildBody(
              commonController,
              isHomeCard: isHomeCard,
              isReply2Reply: isReply2Reply,
              uid: uid,
            ),
          )
        : Center(
            child: buildBody(
              commonController,
              isHomeCard: isHomeCard,
              isReply2Reply: isReply2Reply,
              uid: uid,
            ),
          ),
  );
}

Widget buildBody(
  CommonController commonController, {
  bool isHomeCard = false,
  bool isReply2Reply = false,
  dynamic uid,
  Function(
    dynamic id,
    dynamic uname,
    dynamic fid,
  )? onReply,
  Function(
    dynamic id,
    dynamic fid,
  )? onDelete,
}) {
  switch (commonController.loadingState.value) {
    case Empty():
      return _bodyState(
        'EMPTY',
        () {
          commonController.isEnd = false;
          commonController.setLoadingState(LoadingState.loading());
          commonController.onGetData(true);
        },
      );
    case Error():
      return _bodyState(
        (commonController.loadingState.value as Error).errMsg,
        () {
          commonController.isEnd = false;
          commonController.setLoadingState(LoadingState.loading());
          commonController.onGetData(true);
        },
      );
    case Success():
      var dataList = (commonController.loadingState.value as Success).response
          as List<Datum>;
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
              commonController.setFooterState(LoadingState.loading());
              commonController.onGetData(false);
            }
            return Obx(
                () => footerWidget(commonController.footerState.value, () {
                      commonController.isEnd = false;
                      commonController.setFooterState(LoadingState.loading());
                      commonController.onGetData(false);
                    }));
          } else {
            return itemCard(
              dataList[index],
              isHomeCard: isHomeCard,
              isReply2Reply: isReply2Reply,
              isTopReply: isReply2Reply && index == 0,
              uid: uid,
              onBlock: commonController.onBlock,
              onReply: onReply,
              onDelete: commonController.onDeleteFeedOrReply,
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
