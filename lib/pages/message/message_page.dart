import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:provider/provider.dart';

import '../../components/cards/message_first_card.dart';
import '../../components/cards/message_header_card.dart';
import '../../components/cards/message_second_card.dart';
import '../../components/cards/message_third_card.dart';
import '../../components/footer.dart';
import '../../components/item_card.dart';
import '../../components/sliver_pinned_box_adapter.dart';
import '../../logic/model/check_count/check_count.dart';
import '../../logic/model/check_count/datum.dart' as checkcountdata;
import '../../logic/model/feed/data_model.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/network/network_repo.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/message/message_controller.dart';
import '../../pages/noitfication/notification_page.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/global_data.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  late final _config = Provider.of<AppConfigProvider>(context, listen: false);
  final _backgroundList = [
    0xFF2196f3,
    0xFF00bcd4,
    0xFF4caf50,
    0xFFf44336,
    0xFFff9800,
  ];
  final _titleList = ['@我的动态', '@我的评论', '我收到的赞', '好友关注', '私信'];
  final _iconList = [
    Icons.alternate_email,
    Icons.message_outlined,
    Icons.thumb_up_alt_outlined,
    Icons.person_add_outlined,
    Icons.mail_outline,
  ];
  late final MessageController _messageController =
      Get.put(MessageController());

  List<int?>? _firstList;
  List<int?>? _thirdList;

  bool _isRefreshing = false;

  Future<void> _checkCount() async {
    try {
      Response response = await NetworkRepo.checkCount();
      checkcountdata.Datum? data = CheckCount.fromJson(response.data).data;
      setState(() => _thirdList = [
            data?.atme,
            data?.atcommentme,
            data?.feedlike,
            data?.contactsFollow,
            data?.message,
          ]);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _getProfile() async {
    try {
      Response response = await NetworkRepo.getProfile(GlobalData().uid);
      Datum? data = DataModel.fromJson(response.data).data;
      String username = data?.username ?? '';
      try {
        username = Uri.encodeComponent(username);
      } catch (e) {
        print(e.toString());
      }
      _config
        ..setUserAvatar(data?.userAvatar ?? '')
        ..setUsername(username)
        ..setLevel(data?.level ?? 0)
        ..setExp(data?.experience ?? 0)
        ..setNextExp(data?.nextLevelExperience ?? 1);
      setState(() => _firstList = [data?.feed, data?.follow, data?.fans]);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _messageController.scrollController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_config.isLogin) {
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    _messageController.onReset();
    await _getProfile();
    await _checkCount();
    await _messageController.onGetData();
    _isRefreshing = false;
  }

  Widget _buildMessage(LoadingState loadingState) {
    switch (loadingState) {
      case Empty():
        return SliverToBoxAdapter(
          child: Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: const Text('EMPTY'),
          ),
        );
      case Error():
        return SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() => loadingState = LoadingState.loading());
              }
              _onRefresh();
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
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          sliver: SliverList.separated(
            itemCount: dataList.length + 1,
            itemBuilder: (_, index) {
              if (index == dataList.length) {
                if (!_isRefreshing &&
                    !_messageController.isEnd &&
                    !_messageController.isLoading) {
                  _messageController.onGetData(false);
                }
                return Obx(() =>
                    footerWidget(_messageController.footerState.value, () {
                      _messageController.isEnd = false;
                      _messageController.setFooterState(LoadingState.loading());
                      _messageController.onGetData(false);
                    }));
              } else {
                return itemCard(
                  dataList[index],
                  onBlock: _messageController.onBlock,
                );
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
    return RefreshIndicator(
      onRefresh: () async {
        if (_config.isLogin) {
          _isRefreshing = true;
          await _onRefresh();
        } else {
          return Future.value();
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPinnedBoxAdapter(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    MessageHeaderCard(
                      onLogin: () async {
                        if (await Get.toNamed('/login')) {
                          _onRefresh();
                        }
                      },
                      onLogout: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('确定退出登录？'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _firstList = null;
                                      _thirdList = null;

                                      _config
                                        ..setUid('')
                                        ..setUsername('')
                                        ..setToken('')
                                        ..setUserAvatar('')
                                        ..setLevel(0)
                                        ..setExp(0)
                                        ..setNextExp(1)
                                        ..setIsLogin(false);
                                      _messageController.setLoadingState(
                                          LoadingState.loading());
                                      _messageController.setFooterState(
                                          LoadingState.loading());
                                      Get.back();
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1)
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList.separated(
              itemCount: 7,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return messageFirstCard(_config.isLogin, context, _firstList);
                } else if (index == 1) {
                  return messageSeconfCard(_config.isLogin, context);
                } else if (index >= 2 && index <= 6) {
                  return messageThirdCard(
                    context,
                    _backgroundList[index - 2],
                    _iconList[index - 2],
                    _titleList[index - 2],
                    _thirdList?[index - 2],
                    () {
                      if (_config.isLogin) {
                        Get.toNamed('/notification', arguments: {
                          'type': NotificationType.values[index - 2]
                        });
                        setState(() => _thirdList?[index - 2] = null);
                      }
                    },
                  );
                }
                return const SizedBox();
              },
              separatorBuilder: (_, index) => const SizedBox(height: 10),
            ),
          ),
          if (_config.isLogin)
            Obx(() => _buildMessage(_messageController.loadingState.value)),
        ],
      ),
    );
  }
}
