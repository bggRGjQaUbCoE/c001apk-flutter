import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../components/dialog.dart';
import '../../components/settings/drop_down_menu_item.dart';
import '../../components/settings/edittext_item.dart';
import '../../components/settings/item_title.dart';
import '../../components/settings/switch_item.dart';
import '../../constants/constants.dart';
import '../../pages/blacklist/black_list_page.dart' show BlackListType;
import '../../utils/cache_util.dart';
import '../../utils/storage_util.dart';
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
          const ItemTitle(title: Constants.APP_NAME),
          const EdittextItem(
            icon: Icons.smartphone,
            title: 'SZLM ID',
            boxKey: SettingsBoxKey.szlmId,
            needUpdateXAppDevice: true,
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
          const SwitchItem(
            icon: Icons.palette_outlined,
            title: 'Dynamic Theme',
            boxKey: SettingsBoxKey.useMaterial,
            defaultValue: true,
            forceAppUpdate: true,
          ),
          DropDownMenuItem(
            icon: Icons.format_color_fill,
            title: 'Theme Color',
            boxKey: SettingsBoxKey.staticColor,
            items: Constants.themeType
                .map((type) => DropdownMenuItem<int>(
                      enabled: !GStorage.useMaterial,
                      value: Constants.themeType.indexOf(type),
                      child: Text(type),
                    ))
                .toList(),
            forceAppUpdate: true,
          ),
          const DropDownMenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            boxKey: SettingsBoxKey.selectedTheme,
            items: [
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
            forceAppUpdate: true,
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
              arguments: {'type': BlackListType.user},
            ),
          ),
          ListTile(
            title: const Text('Topic Blacklist'),
            leading: const Icon(Icons.block),
            onTap: () => Get.toNamed(
              '/blacklist/',
              arguments: {'type': BlackListType.topic},
            ),
          ),
          ListTile(
            title: const Text('Font Scale'),
            subtitle: Text('${GStorage.fontScale.toStringAsFixed(2)}x'),
            leading: const Icon(Icons.text_fields),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => SliderDialog(
                fontScale: GStorage.fontScale,
                setData: (newValue) {
                  GStorage.setFontScale(newValue);
                  Get.forceAppUpdate();
                },
              ),
            ),
          ),
          DropDownMenuItem(
            icon: Icons.add_circle_outline_outlined,
            title: 'Follow Type',
            boxKey: SettingsBoxKey.followType,
            items: FollowType.values
                .map((type) => DropdownMenuItem<int>(
                      value: FollowType.values.indexOf(type),
                      child: Text(type.name),
                    ))
                .toList(),
          ),
          /*
          DropDownMenuItem(
            icon: Icons.image_outlined,
            title: 'Image Quality',
            boxKey: SettingsBoxKey.imageQuality,
            items: ImageQuality.values
                .map((type) => DropdownMenuItem<int>(
                      value: ImageQuality.values.indexOf(type),
                      child: Text(type.name),
                    ))
                .toList(),
          ),
          const SwitchItem(
            icon: Icons.image_outlined,
            title: 'Image Dim',
            boxKey: SettingsBoxKey.imageDim,
            defaultValue: true,
          ),
          */
          const SwitchItem(
            icon: Icons.travel_explore,
            title: 'Open In Browser',
            boxKey: SettingsBoxKey.openInBrowser,
            defaultValue: false,
          ),
          /*
          const SwitchItem(
            icon: Icons.feed_outlined,
            title: 'Show Square',
            boxKey: SettingsBoxKey.showSquare,
            defaultValue: true,
          ),
          */
          const SwitchItem(
            icon: Icons.history,
            title: 'Record History',
            boxKey: SettingsBoxKey.recordHistory,
            defaultValue: true,
          ),
          const SwitchItem(
            icon: Icons.emoji_emotions_outlined,
            title: 'Show Emoji',
            boxKey: SettingsBoxKey.showEmoji,
            defaultValue: true,
          ),
          if (Platform.isAndroid)
            const SwitchItem(
              icon: Icons.system_update,
              title: 'Check Update',
              boxKey: SettingsBoxKey.checkUpdate,
              defaultValue: true,
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
