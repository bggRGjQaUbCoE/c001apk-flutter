import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chat_bottom_container/chat_bottom_container.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide FormData;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../../components/cards/chat_card.dart';
import '../../components/cards/chat_time_card.dart';
import '../../components/common_body.dart';
import '../../logic/model/feed/datum.dart';
import '../../logic/model/oss_upload/datum.dart';
import '../../logic/model/oss_upload/oss_upload_model.dart';
import '../../logic/state/loading_state.dart';
import '../../pages/chat/chat_controller.dart';
import '../../pages/feed/reply/emoji_panel.dart';
import '../../utils/device_util.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/oss/aliyunoss_client.dart';
import '../../utils/oss/aliyunoss_config.dart';
import '../../utils/oss_util.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

enum PanelType { none, keyboard, emoji }

// ignore: constant_identifier_names
enum ChatMenuType { Check, Block, Report }

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final String _ukey;
  late final String _uid;
  late final String _username;

  late final String _random = DeviceUtil.randHexString(8);
  late final _chatController = Get.put(
    ChatController(ukey: _ukey),
    tag: _ukey + _random,
  );
  late final _focusNode = FocusNode();
  late final _controller = ChatBottomPanelContainerController<PanelType>();
  PanelType _currentPanelType = PanelType.none;
  bool readOnly = false;
  late final _enableSend = StreamController<bool>();
  late bool _visibleSend = false;
  late final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ukey = Get.parameters['ukey'] ?? '';
    _uid = Get.parameters['uid'] ?? '';
    _username = Get.parameters['username'] ?? '';
    _chatController.scrollController = ScrollController();

    _enableSend.add(false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _chatController.editingController.dispose();
    _chatController.scrollController?.dispose();
    Get.delete<ChatController>(
      tag: _ukey + _random,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_username),
        actions: [
          PopupMenuButton(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _buildList()),
          _buildInputView(),
          _buildPanelContainer(),
        ],
      ),
    );
  }

  Widget _buildList() {
    Widget resultWidget = Obx(
      () {
        if (_chatController.loadingState.value is Success) {
          List<Datum> dataList =
              (_chatController.loadingState.value as Success).response;
          return ListView.builder(
            padding: EdgeInsets.zero,
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
                    isLeft:
                        dataList[index].fromuid.toString() != GlobalData().uid,
                    onGetImageUrl: () {
                      _chatController.onGetImageUrl(dataList[index].id);
                    },
                    onViewImage: () async {
                      if (_focusNode.hasFocus) {
                        await Future.delayed(const Duration(milliseconds: 500));
                      }
                      Get.toNamed('imageview', arguments: {
                        "imgList": [dataList[index].messagePic!],
                      });
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              clipBehavior: Clip.hardEdge,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text(
                                      '删除',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    onTap: () {
                                      _chatController
                                          .onDeleteMsg(dataList[index].id);
                                      Get.back();
                                    },
                                  ),
                                  if (!dataList[index].message.isNullOrEmpty)
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
                  return ChatTimeCard(text: dataList[index].title ?? '');
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
    );
    resultWidget = Listener(
      child: resultWidget,
      onPointerDown: (event) {
        // Hide panel when touch ListView.
        hidePanel();
      },
    );
    return resultWidget;
  }

  Widget _buildPanelContainer() {
    return ChatBottomPanelContainer<PanelType>(
      controller: _controller,
      inputFocusNode: _focusNode,
      otherPanelWidget: (type) {
        if (type == null) return const SizedBox.shrink();
        switch (type) {
          case PanelType.emoji:
            return _buildEmojiPickerPanel();
          default:
            return const SizedBox.shrink();
        }
      },
      onPanelTypeChange: (panelType, data) {
        debugPrint('panelType: $panelType');
        switch (panelType) {
          case ChatBottomPanelType.none:
            _currentPanelType = PanelType.none;
            break;
          case ChatBottomPanelType.keyboard:
            _currentPanelType = PanelType.keyboard;
            break;
          case ChatBottomPanelType.other:
            if (data == null) return;
            switch (data) {
              case PanelType.emoji:
                _currentPanelType = PanelType.emoji;
                break;
              default:
                _currentPanelType = PanelType.none;
                break;
            }
            break;
        }
      },
      panelBgColor: Theme.of(context).colorScheme.onInverseSurface,
    );
  }

  Widget _buildEmojiPickerPanel() {
    double height = 300;
    final keyboardHeight = _controller.keyboardHeight;
    if (keyboardHeight != 0) {
      height = keyboardHeight;
    }

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      height: height,
      child: EmotePanel(
        index: 1,
        onClick: (emoji) {
          if (!_visibleSend) {
            _visibleSend = true;
            _enableSend.add(true);
          }
          _onChooseEmote(emoji);
        },
      ),
    );
  }

  Widget _buildInputView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () async {
              updatePanelType(
                PanelType.emoji == _currentPanelType
                    ? PanelType.keyboard
                    : PanelType.emoji,
              );
            },
            icon: const Icon(Icons.emoji_emotions_outlined),
            tooltip: 'Emoji',
          ),
          Expanded(
            child: Listener(
              onPointerUp: (event) {
                // Currently it may be emojiPanel.
                if (readOnly) {
                  updatePanelType(PanelType.keyboard);
                }
              },
              child: TextField(
                readOnly: readOnly,
                focusNode: _focusNode,
                controller: _chatController.editingController,
                minLines: 1,
                maxLines: 4,
                onChanged: (value) {
                  if (value.isNotEmpty && !_visibleSend) {
                    _visibleSend = true;
                    _enableSend.add(true);
                  } else if (value.isEmpty && _visibleSend) {
                    _visibleSend = false;
                    _enableSend.add(false);
                  }
                },
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  filled: true,
                  hintText: '写私信...',
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(4),
                    gapPadding: 0,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
          ),
          StreamBuilder(
              stream: _enableSend.stream,
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: () async {
                    if (snapshot.data == true) {
                      _chatController.onSendMessage(_uid);
                    } else {
                      XFile? pickedFile = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (pickedFile != null) {
                        SmartDialog.showLoading(msg: '正在加载');
                        Uint8List imageBytes = await pickedFile.readAsBytes();
                        ui.Image image = await decodeImageFromList(imageBytes);
                        int width = image.width;
                        int height = image.height;
                        Digest md5Hash = md5.convert(imageBytes);
                        String mimeType =
                            lookupMimeType(pickedFile.path) ?? 'image/png';
                        String name =
                            '${const Uuid().v1().replaceAll('-', '')}.${mimeType.replaceFirst('image/', '')}';
                        OssUploadModel uploadModel = OssUploadModel(
                          name: name,
                          resolution: '${width}x$height',
                          md5: md5Hash.toString(),
                        );
                        OssDatum? data = await OssUtil.onPostOSSUploadPrepare(
                          'message',
                          'message',
                          [uploadModel],
                          uid: _uid,
                        );
                        if (data != null) {
                          SmartDialog.showLoading(msg: '正在上传图片');
                          AliyunOssClient client = AliyunOssClient(
                            accessKeyId: data.uploadPrepareInfo!.accessKeyId!,
                            accessKeySecret:
                                data.uploadPrepareInfo!.accessKeySecret!,
                            securityToken:
                                data.uploadPrepareInfo!.securityToken!,
                          );
                          AliyunOssConfig config = AliyunOssConfig(
                            endpoint: data.uploadPrepareInfo!.endPoint!,
                            bucket: data.uploadPrepareInfo!.bucket!,
                            directory: "message",
                          );
                          AliyunOssResult result = await client.upload(
                            id: '1',
                            config: config,
                            ossFileName: data.fileInfo![0].uploadFileName!
                                .replaceFirst('message', ''),
                            filePath: pickedFile.path,
                          );
                          if (result.state == AliyunOssResultState.success) {
                            _chatController.onSendMessage(
                              _uid,
                              pic: '/${data.fileInfo![0].uploadFileName}',
                            );
                          } else if (result.state ==
                              AliyunOssResultState.fail) {
                            SmartDialog.dismiss();
                            SmartDialog.showToast('上传失败: ${result.msg}');
                          }
                        }
                      }
                    }
                  },
                  icon: Icon(snapshot.data == true
                      ? Icons.send
                      : Icons.image_outlined),
                  tooltip: snapshot.data == true ? 'Send' : 'Image',
                );
              }),
        ],
      ),
    );
  }

  updatePanelType(PanelType type) async {
    final isSwitchToKeyboard = PanelType.keyboard == type;
    final isSwitchToEmojiPanel = PanelType.emoji == type;
    bool isUpdated = false;
    switch (type) {
      case PanelType.keyboard:
        updateInputView(isReadOnly: false);
        break;
      case PanelType.emoji:
        isUpdated = updateInputView(isReadOnly: true);
        break;
      default:
        break;
    }

    updatePanelTypeFunc() {
      _controller.updatePanelType(
        isSwitchToKeyboard
            ? ChatBottomPanelType.keyboard
            : ChatBottomPanelType.other,
        data: type,
        forceHandleFocus: isSwitchToEmojiPanel
            ? ChatBottomHandleFocus.requestFocus
            : ChatBottomHandleFocus.none,
      );
    }

    if (isUpdated) {
      // Waiting for the input view to update.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        updatePanelTypeFunc();
      });
    } else {
      updatePanelTypeFunc();
    }
  }

  hidePanel() async {
    if (_focusNode.hasFocus) {
      await Future.delayed(const Duration(milliseconds: 100));
      _focusNode.unfocus();
    }
    updateInputView(isReadOnly: false);
    if (ChatBottomPanelType.none == _controller.currentPanelType) return;
    _controller.updatePanelType(ChatBottomPanelType.none);
  }

  bool updateInputView({
    required bool isReadOnly,
  }) {
    if (readOnly != isReadOnly) {
      readOnly = isReadOnly;
      // You can just refresh the input view.
      setState(() {});
      return true;
    }
    return false;
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
