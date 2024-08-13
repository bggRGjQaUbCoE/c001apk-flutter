import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/cards/search_history_card.dart';
import '../../pages/blacklist/black_list_controller.dart';
import '../../utils/date_util.dart';

enum BlackListType { user, topic }

class BlackListPage extends StatefulWidget {
  const BlackListPage({super.key});

  @override
  State<BlackListPage> createState() => _BlackListPageState();
}

class _BlackListPageState extends State<BlackListPage> {
  late final BlackListType _type = Get.arguments['type'];

  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _shouldShowClearBtn = false;

  late final _controller = Get.put(
    BlackListController(type: _type),
    tag: _type.name,
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: TextField(
            focusNode: _focusNode,
            controller: _textController,
            onTap: () => _focusNode.requestFocus(),
            style: const TextStyle(fontSize: 18),
            onChanged: (value) =>
                setState(() => _shouldShowClearBtn = value.isNotEmpty),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _type == BlackListType.user ? 'uid' : 'topic',
              hintStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            // keyboardType:
            // _type == BlackListType.User ? TextInputType.number : null,
            inputFormatters: _type == BlackListType.user
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _textController.clear();
                _controller.handleData(value);
                setState(() => _shouldShowClearBtn = false);
              }
              _focusNode.requestFocus();
            },
          ),
          actions: [
            if (_shouldShowClearBtn)
              IconButton(
                onPressed: () {
                  _textController.clear();
                  _focusNode.requestFocus();
                  setState(() => _shouldShowClearBtn = false);
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
              ),
            if (_controller.dataList.isNotEmpty)
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                        '确定清除全部${_type == BlackListType.user ? '用户' : '话题'}黑名单？'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          _controller.clearAll();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.clear_all),
                tooltip: 'Clear All',
              ),
            IconButton(
              onPressed: () {
                if (_controller.dataList.isNotEmpty) {
                  try {
                    Share.shareXFiles([
                      XFile.fromData(
                          utf8.encode(_controller.dataList.toString()),
                          mimeType: 'text/plain')
                    ], fileNameOverrides: [
                      '${_type.name}-blacklist_${DateUtil.format(DateTime.now().microsecondsSinceEpoch ~/ 1000)}.json'
                    ]);
                  } catch (e) {
                    SmartDialog.showToast('导出失败');
                    print(e.toString());
                  }
                }
              },
              icon: const Icon(Icons.file_upload_outlined),
              tooltip: 'Export',
            ),
            IconButton(
              onPressed: () async {
                try {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    File file = File(result.files.single.path ?? '');
                    String dataString = await file.readAsString();
                    List<String> dataList =
                        (jsonDecode(dataString) as List<dynamic>)
                            .map((data) => data.toString())
                            .toList();
                    await _controller.onImport(dataList);
                    SmartDialog.showToast('导入成功');
                  }
                } catch (e) {
                  SmartDialog.showToast('导入失败');
                  print(e.toString());
                }
              },
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Import',
            ),
          ],
          bottom: const PreferredSize(
              preferredSize: Size.zero, child: Divider(height: 1)),
        ),
        body: _controller.dataList.isNotEmpty
            ? SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 10 + MediaQuery.of(context).padding.bottom,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _controller.dataList
                      .map(
                        (text) => SearchHistoryCard(
                          text: text,
                          onTap: () {
                            try {
                              Get.toNamed(
                                  '/${_type == BlackListType.user ? 'u' : 't'}/$text');
                            } catch (e) {
                              try {
                                Get.toNamed(
                                    '/${_type == BlackListType.user ? 'u' : 't'}/${Uri.encodeComponent(text)}');
                              } catch (e) {
                                print('failed to view $text');
                              }
                            }
                          },
                          onLongPress: () => _controller.handleData(text, true),
                        ),
                      )
                      .toList(),
                ),
              )
            : const Center(
                child: Text('EMPTY'),
              ),
      ),
    );
  }
}
