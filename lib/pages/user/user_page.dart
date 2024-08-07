import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:indent/indent.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/cards/user_info_card.dart';
import '../../../components/footer.dart';
import '../../../components/item_card.dart';
import '../../../logic/model/feed/datum.dart';
import '../../../logic/state/loading_state.dart';
import '../../../pages/user/user_controller.dart';
import '../../../utils/extensions.dart';
import '../../../utils/utils.dart';

// ignore: constant_identifier_names
enum UserMenuItem { Copy, Share, Block, Report, UserInfo }

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final String _uid = Get.parameters['uid'].orEmpty;

  late final UserController _userController = UserController(uid: _uid);

  double _scrollRatio = 0;

  @override
  void initState() {
    super.initState();
    _onGetUserData();
  }

  void _onReGetUserData() {
    setState(() => _userController.userState = LoadingState.loading());
    _onGetUserData();
  }

  Future<void> _onGetUserData() async {
    LoadingState loadingState = await _userController.onGetUserData();
    setState(() => _userController.userState = loadingState);
    if (loadingState is Success) {
      _onGetUserFeed();
    }
  }

  Future<void> _onGetUserFeed({bool isRefresh = true}) async {
    var responseState = await _userController.onGetData();
    if (responseState != null) {
      setState(() {
        if (isRefresh) {
          _userController.loadingState = responseState;
        } else if (responseState is Success &&
            _userController.loadingState is Success) {
          _userController.loadingState = LoadingState.success(
              (_userController.loadingState as Success).response +
                  responseState.response);
        } else {
          _userController.footerState = responseState;
        }
      });
    }
  }

  Widget _buildUserInfo(LoadingState userState) {
    switch (userState) {
      case Empty():
        return GestureDetector(
          onTap: _onReGetUserData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return GestureDetector(
          onTap: _onReGetUserData,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(userState.errMsg),
          ),
        );
      case Success():
        return UserInfoCard(
          data: userState.response!,
        );
    }
    return const CircularProgressIndicator();
  }

  Widget _buildUserFeed(LoadingState loadingState) {
    switch (loadingState) {
      case Empty():
        return SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () {
              setState(
                  () => _userController.loadingState = LoadingState.loading());
              _onGetUserFeed();
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              child: const Text('EMPTY'),
            ),
          ),
        );
      case Error():
        return SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () {
              setState(
                  () => _userController.loadingState = LoadingState.loading());
              _onGetUserFeed();
            },
            child: Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10.0),
              child: Text(loadingState.errMsg),
            ),
          ),
        );
      case Success():
        List<Datum> dataList = loadingState.response as List<Datum>;
        return SliverPadding(
          padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom),
          sliver: SliverList.separated(
            itemCount: dataList.length + 1,
            itemBuilder: (_, index) {
              if (index == dataList.length) {
                if (!_userController.isEnd && !_userController.isLoading) {
                  _onGetUserFeed(isRefresh: false);
                }
                return footerWidget(_userController.footerState, () {
                  _userController.isEnd = false;
                  setState(() =>
                      _userController.footerState = LoadingState.loading());
                  _onGetUserFeed(isRefresh: false);
                });
              } else {
                return itemCard(dataList[index]);
              }
            },
            separatorBuilder: (_, index) => const SizedBox(height: 10),
          ),
        );
    }
    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10.0),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            notificationPredicate: (notification) {
              final double offset = notification.metrics.pixels;
              if (offset >= 0) {
                setState(() => _scrollRatio = min(1.0, offset / 105));
              }
              return true;
            },
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () async {
              _userController.onReset();
              await _onGetUserFeed();
            },
            child: _userController.userState is Success
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildUserInfo(_userController.userState),
                      ),
                      _buildUserFeed(_userController.loadingState),
                    ],
                  )
                : Center(child: _buildUserInfo(_userController.userState)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppBar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surface
                  .withOpacity(_scrollRatio),
              title: _scrollRatio == 1 && _userController.username != null
                  ? Text(_userController.username!)
                  : null,
              centerTitle: Platform.isIOS,
              actions: _userController.userState is Success
                  ? [
                      IconButton(
                        onPressed: () => Get.toNamed('/search', parameters: {
                          'title': _userController.username!,
                          'pageType': 'user',
                          'pageParam': _uid,
                        }),
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                      ),
                      PopupMenuButton(
                        onSelected: (UserMenuItem item) {
                          switch (item) {
                            case UserMenuItem.Copy:
                              Utils.copyText(
                                  Utils.getShareUrl(_uid, ShareType.u));
                              break;
                            case UserMenuItem.Share:
                              Share.share(Utils.getShareUrl(_uid, ShareType.u));
                              break;
                            case UserMenuItem.Block:
                              SmartDialog.showToast('todo: Block');
                              break;
                            case UserMenuItem.Report:
                              if (Utils.isSupportWebview()) {
                                Utils.report(_uid, ReportType.User);
                              } else {
                                SmartDialog.showToast('not supported');
                              }
                              break;
                            case UserMenuItem.UserInfo:
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  Datum user =
                                      (_userController.userState as Success)
                                          .response;
                                  return AlertDialog(
                                    title: Text(
                                      user.username ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    content: Text(
                                      '''
                                      |uid: ${user.uid}\n
                                      |等级: Lv.${user.level}\n
                                      |性别: ${user.gender == 1 ? '男' : user.gender == 0 ? '女' : '未知'}\n
                                      |注册时长: ${((DateTime.now().microsecondsSinceEpoch ~/ 10e5 - user.regdate!) ~/ 24 ~/ 3600)} 天\n
                                      |注册时间: ${DateFormat('yyyy年MM月dd日 HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(user.regdate * 1000))}
                                      '''
                                          .trimMargin(),
                                    ),
                                  );
                                },
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            UserMenuItem.values
                                .map((item) => PopupMenuItem<UserMenuItem>(
                                      value: item,
                                      child: Text(item.name),
                                    ))
                                .toList(),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
