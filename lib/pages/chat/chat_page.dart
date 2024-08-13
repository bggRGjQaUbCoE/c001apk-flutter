import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../components/cards/chat_card.dart';
import '../../components/cards/chat_time_card.dart';
import '../../components/common_body.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/chat/chat_controller.dart';
import '../../utils/device_util.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';
import '../feed/reply/emoji_panel.dart';
import '../feed/reply/reply_dialog.dart';

// ignore: constant_identifier_names
enum ChatMenuType { Check, Block, Report }

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late final String _ukey = Get.parameters['ukey'] ?? '';
  late final String _uid = Get.parameters['uid'] ?? '';
  late final String _username = Get.parameters['username'] ?? '';

  late final _chatController = Get.put(
    ChatController(ukey: _ukey),
    tag: _ukey + DeviceUtil.randHexString(8),
  );
  late final _focusNode = FocusNode();

  final _debouncer = Debouncer(milliseconds: 200);
  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _chatController.scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    _autoFocus();
    _focuslistener();
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  _focuslistener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _chatController.setShowEmoji(false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(() {});
    _focusNode.dispose();
    _chatController.editingController.dispose();
    _chatController.scrollController?.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          // 键盘高度
          final viewInsets = EdgeInsets.fromViewPadding(
              View.of(context).viewInsets, View.of(context).devicePixelRatio);
          _debouncer.run(
            () {
              if (mounted) {
                if (_keyboardHeight == 0) {
                  setState(() {
                    _keyboardHeight = _keyboardHeight == 0.0
                        ? viewInsets.bottom
                        : _keyboardHeight;
                  });
                }
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username),
        actions: [
          PopupMenuButton(
              onOpened: () => _focusNode.unfocus(),
              onSelected: (value) {
                switch (value) {
                  case ChatMenuType.Check:
                    Get.toNamed('/u/$_uid');
                    break;
                  case ChatMenuType.Block:
                    GStorage.onBlock(_uid);
                    break;
                  case ChatMenuType.Report:
                    if (Utils.isSupportWebview()) {
                      Utils.report(_uid, ReportType.User);
                    } else {
                      SmartDialog.showToast('not supported');
                    }
                    break;
                }
              },
              itemBuilder: (context) => ChatMenuType.values
                  .map((item) =>
                      PopupMenuItem(value: item, child: Text(item.name)))
                  .toList())
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (_chatController.loadingState.value is Success) {
                  List<Datum> dataList =
                      (_chatController.loadingState.value as Success).response;
                  return ListView.builder(
                    controller: _chatController.scrollController,
                    reverse: true,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      if (index == dataList.length - 1 &&
                          !_chatController.isEnd &&
                          !_chatController.isLoading) {
                        _chatController.onGetData(false);
                      }
                      switch (dataList[index].entityType) {
                        case 'message':
                          return ChatCard(
                            data: dataList[index],
                            isLeft: dataList[index].fromuid.toString() !=
                                GlobalData().uid,
                            onGetImageUrl: () {
                              _chatController.onGetImageUrl(dataList[index].id);
                            },
                            onClearFocus: () => _focusNode.unfocus(),
                            onViewImage: () async {
                              if (_focusNode.hasFocus) {
                                _focusNode.unfocus();
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                              }
                              Get.toNamed('imageview', arguments: {
                                "imgList": [dataList[index].messagePic!],
                              });
                            },
                            onLongPress: () {
                              _focusNode.unfocus();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      clipBehavior: Clip.hardEdge,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: const Text(
                                              '删除',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            onTap: () {
                                              _chatController.onDeleteMsg(
                                                  dataList[index].id);
                                              Get.back();
                                            },
                                          ),
                                          if (!dataList[index]
                                              .message
                                              .isNullOrEmpty)
                                            ListTile(
                                              title: const Text(
                                                '复制',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              onTap: () {
                                                Utils.copyText(
                                                    dataList[index].message!);
                                                Get.back();
                                              },
                                            ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                          );
                        case 'messageExtra':
                          return ChatTimeCard(
                              text: dataList[index].title ?? '');
                      }
                      return ListTile(
                        title: Text(dataList[index].entityType.toString()),
                      );
                    },
                  );
                } else {
                  return Center(child: buildBody(_chatController));
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 6,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            color: Theme.of(context).colorScheme.onInverseSurface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (_focusNode.hasFocus) {
                          _focusNode.unfocus();
                          await Future.delayed(
                              const Duration(milliseconds: 255));
                        }
                        _chatController.setShowEmoji(
                            !_chatController.showEmojiPanel.value);
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      tooltip: 'Emoji',
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _chatController.editingController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: '写私信...',
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_chatController.editingController.text.isNotEmpty) {
                          _chatController.onSendMessage(_uid);
                        }
                      },
                      icon: const Icon(Icons.send),
                      tooltip: 'Send',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => _chatController.showEmojiPanel.value
                      ? SizedBox(
                          width: double.infinity,
                          height: _keyboardHeight,
                          child: EmotePanel(
                            index: 1,
                            onClick: (emoji) {
                              _onChooseEmote(emoji);
                            },
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onChooseEmote(String emoji) {
    final int cursorPosition =
        _chatController.editingController.selection.baseOffset;
    final String currentText = _chatController.editingController.text;
    final String newText = currentText.substring(0, cursorPosition) +
        emoji +
        currentText.substring(cursorPosition);
    _chatController.editingController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition + emoji.length),
    );
  }
}
