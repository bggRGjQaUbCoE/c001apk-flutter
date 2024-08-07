import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../../../utils/utils.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final version = Get.parameters['version'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: const BackButton(),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          const Icon(Icons.all_inclusive),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text(Constants.APP_NAME),
            subtitle: const Text('test only'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('Version'),
            subtitle: Text(version),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text(Constants.URL_SOURCE_CODE),
            onTap: () => Utils.launchURL(Constants.URL_SOURCE_CODE),
          ),
          ListTile(
            leading: const Icon(Icons.source_outlined),
            title: const Text('Open Source License'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: Constants.APP_NAME,
              applicationVersion: version,
              applicationIcon: const Icon(Icons.all_inclusive),
            ),
          ),
        ],
      ),
    );
  }
}
