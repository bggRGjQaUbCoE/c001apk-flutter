import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/dialog.dart';
import '../../../providers/app_config_provider.dart';

class ParamsPage extends StatelessWidget {
  const ParamsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
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
          ListTile(
            title: const Text('Version Name'),
            subtitle: Text(appConfigProvider.versionName),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Version Name',
                defaultText: appConfigProvider.versionName,
                setData: (newValue) =>
                    appConfigProvider.setVersionName(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Api Version'),
            subtitle: Text(appConfigProvider.apiVersion),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Api Version',
                defaultText: appConfigProvider.apiVersion,
                setData: (newValue) =>
                    appConfigProvider.setApiVersion(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Version Code'),
            subtitle: Text(appConfigProvider.versionCode),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Version Code',
                defaultText: appConfigProvider.versionCode,
                setData: (newValue) =>
                    appConfigProvider.setVersionCode(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Manufacturer'),
            subtitle: Text(appConfigProvider.manufacturer),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Manufacturer',
                defaultText: appConfigProvider.manufacturer,
                setData: (newValue) =>
                    appConfigProvider.setManufacturer(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Brand'),
            subtitle: Text(appConfigProvider.brand),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Brand',
                defaultText: appConfigProvider.brand,
                setData: (newValue) => appConfigProvider.setBrand(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Model'),
            subtitle: Text(appConfigProvider.model),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Model',
                defaultText: appConfigProvider.model,
                setData: (newValue) => appConfigProvider.setModel(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('BuildNumber'),
            subtitle: Text(appConfigProvider.buildNumber),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'BuildNumber',
                defaultText: appConfigProvider.buildNumber,
                setData: (newValue) =>
                    appConfigProvider.setBuildNumber(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('SDK INT'),
            subtitle: Text(appConfigProvider.sdkInt),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'SDK INT',
                defaultText: appConfigProvider.sdkInt,
                setData: (newValue) => appConfigProvider.setSdkInt(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('Android Version'),
            subtitle: Text(appConfigProvider.androidVersion),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => EditTextDialog(
                title: 'Android Version',
                defaultText: appConfigProvider.androidVersion,
                setData: (newValue) =>
                    appConfigProvider.setAndroidVersion(newValue),
              ),
            ),
          ),
          ListTile(
            title: const Text('User Angent'),
            subtitle: Text(appConfigProvider.userAgent),
            onTap: () {},
          ),
          ListTile(
            title: const Text('X-App-Device'),
            subtitle: Text(appConfigProvider.xAppDevice),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Regenerate Params'),
            onTap: () => appConfigProvider.regenerateParams(),
          ),
        ],
      ),
    );
  }
}
