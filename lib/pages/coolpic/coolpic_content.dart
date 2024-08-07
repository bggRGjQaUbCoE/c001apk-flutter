import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/coolpic/coolpic_controller.dart';
import '../../pages/home/return_top_controller.dart';

class CoolpicContent extends StatefulWidget {
  const CoolpicContent({
    super.key,
    required this.type,
    required this.title,
  });

  final String type;
  final String title;

  @override
  State<CoolpicContent> createState() => _CoolpicContentState();
}

class _CoolpicContentState extends State<CoolpicContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _coolpicController =
      CoolpicController(type: widget.type, title: widget.title);

  @override
  void initState() {
    super.initState();

    _coolpicController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _coolpicController.scrollController = ScrollController();
    _coolpicController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.title);

    _coolpicController.returnTopController?.index.listen((index) {
      if ((index == 0 && widget.type == 'recommend') ||
          (index == 1 && widget.type == 'hot') ||
          (index == 2 && widget.type == 'newest')) {
        _coolpicController.animateToTop();
      }
    });

    _onGetData();
  }

  @override
  void dispose() {
    _coolpicController.scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _coolpicController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _coolpicController.loadingState = responseState;
        } else if (responseState is Success &&
            _coolpicController.loadingState is Success) {
          _coolpicController.loadingState = LoadingState.success(
              (_coolpicController.loadingState as Success).response +
                  responseState.response);
        } else {
          _coolpicController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _coolpicController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _coolpicController.loadingState = state),
      (state) => setState(() => _coolpicController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _coolpicController.loadingState is Success
        ? RefreshIndicator(
            key: _coolpicController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _coolpicController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
