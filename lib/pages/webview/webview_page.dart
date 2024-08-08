import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/cache_util.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';

// ignore: constant_identifier_names
enum WebviewMenuItem { Refresh, Copy, Open_In_Browser, Clear_Cache, Go_Back }

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final String _url = Get.parameters['url'] ?? '';
  final bool _isLogin = Get.parameters['isLogin'] == '1';
  String? _title;
  double _progress = 0;

  late final InAppWebViewController _webViewController;
  late final _config = Provider.of<AppConfigProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    CookieManager().deleteAllCookies();
    if (_config.isLogin) {
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'DID',
        value: _config.szlmId,
      );
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'forward',
        value: 'https://www.coolapk.com',
      );
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'displayVersion',
        value: 'v14',
      );
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'uid',
        value: _config.uid,
      );
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'username',
        value: _config.username,
      );
      CookieManager().setCookie(
        url: WebUri.uri(Uri.parse('.coolapk.com')),
        name: 'token',
        value: _config.token,
      );
    }
  }

  @override
  void dispose() {
    _webViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title != null
            ? Text(
                _title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: Size.zero,
                child: LinearProgressIndicator(
                  value: _progress,
                ),
              )
            : null,
        actions: [
          PopupMenuButton(
            onSelected: (item) async {
              switch (item) {
                case WebviewMenuItem.Refresh:
                  _webViewController.reload();
                  break;
                case WebviewMenuItem.Copy:
                  WebUri? uri = await _webViewController.getUrl();
                  if (uri != null) {
                    Utils.copyText(uri.toString());
                  }
                  break;
                case WebviewMenuItem.Open_In_Browser:
                  WebUri? uri = await _webViewController.getUrl();
                  if (uri != null) {
                    Utils.launchURL(uri.toString());
                  }
                  break;
                case WebviewMenuItem.Clear_Cache:
                  try {
                    await InAppWebViewController.clearAllCache();
                    await _webViewController.clearHistory();
                    SmartDialog.showToast('已清理');
                  } catch (e) {
                    SmartDialog.showToast(e.toString());
                  }
                  break;
                case WebviewMenuItem.Go_Back:
                  if (await _webViewController.canGoBack()) {
                    _webViewController.goBack();
                  }
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<WebviewMenuItem>>[
              ...WebviewMenuItem.values.sublist(0, 4).map(
                  (item) => PopupMenuItem(value: item, child: Text(item.name))),
              const PopupMenuDivider(),
              PopupMenuItem(
                  value: WebviewMenuItem.Go_Back,
                  child: Text(
                    WebviewMenuItem.Go_Back.name,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  )),
            ],
          )
        ],
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          useHybridComposition: false,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          useShouldOverrideUrlLoading: true,
          useOnDownloadStart: true,
          clearCache: true,
          userAgent: _config.userAgent,
          forceDark: ForceDark.AUTO,
          algorithmicDarkeningAllowed: true,
        ),
        initialUrlRequest:
            URLRequest(url: WebUri.uri(Uri.parse(_url)), headers: {
          'X-Requested-With': Constants.APP_ID,
        }),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        onProgressChanged: (controller, progress) {
          setState(() => _progress = progress / 100);
        },
        onTitleChanged: (controller, title) {
          setState(() => _title = title);
        },
        onCloseWindow: (controller) => Get.back(),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var url = navigationAction.request.url!.toString();

          if (!url.startsWith('http')) {
            var snackBar = SnackBar(
              content: const Text('当前网页将要打开外部链接，是否打开'),
              showCloseIcon: true,
              action: SnackBarAction(
                label: '打开',
                onPressed: () => Utils.launchURL(url),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            return NavigationActionPolicy.CANCEL;
          }

          if (_isLogin && url == Constants.URL_COOLAPK) {
            String uid = (await CookieManager().getCookie(
              url: WebUri.uri(Uri.parse(Constants.URL_COOLAPK)),
              name: 'uid',
            ))
                ?.value;
            String username = (await CookieManager().getCookie(
              url: WebUri.uri(Uri.parse(Constants.URL_COOLAPK)),
              name: 'username',
            ))
                ?.value;
            String token = (await CookieManager().getCookie(
              url: WebUri.uri(Uri.parse(Constants.URL_COOLAPK)),
              name: 'token',
            ))
                ?.value;
            if (!uid.isNullOrEmpty &&
                !username.isNullOrEmpty &&
                !token.isNullOrEmpty) {
              _config.setUid(uid);
              _config.setUsername(username);
              _config.setToken(token);
              _config.setIsLogin(true);
              Get.back(result: true);
            } else {
              Get.back(result: false);
            }
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
        onDownloadStartRequest: (controller, request) {
          showDialog(
              context: context,
              builder: (context) {
                String suggestedFilename = request.suggestedFilename.toString();
                String fileSize =
                    CacheManage.formatSize(request.contentLength.toDouble());
                try {
                  suggestedFilename = Uri.decodeComponent(suggestedFilename);
                } catch (e) {
                  print(e.toString());
                }
                return AlertDialog(
                  title: Text(
                    'Download file: $suggestedFilename ?',
                    style: const TextStyle(fontSize: 18),
                  ),
                  content: SelectableText(request.url.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Close')),
                    TextButton(
                        onPressed: () async {
                          Get.back();
                          Utils.onDownloadFile(
                            request.url.toString(),
                            suggestedFilename,
                          );
                        },
                        child: Text('OK ($fileSize)')),
                  ],
                );
              });
          setState(() => _progress = 1);
        },
      ),
    );
  }
}
