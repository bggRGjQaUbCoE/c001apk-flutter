import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response, FormData;

import '../../../logic/model/feed/data_model.dart';
import '../../../logic/model/login/login_response.dart';
import '../../../logic/network/network_repo.dart';
import '../../../pages/feed/reply/emoji_panel.dart';
import '../../../pages/feed/reply/toolbar_icon_button.dart';
import '../../../utils/extensions.dart';

/// From Pilipala

enum ReplyType { feed, reply }

class ReplyDialog extends StatefulWidget {
  const ReplyDialog({
    super.key,
    this.type,
    this.id,
    this.username,
    this.targetType,
    this.targetId,
    this.title,
  });

  final ReplyType? type;
  final dynamic id;
  final String? username;
  final String? targetType;
  final dynamic targetId;
  final String? title;

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> with WidgetsBindingObserver {
  late final TextEditingController _replyContentController =
      TextEditingController(
          text: widget.targetType == 'tag' ? '#${widget.title}# ' : null);
  final FocusNode _replyContentFocusNode = FocusNode();
  late double _emoteHeight = 0.0;
  double _keyboardHeight = 0.0; // 键盘高度
  final _debouncer = Debouncer(milliseconds: 200); // 设置延迟时间
  String _toolbarType = 'input';
  bool _enablePublish = false;
  final TextEditingController _captchaController = TextEditingController();
  bool _checkBoxValue = false;

  @override
  void initState() {
    super.initState();
    // 监听输入框聚焦
    // replyContentFocusNode.addListener(_onFocus);
    // 界面观察者 必须
    WidgetsBinding.instance.addObserver(this);
    // 自动聚焦
    _autoFocus();
    // 监听聚焦状态
    _focuslistener();
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _replyContentFocusNode.requestFocus();
    }
  }

  _focuslistener() {
    _replyContentFocusNode.addListener(() {
      if (_replyContentFocusNode.hasFocus) {
        setState(() => _toolbarType = 'input');
      }
    });
  }

  Future _onPublish() async {
    try {
      SmartDialog.showLoading();
      if (widget.id == null) {
        Response response = await NetworkRepo.postCreateFeed(
          FormData.fromMap(
            {
              'type': 'feed',
              if (widget.targetType != null) 'targetType': widget.targetType,
              if (widget.targetType == 'apk') 'type': 'comment',
              if (widget.targetId != null) 'targetId': widget.targetId,
              'message': _replyContentController.text,
              'status': _checkBoxValue ? -1 : 1,
            },
          ),
        );
        LoginResponse data = LoginResponse.fromJson(response.data);
        if (!data.message.isNullOrEmpty) {
          SmartDialog.dismiss();
          SmartDialog.showToast(data.message!);
          if (data.messageStatus == 'err_request_captcha') {
            _onGetCaptcha();
          }
        } else if (data.data != null) {
          SmartDialog.dismiss();
          SmartDialog.showToast('发布成功');
          Get.back();
        }
      } else {
        Response response = await NetworkRepo.postReply(
          FormData.fromMap({
            'message': _replyContentController.text,
            'replyAndForward': _checkBoxValue ? 1 : 0,
          }),
          widget.id,
          widget.type!.name,
        );
        DataModel data = DataModel.fromJson(response.data);
        if (!data.message.isNullOrEmpty) {
          SmartDialog.dismiss();
          SmartDialog.showToast(data.message!);
          if (data.messageStatus == 'err_request_captcha') {
            _onGetCaptcha();
          }
        } else if (response.data != null) {
          SmartDialog.dismiss();
          Get.back(result: {'data': data.data});
        }
      }
    } catch (e) {
      SmartDialog.dismiss();
      debugPrint(e.toString());
    }
  }

