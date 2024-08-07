import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/constants.dart';
import '../../../utils/device_util.dart';
import '../../../utils/token_util.dart';

class AppConfigProvider with ChangeNotifier {
  final SharedPreferences sharedPreferencesInstance;

  AppConfigProvider({required this.sharedPreferencesInstance});

  bool _useDynamicColor = true;
  bool _supportsDynamicTheme = true;
  int _staticColor = 0;
  int _selectedTheme = 0;

  String _szlmId = "";
  double _fontScale = 1.00;
  int _followType = 0;
  int _imageQuality = 0;
  bool _imageDim = true;
  bool _openInBrowser = false;
  bool _showSquare = true;
  bool _recordHistory = true;
  bool _showEmoji = true;
  bool _checkUpdate = true;
  bool _checkCount = true;

  String _installTime = '';
  String _versionName = '';
  String _apiVersion = '';
  String _versionCode = '';
  String _manufacturer = '';
  String _brand = '';
  String _model = '';
  String _buildNumber = '';
  String _sdkInt = '';
  String _androidVersion = '';
  String _userAgent = '';
  String _xAppDevice = '';

  String _SESSID = '';
  bool _isLogin = false;
  String _uid = '';
  String _username = '';
  String _token = '';
  String _userAvatar = '';
  int _exp = 0;
  int _nextExp = 1;
  int _level = 0;

