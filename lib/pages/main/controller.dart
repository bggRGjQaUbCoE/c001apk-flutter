// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:provider/provider.dart';

import '../../logic/network/network_repo.dart';
import '../../logic/model/check_info/check.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/extensions.dart';

class MainController extends GetxController {
  final _config = Provider.of<AppConfigProvider>(Get.context!, listen: false);

  Future<void> checkLoginInfo() async {
    Response response = await NetworkRepo.checkLoginInfo();
    try {
      if (response.statusCode == HttpStatus.ok) {
        CheckInfo responseData = CheckInfo.fromJson(response.data);
        if (!responseData.message.isNullOrEmpty) {
          print(response.data['message']);
          if (response.data['message'] == '登录信息有误') {
            _config.setUid('');
            _config.setUsername('');
            _config.setToken('');
            _config.setIsLogin(false);
          }
        } else {
          if (responseData.data != null) {
            _config.setUid(responseData.data!.uid.orEmpty);
            _config.setUsername(
                Uri.encodeComponent(responseData.data!.username.orEmpty));
            _config.setToken(responseData.data!.token.orEmpty);
            _config.setIsLogin(true);
          } else {
            print('null');
          }
        }
      } else {
        print('statusCode: ${response.statusCode}');
      }
    } catch (e) {
      print('failed to get token: ${e.toString()}');
    }

    try {
      String? SESSID = response.headers['Set-Cookie']?[0];
      if (SESSID != null) {
        _config.setSESSID(SESSID.substring(0, SESSID.indexOf(';')));
      }
    } catch (e) {
      print('failed to get SESSID: ${e.toString()}');
    }
  }
}