  Future<void> _onGetCaptcha() async {
    try {
      Response response = await NetworkRepo.getValidateCaptcha();
      if (mounted) {
        _captchaController.clear();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Captcha'),
            content: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.memory(response.data),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _captchaController,
                      autofocus: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z]")),
                      ],
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        labelText: 'captcha',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _postRequestValidate();
                },
                child: const Text('验证并继续'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      SmartDialog.showToast('无法获取验证码: $e');
      debugPrint(e.toString());
    }
  }

  Future<void> _postRequestValidate() async {
    try {
      Response response = await NetworkRepo.postRequestValidate(
        FormData.fromMap({
          'type': 'err_request_captcha',
          'code': _captchaController.text,
        }),
      );
      LoginResponse data = LoginResponse.fromJson(response.data);
      if (data.data == '验证通过') {
        _onPublish();
      } else if (!data.message.isNullOrEmpty) {
        SmartDialog.showToast(data.message!);
        if (data.message == "请输入正确的图形验证码") {
          _onGetCaptcha();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onChooseEmote(String emoji) {
    final int cursorPosition = _replyContentController.selection.baseOffset;
    final String currentText = _replyContentController.text;
    final String newText = currentText.substring(0, cursorPosition) +
        emoji +
        currentText.substring(cursorPosition);
    _replyContentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition + emoji.length),
    );
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
                if (_keyboardHeight == 0 && _emoteHeight == 0) {
                  setState(() {
                    _emoteHeight = _keyboardHeight = _keyboardHeight == 0.0
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replyContentController.dispose();
    _captchaController.dispose();
    _replyContentFocusNode.removeListener(() {});
    _replyContentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = EdgeInsets.fromViewPadding(
            View.of(context).viewInsets, View.of(context).devicePixelRatio)
        .bottom;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
              minHeight: 120,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, right: 15, left: 15, bottom: 10),
              child: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextField(
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 500,
                    autofocus: false,
                    focusNode: _replyContentFocusNode,
                    controller: _replyContentController,
                    onChanged: (value) => setState(() =>
                        _enablePublish = value.replaceAll('\n', '').isNotEmpty),
                    decoration: InputDecoration(
                        hintText: widget.username != null
                            ? '回复: ${widget.username}'
                            : '发布${widget.title != null ? '于 ${widget.title}' : '动态'}',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                        )),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToolbarIconButton(
                  onPressed: () {
                    if (_toolbarType == 'emote') {
                      setState(() => _toolbarType = 'input');
                    }
                    _replyContentFocusNode.requestFocus();
                  },
                  icon: const Icon(Icons.keyboard, size: 22),
                  toolbarType: _toolbarType,
                  selected: _toolbarType == 'input',
                ),
                const SizedBox(width: 20),
                ToolbarIconButton(
                  onPressed: () {
                    if (_toolbarType == 'input') {
                      setState(() => _toolbarType = 'emote');
                    }
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.emoji_emotions, size: 22),
                  toolbarType: _toolbarType,
                  selected: _toolbarType == 'emote',
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      setState(() => _checkBoxValue = !_checkBoxValue),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        side: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.outline),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).colorScheme.primary;
                          }
                          return null;
                        }),
                        value: _checkBoxValue,
                        onChanged: null,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                      Text(
                        widget.type == null ? '仅自己可见' : '回复并转发',
                        style: TextStyle(
                          height: 1,
                          color: _checkBoxValue
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.outline,
                        ),
                        strutStyle: const StrutStyle(height: 1, leading: 0),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _enablePublish ? _onPublish : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                  ),
                  child: const Text('发布'),
                ),
              ],
            ),
          ),
          AnimatedSize(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              height: _toolbarType == 'input'
                  ? (keyboardHeight > _keyboardHeight
                      ? keyboardHeight
                      : _keyboardHeight)
                  : _emoteHeight,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: EmotePanel(
                index: 1,
                onClick: (emoji) {
                  _onChooseEmote(emoji);
                  if (!_enablePublish) {
                    setState(() => _enablePublish = true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef DebounceCallback = void Function();

class Debouncer {
  DebounceCallback? callback;
  final int? milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(DebounceCallback callback) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), () {
      callback();
    });
  }
}
