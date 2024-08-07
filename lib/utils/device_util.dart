import 'dart:math';

import '../../../constants/constants.dart';

class DeviceUtil {
  static bool isPreGetLoginParam = false;
  static bool isGetLoginParam = false;
  static bool isTryLogin = false;
  static bool isGetCaptcha = false;
  static bool isGetSmsLoginParam = false;
  static bool isGetSmsToken = false;

  static int? atme;
  static int? atcommentme;
  static int? feedlike;
  static int? contacts_follow;
  static int? message;
  static int notification = 0;

  static String SESSID = Constants.EMPTY_STRING;

  static String randHexString(int length, [bool toUpperCase = true]) {
    const chars = '0123456789abcdef';
    final hexString = StringBuffer();
    for (int i = 0; i < length; i++) {
      hexString.write(chars[Random().nextInt(chars.length)]);
    }

    return toUpperCase
        ? hexString.toString().toUpperCase()
        : hexString.toString();
  }

  static String randomMacAddress() {
    final macBytes = List<int>.generate(6, (_) => Random().nextInt(256));
    macBytes[0] = (macBytes[0] & 0xFE) | 0x02;
    return macBytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  static String randomManufacturer() {
    const manufacturers = [
      'Samsung',
      'Google',
      'Huawei',
      'Xiaomi',
      'OnePlus',
      'Sony',
      'LG',
      'Motorola',
      'HTC',
      'Nokia',
      'Lenovo',
      'Asus',
      'ZTE',
      'Alcatel',
      'OPPO',
      'Vivo',
      'Realme'
    ];
    return manufacturers[Random().nextInt(manufacturers.length)];
  }

  static String randomBrand() {
    const brands = [
      'Samsung',
      'Google',
      'Huawei',
      'Xiaomi',
      'Redmi',
      'OnePlus',
      'Sony',
      'LG',
      'Motorola',
      'HTC',
      'Nokia',
      'Lenovo',
      'Asus',
      'ZTE',
      'Alcatel',
      'OPPO',
      'Vivo',
      'Realme'
    ];
    return brands[Random().nextInt(brands.length)];
  }

  static String randomDeviceModel() {
    return randHexString(6);
  }

  static String randomSdkInt() {
    return (Random().nextInt(14) + 21).toString();
  }

  static String randomAndroidVersionRelease() {
    const androidVersionReleases = [
      '5.0.1',
      '6.0',
      '7.0',
      '7.1.1',
      '8.0.0',
      '8.1.0',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14'
    ];
    return androidVersionReleases[
        Random().nextInt(androidVersionReleases.length)];
  }
}
