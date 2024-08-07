import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../constants/constants.dart';

class TokenUtils {
  static bool isPreGetLoginParam = false;
  static bool isGetLoginParam = false;
  static bool isOnLogin = false;
  static bool isGetCaptcha = false;

  static String createRandomNumber() {
    return Random().nextDouble().toString().replaceAll('.', 'undefined');
  }

  static Future<String> encodeDevice(String deviceInfo) async {
    var bytes = utf8.encode(deviceInfo);
    var base64Str = base64Encode(bytes);
    var reversedStr = base64Str.split('').reversed.join();
    var cleanedStr = reversedStr.replaceAll(
        RegExp(r'(\r\n|\r|\n|=)'), Constants.EMPTY_STRING);
    return cleanedStr;
  }

  static String getTokenV2(String deviceCode) {
    var timeStamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    var base64TimeStamp = getBase64(timeStamp);
    var md5TimeStamp = _getMD5(timeStamp);
    var md5DeviceCode = _getMD5(deviceCode);
    var token =
        '${Constants.APP_LABEL}?$md5TimeStamp\$$md5DeviceCode&${Constants.APP_ID}';
    var base64Token = getBase64(token);
    var md5Base64Token = _getMD5(base64Token);
    var md5Token = _getMD5(token);
    var bcryptSalt =
        '${"\$2a\$10\$$base64TimeStamp/$md5Token".substring(0, 31)}u';
    var bcryptResult = BCrypt.hashpw(md5Base64Token, bcryptSalt);
    return 'v2${base64Encode(utf8.encode(bcryptResult.replaceRange(0, 3, "\$2y"))).replaceAll("=", "")}';
  }

  static String getBase64(String input) {
    return base64Encode(utf8.encode(input)).replaceAll('=', '');
  }

  static String _getMD5(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString().replaceAll('-', '');
  }
}
