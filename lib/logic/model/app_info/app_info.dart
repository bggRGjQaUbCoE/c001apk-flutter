import 'dart:typed_data';

class AppInfo {
  Uint8List? icon;
  String appName;
  String packageName;
  String versionName;
  String versionCode;
  String lastUpdateTime;

  AppInfo({
    required this.icon,
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.lastUpdateTime,
  });

  factory AppInfo.create(dynamic data) {
    return AppInfo(
      icon: data['icon'],
      appName: data['appName'] ?? '',
      packageName: data['packageName'] ?? '',
      versionName: data['versionName'] ?? '0',
      versionCode: data['versionCode'] ?? '0',
      lastUpdateTime: data['lastUpdateTime'] ?? '0',
    );
  }

  static List<AppInfo> parseList(dynamic apps) {
    if (apps == null || apps is! List || apps.isEmpty) return [];
    final List<AppInfo> appInfoList =
        apps.map((app) => AppInfo.create(app)).toList();
    appInfoList.sort((a, b) => a.lastUpdateTime.compareTo(b.lastUpdateTime));
    return appInfoList.reversed.toList();
  }
}
