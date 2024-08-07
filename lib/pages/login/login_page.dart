import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../logic/model/login/login_response.dart';
import '../../../logic/network/network_repo.dart';
import '../../../providers/app_config_provider.dart';
import '../../../utils/extensions.dart';
import '../../../utils/token_util.dart';
import '../../../utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;
  bool _showClearAccount = false;
  bool _showClearCaptcha = false;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final FocusNode _pwdFocusNode = FocusNode();
  final FocusNode _captchaFocusNode = FocusNode();
  String? _requestHash;
  Uint8List? _captchaImg;

  String urlPreGetParam = '/auth/login?type=mobile';
  String urlGetParam = '/auth/loginByCoolApk';

  late final _config = Provider.of<AppConfigProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    TokenUtils.isPreGetLoginParam = true;
    _onGetLoginParam(urlPreGetParam);
  }

  String? _getParam(List<String>? cookies, String param) {
    return cookies
        ?.where((cookie) => cookie.contains('$param='))
        .toList()
        .lastOrNull
        ?.split(';')
        .firstOrNull
        ?.replaceFirst('$param=', '')
        .trim();
  }

  Future<void> _onGetCaptcha() async {
    TokenUtils.isGetCaptcha = true;
    try {
      Response response = await NetworkRepo.getLoginParam(
          '/auth/showCaptchaImage?${DateTime.now().microsecondsSinceEpoch ~/ 1000}',
          Options(responseType: ResponseType.bytes));
      setState(() => _captchaImg = response.data);
    } catch (e) {
      SmartDialog.showToast('无法获取验证码: $e');
      print(e.toString());
    }
  }

  void _beforeLogin() {
    if (_accountController.text.isEmpty || _pwdController.text.isEmpty) {
      SmartDialog.showToast('账号或密码为空');
    } else {
      _onLogin();
    }
  }

  Future<void> _onLogin() async {
    TokenUtils.isOnLogin = true;
    try {
      Response response = await NetworkRepo.onLogin(
          _requestHash!,
          _accountController.text,
          _pwdController.text,
          _captchaController.text);
      LoginResponse loginResponse =
          LoginResponse.fromJson(jsonDecode(response.data));
      if (loginResponse.status == 1) {
        List<String>? cookies = response.headers['Set-Cookie'];
        String? uid = _getParam(cookies, 'uid');
        String? username = _getParam(cookies, 'username');
        String? token = _getParam(cookies, 'token');
        if (!uid.isNullOrEmpty &&
            !username.isNullOrEmpty &&
            !token.isNullOrEmpty) {
          _config
            ..setUid(uid!)
            ..setUsername(username!)
            ..setToken(token!)
            ..setIsLogin(true);
          SmartDialog.showToast('登录成功');
          Get.back(result: true);
        }
      } else {
        if (!loginResponse.message.isNullOrEmpty) {
          SmartDialog.showToast(loginResponse.message!);
        }
        if (loginResponse.message == '图形验证码不能为空", "图形验证码错误' ||
            (_captchaImg != null && loginResponse.message == '密码错误')) {
          _onGetCaptcha();
        }
      }
    } catch (e) {
      SmartDialog.showToast('登陆失败: $e');
      print(e.toString());
    }
  }

  Future<void> _onGetLoginParam(String url) async {
    try {
      Response response = await NetworkRepo.getLoginParam(url);
      if (url == urlGetParam) {
        try {
          dom.Document document = parse(response.data);
          setState(() => _requestHash = document
              .getElementsByTagName('Body')[0]
              .attributes['data-request-hash']);
        } catch (e) {
          SmartDialog.showToast('无法获取requestHash: $e');
          print('failed to get requestHash: ${e.toString()}');
        }
      }
      try {
        String? SESSID = response.headers['Set-Cookie']?[0];
        if (SESSID != null) {
          _config.setSESSID(SESSID.substring(0, SESSID.indexOf(';')));
        }
      } catch (e) {
        SmartDialog.showToast('无法获取SESSID: $e');
        print('failed to get SESSID: ${e.toString()}');
      }
      if (url == urlPreGetParam) {
        TokenUtils.isGetLoginParam = true;
        _onGetLoginParam(urlGetParam);
      }
    } catch (e) {
      SmartDialog.showToast('无法获取参数: $e');
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _pwdController.dispose();
    _captchaController.dispose();
    _pwdFocusNode.dispose();
    _captchaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        bottom: const PreferredSize(
          preferredSize: Size.zero,
          child: Divider(height: 1),
        ),
        actions: [
          if (Utils.isSupportWebview())
            TextButton(
              onPressed: () async {
                dynamic result = await Get.toNamed('/webview', parameters: {
                  'url': Constants.URL_LOGIN,
                  'isLogin': '1',
                });
                if (result == true) {
                  SmartDialog.showToast('登录成功');
                  Get.back(result: true);
                } else if (result == false) {
                  SmartDialog.showToast('网页登录失败');
                }
              },
              child: const Text('网页登录'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _accountController,
              autofocus: true,
              onChanged: (value) =>
                  setState(() => _showClearAccount = value.isNotEmpty),
              textInputAction: TextInputAction.next,
              onSubmitted: (value) => _pwdFocusNode.requestFocus(),
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: '账号',
                suffixIcon: _showClearAccount
                    ? IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _accountController.clear();
                          setState(() => _showClearAccount = false);
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              focusNode: _pwdFocusNode,
              controller: _pwdController,
              obscureText: !_showPassword,
              textInputAction: _captchaImg != null
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: (value) {
                if (_captchaImg != null) {
                  _captchaFocusNode.requestFocus();
                } else {
                  _beforeLogin();
                }
              },
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                filled: true,
                labelText: '密码',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
            ),
            if (_captchaImg != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => _onGetCaptcha(),
                      child: Image.memory(_captchaImg!),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _captchaController,
                      focusNode: _captchaFocusNode,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z]")),
                      ],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) => _beforeLogin(),
                      onChanged: (value) =>
                          setState(() => _showClearCaptcha = value.isNotEmpty),
                      decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        filled: true,
                        labelText: 'captcha',
                        suffixIcon: _showClearCaptcha
                            ? IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  setState(() =>
                                      _showClearCaptcha = !_showClearCaptcha);
                                  _captchaController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: _requestHash.isNullOrEmpty
                  ? null
                  : () {
                      _beforeLogin();
                    },
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}
