import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../components/dialog.dart';
import '../../constants/constants.dart';
import '../../pages/blacklist/black_list_page.dart' show BlackListType;
import '../../providers/app_config_provider.dart';
import '../../utils/cache_util.dart';
import '../../utils/device_util.dart';
import '../../utils/token_util.dart';
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
  late final _config = Provider.of<AppConfigProvider>(context);

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
            subtitle: _config.szlmId.isEmpty ? null : Text(_config.szlmId),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) {
                return EditTextDialog(
                  title: 'SZLM ID',
                  defaultText: _config.szlmId,
                  setData: (value) async {
                    _config.setSzlmId(value);
                    _config.setXAppDevice(await TokenUtils.encodeDevice(
                        '$value; ; ; ${DeviceUtil.randomMacAddress()}; ${_config.manufacturer}; ${_config.brand}; ${_config.model}; ${_config.buildNumber}; null'));
                  },
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
                value: _config.useDynamicColor,
                onChanged: (value) => _config.setUseDynamicColor(value)),
            onTap: () => _config.setUseDynamicColor(!_config.useDynamicColor),
          ),
          ListTile(
            leading: const Icon(Icons.format_color_fill),
            enabled: !_config.useDynamicColor,
            title: const Text('Theme Color'),
            trailing: DropdownButton<int>(
              value: _config.staticColor,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _config.setStaticColor(newValue);
                }
              },
              items: Constants.themeType
                  .map((type) => DropdownMenuItem<int>(
                        enabled: !_config.useDynamicColor,
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
              value: _config.selectedTheme,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _config.setSelectedTheme(newValue);
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
            onTap: () => Get.toNamed(
              '/blacklist/',
              arguments: {'type': BlackListType.User},
            ),
          ),
          ListTile(
            title: const Text('Topic Blacklist'),
            leading: const Icon(Icons.block),
            onTap: () => Get.toNamed(
              '/blacklist/',
              arguments: {'type': BlackListType.Topic},
            ),
          ),
          ListTile(
            title: const Text('Font Scale'),
            subtitle: Text('${_config.fontScale.toStringAsFixed(2)}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () => showDialog<void>(
                context: context,
                builder: (context) => SliderDialog(
                    fontScale: _config.fontScale,
                    setData: (newValue) => _config.setFontScale(newValue))),
          ),
          ListTile(
            title: const Text('Follow Type'),
            leading: const Icon(Icons.add_circle_outline_outlined),
            trailing: DropdownButton<int>(
              value: _config.followType,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _config.setFollowType(newValue);
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
              value: _config.imageQuality,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  _config.setImageQuality(newValue);
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
              value: _config.imageDim,
              onChanged: (value) => _config.setImageDim(value),
            ),
            onTap: () => _config.setImageDim(!_config.imageDim),
          ),
          ListTile(
            title: const Text('Open In Browser'),
            leading: const Icon(Icons.travel_explore),
            trailing: Switch(
              value: _config.openInBrowser,
              onChanged: (value) => _config.setOpenInBrowser(value),
            ),
            onTap: () => _config.setOpenInBrowser(!_config.openInBrowser),
          ),
          ListTile(
            title: const Text('Show Square'),
            leading: const Icon(Icons.feed_outlined),
            trailing: Switch(
              value: _config.showSquare,
              onChanged: (value) => _config.setShowSquare(value),
            ),
            onTap: () => _config.setShowSquare(!_config.showSquare),
          ),
          ListTile(
            title: const Text('Record History'),
            leading: const Icon(Icons.history),
            trailing: Switch(
              value: _config.recordHistory,
              onChanged: (value) => _config.setRecordHistory(value),
            ),
            onTap: () => _config.setRecordHistory(!_config.recordHistory),
          ),
          ListTile(
            title: const Text('Show Emoji'),
            leading: const Icon(Icons.emoji_emotions_outlined),
            trailing: Switch(
              value: _config.showEmoji,
              onChanged: (value) => _config.setShowEmoji(value),
            ),
            onTap: () => _config.setShowEmoji(!_config.showEmoji),
          ),
          if (Platform.isAndroid)
            ListTile(
              title: const Text('Check Update'),
              leading: const Icon(Icons.system_update),
              trailing: Switch(
                value: _config.checkUpdate,
                onChanged: (value) => _config.setCheckUpdate(value),
              ),
              onTap: () => _config.setCheckUpdate(!_config.checkUpdate),
            ),
          //   ListTile(
          //     title: const Text('Check Count'),
          //     leading: const Icon(Icons.notifications_outlined),
          //     trailing: Switch(
          //       value: _config.checkCount,
          //       onChanged: (value) => _config.setCheckCount(value),
          //     ),
          //     onTap: () => _config.setCheckCount(!_config.checkCount),
          //   ),
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
