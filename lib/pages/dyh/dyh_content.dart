import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/common_body.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/dyh/dyh_controller.dart';
import '../../pages/home/return_top_controller.dart';

class DyhContent extends StatefulWidget {
  const DyhContent({
    super.key,
    required this.type,
    required this.id,
    required this.title,
  });

  final String type;
  final String id;
  final String title;

  @override
  State<DyhContent> createState() => _DyhContentState();
}

class _DyhContentState extends State<DyhContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final _dyhController = DyhController(type: widget.type, id: widget.id);

  @override
  void initState() {
    super.initState();

    _dyhController.refreshKey = GlobalKey<RefreshIndicatorState>();
    _dyhController.scrollController = ScrollController();
    _dyhController.returnTopController =
        Get.find<ReturnTopController>(tag: widget.id + widget.title);

    _dyhController.returnTopController?.index.listen((index) {
      if ((index == 0 && widget.type == 'all') ||
          (index == 1 && widget.type == 'square')) {
        _dyhController.animateToTop();
      }
    });

    _onGetData();
  }

  @override
  void dispose() {
    _dyhController.scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onGetData({bool isRefresh = true}) async {
    var responseState = await _dyhController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _dyhController.loadingState = responseState;
        } else if (responseState is Success &&
            _dyhController.loadingState is Success) {
          _dyhController.loadingState = LoadingState.success(
              (_dyhController.loadingState as Success).response +
                  responseState.response);
        } else {
          _dyhController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildBody() {
    return buildBody(
      _dyhController,
      (isRefresh) => _onGetData(isRefresh: isRefresh),
      (state) => setState(() => _dyhController.loadingState = state),
      (state) => setState(() => _dyhController.footerState = state),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _dyhController.loadingState is Success
        ? RefreshIndicator(
            key: _dyhController.refreshKey,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _dyhController.onReset();
              await _onGetData();
            },
            child: _buildBody(),
          )
        : Center(child: _buildBody());
  }
}
