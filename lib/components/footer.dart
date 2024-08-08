import 'package:flutter/material.dart';

import '../logic/state/loading_state.dart';

Widget footerWidget(LoadingState footerState, Function() onReload) {
  switch (footerState) {
    case Empty():
      return Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        child: const Text('END'),
      );
    case Error():
      return GestureDetector(
        onTap: onReload,
        child: Container(
          height: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10.0),
          child: Text(footerState.errMsg),
        ),
      );
    default:
      return Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        child: const CircularProgressIndicator(),
      );
  }
}
