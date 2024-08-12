// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../logic/network/network_repo.dart';
import '../../logic/model/check_info/check.dart';
import '../../utils/extensions.dart';
import '../../utils/global_data.dart';
import '../../utils/storage_util.dart';

class MainController extends GetxController {
  Future<void> checkLoginInfo() async {
    Response response = await NetworkRepo.checkLoginInfo();
    try {
      if (response.statusCode == HttpStatus.ok) {
        CheckInfo responseData = CheckInfo.fromJson(response.data);
        if (!responseData.message.isNullOrEmpty) {
          print(response.data['message']);
          if (response.data['message'] == '登录信息有误') {
            GStorage.setUid('');
            GStorage.setUsername('');
            GStorage.setToken('');
            GStorage.setIsLogin(false);
          }
        } else {
          if (responseData.data != null) {
            GStorage.setUid(responseData.data!.uid.orEmpty);
            GStorage.setUsername(
                Uri.encodeComponent(responseData.data!.username.orEmpty));
            GStorage.setToken(responseData.data!.token.orEmpty);
            GStorage.setIsLogin(true);
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
        GlobalData().SESSID = SESSID.substring(0, SESSID.indexOf(';'));
      }
    } catch (e) {
      print('failed to get SESSID: ${e.toString()}');
    }
  }
}