  void setLevel(int value) async {
    try {
      sharedPreferencesInstance.setInt('level', value);
      _level = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  int get level {
    return _level;
  }

  void setNextExp(int value) async {
    try {
      sharedPreferencesInstance.setInt('nextExp', value);
      _nextExp = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  int get nextExp {
    return _nextExp;
  }

  void setExp(int value) async {
    try {
      sharedPreferencesInstance.setInt('exp', value);
      _exp = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  int get exp {
    return _exp;
  }

  void setUserAvatar(String value) async {
    try {
      sharedPreferencesInstance.setString('userAvatar', value);
      _userAvatar = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get userAvatar {
    return _userAvatar;
  }

  void setToken(String value) async {
    try {
      sharedPreferencesInstance.setString('token', value);
      _token = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get token {
    return _token;
  }

  void setUsername(String value) async {
    try {
      sharedPreferencesInstance.setString('username', value);
      _username = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get username {
    return _username;
  }

  void setUid(String value) async {
    try {
      sharedPreferencesInstance.setString('uid', value);
      _uid = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get uid {
    return _uid;
  }

  void setIsLogin(bool value) async {
    try {
      sharedPreferencesInstance.setBool('isLogin', value);
      _isLogin = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get isLogin {
    return _isLogin;
  }

  void setSESSID(String value) async {
    try {
      sharedPreferencesInstance.setString('SESSID', value);
      _SESSID = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get SESSID {
    return _SESSID;
  }

  void setInstallTime(String value) async {
    try {
      sharedPreferencesInstance.setString('installTime', value);
      _installTime = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get installTime {
    return _installTime;
  }

  void setXAppDevice(String value) async {
    try {
      sharedPreferencesInstance.setString('xAppDevice', value);
      _xAppDevice = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get xAppDevice {
    return _xAppDevice;
  }

  void setUserAgent() async {
    try {
      final userAgent =
          'Dalvik/2.1.0 (Linux; U; Android $androidVersion; $model $buildNumber) (#Build; $brand; $model; $buildNumber; $androidVersion) +CoolMarket/$versionName-$versionCode-${Constants.MODE}';
      sharedPreferencesInstance.setString('userAgent', userAgent);
      _userAgent = userAgent;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get userAgent {
    return _userAgent;
  }

  void setAndroidVersion(String value) async {
    try {
      sharedPreferencesInstance.setString('androidVersion', value);
      _androidVersion = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get androidVersion {
    return _androidVersion;
  }

  void setSdkInt(String value) async {
    try {
      sharedPreferencesInstance.setString('sdkInt', value);
      _sdkInt = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get sdkInt {
    return _sdkInt;
  }

  void setBuildNumber(String value) async {
    try {
      sharedPreferencesInstance.setString('buildNumber', value);
      _buildNumber = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get buildNumber {
    return _buildNumber;
  }

  void setModel(String value) async {
    try {
      sharedPreferencesInstance.setString('model', value);
      _model = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get model {
    return _model;
  }

  void setBrand(String value) async {
    try {
      sharedPreferencesInstance.setString('brand', value);
      _brand = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get brand {
    return _brand;
  }

  void setManufacturer(String value) async {
    try {
      sharedPreferencesInstance.setString('manufacturer', value);
      _manufacturer = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get manufacturer {
    return _manufacturer;
  }

  void setApiVersion(String value) async {
    try {
      sharedPreferencesInstance.setString('apiVersion', value);
      _apiVersion = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get apiVersion {
    return _apiVersion;
  }

  void setVersionCode(String value) async {
    try {
      sharedPreferencesInstance.setString('versionCode', value);
      _versionCode = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get versionCode {
    return _versionCode;
  }

  void setVersionName(String value) async {
    try {
      sharedPreferencesInstance.setString('versionName', value);
      _versionName = value;
      setUserAgent();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  String get versionName {
    return _versionName;
  }

  void setFontScale(double value) async {
    try {
      sharedPreferencesInstance.setDouble('fontScale', value);
      _fontScale = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  double get fontScale {
    return _fontScale;
  }

  void setCheckCount(bool value) async {
    try {
      sharedPreferencesInstance.setBool('checkCount', value);
      _checkCount = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get checkCount {
    return _checkCount;
  }

  void setCheckUpdate(bool value) async {
    try {
      sharedPreferencesInstance.setBool('checkUpdate', value);
      _checkUpdate = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get checkUpdate {
    return _checkUpdate;
  }

  void setShowEmoji(bool value) async {
    try {
      sharedPreferencesInstance.setBool('showEmoji', value);
      _showEmoji = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get showEmoji {
    return _showEmoji;
  }

  void setRecordHistory(bool value) async {
    try {
      sharedPreferencesInstance.setBool('recordHistory', value);
      _recordHistory = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get recordHistory {
    return _recordHistory;
  }

  void setShowSquare(bool value) async {
    try {
      sharedPreferencesInstance.setBool('showSquare', value);
      _showSquare = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get showSquare {
    return _showSquare;
  }

  void setOpenInBrowser(bool value) async {
    try {
      sharedPreferencesInstance.setBool('openInBrowser', value);
      _openInBrowser = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get openInBrowser {
    return _openInBrowser;
  }

  void setImageDim(bool value) async {
    try {
      sharedPreferencesInstance.setBool('imageDim', value);
      _imageDim = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  bool get imageDim {
    return _imageDim;
  }

  void setImageQuality(int value) async {
    try {
      sharedPreferencesInstance.setInt('imageQuality', value);
      _imageQuality = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  int get imageQuality {
    return _imageQuality;
  }

  void setFollowType(int value) async {
    try {
      sharedPreferencesInstance.setInt('followType', value);
      _followType = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  int get followType {
    return _followType;
  }

  String get szlmId {
    return _szlmId;
  }

  bool get useDynamicColor {
    return _useDynamicColor;
  }

  bool get supportsDynamicTheme {
    return _supportsDynamicTheme;
  }

  int get staticColor {
    return _staticColor;
  }

  int get selectedTheme {
    return _selectedTheme;
  }

  void setSzlmId(String value) async {
    try {
      sharedPreferencesInstance.setString('szlmId', value);
      _szlmId = value;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Brightness getBrightness() {
    switch (_selectedTheme) {
      case 0:
        if (PlatformDispatcher.instance.platformBrightness ==
            Brightness.light) {
          return Brightness.dark;
        } else {
          return Brightness.light;
        }

      case 1:
        return Brightness.dark;

      case 2:
        return Brightness.light;

      default:
        return Brightness.dark;
    }
  }

  ThemeMode getThemeMode() {
    switch (_selectedTheme) {
      case 0:
        return ThemeMode.system;

      case 1:
        return ThemeMode.light;

      case 2:
        return ThemeMode.dark;

      default:
        return ThemeMode.system;
    }
  }

  Future<bool> setUseDynamicColor(bool value) async {
    try {
      sharedPreferencesInstance.setBool('useDynamicColor', value);
      _useDynamicColor = value;
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());

      return false;
    }
  }

  void setSupportsDynamicTheme(bool value) {
    _supportsDynamicTheme = value;
  }

  Future<bool> setStaticColor(int value) async {
    try {
      sharedPreferencesInstance.setInt('staticColor', value);
      _staticColor = value;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setSelectedTheme(int value) async {
    try {
      sharedPreferencesInstance.setInt('selectedTheme', value);
      _selectedTheme = value;
      notifyListeners();
      if (Platform.isAndroid) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarBrightness: getBrightness(),
          systemNavigationBarIconBrightness: getBrightness(),
        ));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void regenerateParams() async {
    setVersionName(Constants.VERSION_NAME);
    setApiVersion(Constants.API_VERSION);
    setVersionCode(Constants.VERSION_CODE);
    setManufacturer(DeviceUtil.randomManufacturer());
    setBrand(DeviceUtil.randomBrand());
    setModel(DeviceUtil.randomDeviceModel());
    setBuildNumber(DeviceUtil.randHexString(32));
    setSdkInt(DeviceUtil.randomSdkInt());
    setAndroidVersion(DeviceUtil.randomAndroidVersionRelease());
    setUserAgent();
    setXAppDevice(await TokenUtils.encodeDevice(
        '${szlmId.isEmpty ? DeviceUtil.randHexString(32) : szlmId}; ; ; ${DeviceUtil.randomMacAddress()}; $manufacturer; $brand; $model; $buildNumber; null'));
  }

  void saveFromSharedPreferences() {
    _useDynamicColor =
        sharedPreferencesInstance.getBool('useDynamicColor') ?? true;
    _staticColor = sharedPreferencesInstance.getInt('staticColor') ?? 0;
    _selectedTheme = sharedPreferencesInstance.getInt('selectedTheme') ?? 0;

    _szlmId = sharedPreferencesInstance.getString('szlmId') ?? '';
    _fontScale = sharedPreferencesInstance.getDouble('fontScale') ?? 1.00;
    _followType = sharedPreferencesInstance.getInt('followType') ?? 0;
    _imageQuality = sharedPreferencesInstance.getInt('imageQuality') ?? 0;
    _imageDim = sharedPreferencesInstance.getBool('imageDim') ?? true;
    _openInBrowser =
        sharedPreferencesInstance.getBool('openInBrowser') ?? false;
    _showSquare = sharedPreferencesInstance.getBool('showSquare') ?? true;
    _recordHistory = sharedPreferencesInstance.getBool('recordHistory') ?? true;
    _showEmoji = sharedPreferencesInstance.getBool('showEmoji') ?? true;
    _checkUpdate = sharedPreferencesInstance.getBool('checkUpdate') ?? true;
    _checkCount = sharedPreferencesInstance.getBool('checkCount') ?? true;

    _installTime = sharedPreferencesInstance.getString('installTime') ?? '';
    _versionName = sharedPreferencesInstance.getString('versionName') ?? '';
    _apiVersion = sharedPreferencesInstance.getString('apiVersion') ?? '';
    _versionCode = sharedPreferencesInstance.getString('versionCode') ?? '';
    _buildNumber = sharedPreferencesInstance.getString('buildNumber') ?? '';
    _manufacturer = sharedPreferencesInstance.getString('manufacturer') ?? '';
    _brand = sharedPreferencesInstance.getString('brand') ?? '';
    _model = sharedPreferencesInstance.getString('model') ?? '';
    _sdkInt = sharedPreferencesInstance.getString('sdkInt') ?? '';
    _androidVersion =
        sharedPreferencesInstance.getString('androidVersion') ?? '';
    _userAgent = sharedPreferencesInstance.getString('userAgent') ?? '';
    _xAppDevice = sharedPreferencesInstance.getString('xAppDevice') ?? '';

    _SESSID = sharedPreferencesInstance.getString('SESSID') ?? '';
    _isLogin = sharedPreferencesInstance.getBool('isLogin') ?? false;
    _uid = sharedPreferencesInstance.getString('uid') ?? '';
    _username = sharedPreferencesInstance.getString('username') ?? '';
    _token = sharedPreferencesInstance.getString('token') ?? '';
    _userAvatar = sharedPreferencesInstance.getString('userAvatar') ?? '';
    _exp = sharedPreferencesInstance.getInt('exp') ?? 0;
    _nextExp = sharedPreferencesInstance.getInt('nextExp') ?? 1;
    _level = sharedPreferencesInstance.getInt('level') ?? 0;

    if (_installTime.isEmpty) {
      setInstallTime(
          (DateTime.now().microsecondsSinceEpoch ~/ 1000).toString());
      regenerateParams();
    }
  }
}
