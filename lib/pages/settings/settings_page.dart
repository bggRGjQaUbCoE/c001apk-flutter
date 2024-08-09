import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../components/dialog.dart';
import '../../constants/constants.dart';
import '../../providers/app_config_provider.dart';
import '../../utils/cache_util.dart';
import '../../utils/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// ignore: constant_identifier_names
enum SettingsMenuItem { Feedback, About }

// ignore: constant_identifier_names
enum FollowType { ALL, USER, TOPIC, PRODUCT, APP }

// ignore: constant_identifier_names
enum ImageQuality { AUTO, ORIGIN, THUMBNAIL }

class _SettingsPageState extends State<SettingsPage> {
  String _cacheSize = '';
  String _version = '1.0.0(1)';
  late final appConfigProvider = Provider.of<AppConfigProvider>(context);

  Future<void> _getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    setState(() => _cacheSize = res);
  }

  void _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = '${packageInfo.version}(${packageInfo.buildNumber})';
  }

  @override
  void initState() {
    super.initState();
    _getCacheSize();
    _getVersionInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          PopupMenuButton(
            onSelected: (SettingsMenuItem item) {
              switch (item) {
                case SettingsMenuItem.Feedback:
                  Utils.launchURL(Constants.URL_SOURCE_CODE);
                  break;
                case SettingsMenuItem.About:
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return MAboutDialog(version: _version);
                    },
                  );
                  break;
              }
            },
            itemBuilder: (context) => SettingsMenuItem.values
                .map((item) => PopupMenuItem<SettingsMenuItem>(
                      value: item,
                      child: Text(item.name),
                    ))
                .toList(),
          )
        ],
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          ListTile(
            title: Text(
              Constants.APP_NAME,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text('SZLM ID'),
            subtitle: appConfigProvider.szlmId.isEmpty
                ? null
                : Text(appConfigProvider.szlmId),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) {
                return EditTextDialog(
                  title: 'SZLM ID',
                  defaultText: appConfigProvider.szlmId,
                  setData: (value) => appConfigProvider.setSzlmId(value),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Params'),
            onTap: () => Get.toNamed('/params'),
          ),
          // Theme
          ListTile(
            title: Text(
              'Theme',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Dynamic Theme'),
            trailing: Switch(
                value: appConfigProvider.useDynamicColor,
                onChanged: (value) =>
                    appConfigProvider.setUseDynamicColor(value)),
            onTap: () => appConfigProvider
                .setUseDynamicColor(!appConfigProvider.useDynamicColor),
          ),
          ListTile(
            leading: const Icon(Icons.format_color_fill),
            enabled: !appConfigProvider.useDynamicColor,
            title: const Text('Theme Color'),
            trailing: DropdownButton<int>(
              value: appConfigProvider.staticColor,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  appConfigProvider.setStaticColor(newValue);
                }
              },
              items: Constants.themeType
                  .map((type) => DropdownMenuItem<int>(
                        enabled: !appConfigProvider.useDynamicColor,
                        value: Constants.themeType.indexOf(type),
                        child: Text(type),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<int>(
              value: appConfigProvider.selectedTheme,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  appConfigProvider.setSelectedTheme(newValue);
                }
              },
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('Always Off'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('Always On'),
                ),
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text('Follow System'),
                ),
              ],
            ),
          ),
          // Display
          ListTile(
            title: Text(
              'Display',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('User Blacklist'),
            leading: const Icon(Icons.block),
            onTap: () {
              // todo: User Blacklist
            },
          ),
          ListTile(
            title: const Text('Topic Blacklist'),
            leading: const Icon(Icons.block),
            onTap: () {
              // todo: Topic Blacklist
            },
          ),
          ListTile(
            title: const Text('Font Scale'),
            subtitle:
                Text('${appConfigProvider.fontScale.toStringAsFixed(2)}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () => showDialog<void>(
                context: context,
                builder: (context) => SliderDialog(
                    fontScale: appConfigProvider.fontScale,
                    setData: (newValue) =>
                        appConfigProvider.setFontScale(newValue))),
          ),
          ListTile(
            title: const Text('Follow Type'),
            leading: const Icon(Icons.add_circle_outline_outlined),
            trailing: DropdownButton<int>(
              value: appConfigProvider.followType,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  appConfigProvider.setFollowType(newValue);
                }
              },
              items: FollowType.values
                  .map((type) => DropdownMenuItem<int>(
                        value: FollowType.values.indexOf(type),
                        child: Text(type.name),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: const Text('Image Quality'),
            leading: const Icon(Icons.image_outlined),
            trailing: DropdownButton<int>(
              value: appConfigProvider.imageQuality,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  appConfigProvider.setImageQuality(newValue);
                }
              },
              items: ImageQuality.values
                  .map((type) => DropdownMenuItem<int>(
                        value: ImageQuality.values.indexOf(type),
                        child: Text(type.name),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: const Text('Image Dim'),
            leading: const Icon(Icons.image_outlined),
            trailing: Switch(
              value: appConfigProvider.imageDim,
              onChanged: (value) => appConfigProvider.setImageDim(value),
            ),
            onTap: () =>
                appConfigProvider.setImageDim(!appConfigProvider.imageDim),
          ),
          ListTile(
            title: const Text('Open In Browser'),
            leading: const Icon(Icons.travel_explore),
            trailing: Switch(
              value: appConfigProvider.openInBrowser,
              onChanged: (value) => appConfigProvider.setOpenInBrowser(value),
            ),
            onTap: () => appConfigProvider
                .setOpenInBrowser(!appConfigProvider.openInBrowser),
          ),
          ListTile(
            title: const Text('Show Square'),
            leading: const Icon(Icons.feed_outlined),
            trailing: Switch(
              value: appConfigProvider.showSquare,
              onChanged: (value) => appConfigProvider.setShowSquare(value),
            ),
            onTap: () =>
                appConfigProvider.setShowSquare(!appConfigProvider.showSquare),
          ),
          ListTile(
            title: const Text('Record History'),
            leading: const Icon(Icons.history),
            trailing: Switch(
              value: appConfigProvider.recordHistory,
              onChanged: (value) => appConfigProvider.setRecordHistory(value),
            ),
            onTap: () => appConfigProvider
                .setRecordHistory(!appConfigProvider.recordHistory),
          ),
          ListTile(
            title: const Text('Show Emoji'),
            leading: const Icon(Icons.emoji_emotions_outlined),
            trailing: Switch(
              value: appConfigProvider.showEmoji,
              onChanged: (value) => appConfigProvider.setShowEmoji(value),
            ),
            onTap: () =>
                appConfigProvider.setShowEmoji(!appConfigProvider.showEmoji),
          ),
          if (Platform.isAndroid)
            ListTile(
              title: const Text('Check Update'),
              leading: const Icon(Icons.system_update),
              trailing: Switch(
                value: appConfigProvider.checkUpdate,
                onChanged: (value) => appConfigProvider.setCheckUpdate(value),
              ),
              onTap: () => appConfigProvider
                  .setCheckUpdate(!appConfigProvider.checkUpdate),
            ),
          if (false)
            ListTile(
              title: const Text('Check Count'),
              leading: const Icon(Icons.notifications_outlined),
              trailing: Switch(
                value: appConfigProvider.checkCount,
                onChanged: (value) => appConfigProvider.setCheckCount(value),
              ),
              onTap: () => appConfigProvider
                  .setCheckCount(!appConfigProvider.checkCount),
            ),
          // Others
          ListTile(
            title: Text(
              'Others',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: Text(_version),
            leading: const Icon(Icons.all_inclusive),
            onTap: () =>
                Get.toNamed('/about', parameters: {'version': _version}),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: _cacheSize.isNotEmpty ? Text(_cacheSize) : null,
            leading: const Icon(Icons.cleaning_services_outlined),
            onTap: () async {
              await _getCacheSize();
              if (context.mounted) {
                showDialog<void>(
                  context: context,
                  builder: (context) => ClearDialog(
                    cacheSize: _cacheSize,
                    onClearCache: () async {
                      if (await CacheManage().clearCacheAll()) {
                        _getCacheSize();
                      }
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
