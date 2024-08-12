import 'package:flutter/material.dart';

import '../../components/settings/edittext_item.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class ParamsPage extends StatefulWidget {
  const ParamsPage({super.key});

  @override
  State<ParamsPage> createState() => _ParamsPageState();
}

class _ParamsPageState extends State<ParamsPage> {
  void onChanged() {
    setState(() {});
  }

  final manufacturerKey =
      GlobalKey<EdittextItemState>(debugLabel: 'manufacturer');
  final brandKey = GlobalKey<EdittextItemState>(debugLabel: 'brand');
  final modelKey = GlobalKey<EdittextItemState>(debugLabel: 'model');
  final buildKey = GlobalKey<EdittextItemState>(debugLabel: 'build');
  final sdkKey = GlobalKey<EdittextItemState>(debugLabel: 'sdk');
  final androidKey = GlobalKey<EdittextItemState>(debugLabel: 'android');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Params'),
        leading: const BackButton(),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          EdittextItem(
            title: 'Version Name',
            boxKey: SettingsBoxKey.versionName,
            needUpdateUserAgent: true,
            onChanged: onChanged,
          ),
          const EdittextItem(
            title: 'Api Version',
            boxKey: SettingsBoxKey.apiVersion,
          ),
          EdittextItem(
            title: 'Version Code',
            boxKey: SettingsBoxKey.versionCode,
            needUpdateUserAgent: true,
            onChanged: onChanged,
          ),
          EdittextItem(
            key: manufacturerKey,
            title: 'Manufacturer',
            boxKey: SettingsBoxKey.manufacturer,
            needUpdateXAppDevice: true,
            onChanged: onChanged,
          ),
          EdittextItem(
            key: brandKey,
            title: 'Brand',
            boxKey: SettingsBoxKey.brand,
            needUpdateUserAgent: true,
            needUpdateXAppDevice: true,
            onChanged: onChanged,
          ),
          EdittextItem(
            key: modelKey,
            title: 'Model',
            boxKey: SettingsBoxKey.model,
            needUpdateUserAgent: true,
            needUpdateXAppDevice: true,
            onChanged: onChanged,
          ),
          EdittextItem(
            key: buildKey,
            title: 'BuildNumber',
            boxKey: SettingsBoxKey.buildNumber,
            needUpdateUserAgent: true,
            needUpdateXAppDevice: true,
            onChanged: onChanged,
          ),
          EdittextItem(
            key: sdkKey,
            title: 'SDK INT',
            boxKey: SettingsBoxKey.sdkInt,
          ),
          EdittextItem(
            key: androidKey,
            title: 'Android Version',
            boxKey: SettingsBoxKey.androidVersion,
            needUpdateUserAgent: true,
            onChanged: onChanged,
          ),
          ListTile(
            title: const Text('User Angent'),
            subtitle: Text(GStorage.userAgent),
            onTap: () => Utils.copyText(GStorage.userAgent),
          ),
          ListTile(
            title: const Text('X-App-Device'),
            subtitle: Text(GStorage.xAppDevice),
            onTap: () => Utils.copyText(GStorage.xAppDevice),
          ),
          ListTile(
            title: const Text('Regenerate Params'),
            onTap: () async {
              await GStorage.regenerateParams();
              setState(() {});
              manufacturerKey.currentState?.updateValue();
              brandKey.currentState?.updateValue();
              modelKey.currentState?.updateValue();
              buildKey.currentState?.updateValue();
              sdkKey.currentState?.updateValue();
              androidKey.currentState?.updateValue();
            },
          ),
        ],
      ),
    );
  }
}
