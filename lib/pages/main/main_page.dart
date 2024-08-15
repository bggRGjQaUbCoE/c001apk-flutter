import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../pages/home/return_top_controller.dart';
import '../../pages/home/home_page.dart';
import '../../pages/main/main_controller.dart';
import '../../pages/message/message_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../utils/storage_util.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ReturnTopController _pageScrollController =
      Get.put(ReturnTopController(), tag: 'home');
  int _selectedIndex = 0;
  late final MainController _mainController = Get.put(MainController());

  @override
  void initState() {
    super.initState();
    _mainController.checkLoginInfo();
  }

  @override
  void dispose() async {
    await GStorage.close();
    Get.delete<ReturnTopController>(tag: 'home');
    Get.delete<MainController>();
    super.dispose();
  }

  void onBackPressed() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    } else {
      if (Platform.isAndroid) {
        AndroidIntent intent = const AndroidIntent(
          action: 'android.intent.action.MAIN',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
          category: 'android.intent.category.HOME',
        );
        await intent.launch();
      } else {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomePage(),
      MessagePage(),
      SettingsPage(),
    ];

    const barDestinations = <NavigationDestination>[
      NavigationDestination(
        selectedIcon: Icon(Icons.home),
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.message),
        icon: Icon(Icons.message_outlined),
        label: 'Message',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.settings),
        icon: Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];

    const railDestinations = <NavigationRailDestination>[
      NavigationRailDestination(
        selectedIcon: Icon(Icons.home),
        icon: Icon(Icons.home_outlined),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        selectedIcon: Icon(Icons.message),
        icon: Icon(Icons.message_outlined),
        label: Text('Message'),
      ),
      NavigationRailDestination(
        selectedIcon: Icon(Icons.settings),
        icon: Icon(Icons.settings_outlined),
        label: Text('Settings'),
      ),
    ];

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, obj) async {
          onBackPressed();
        },
        child: LayoutBuilder(builder: (_, constriants) {
          bool isPortait = constriants.maxHeight > constriants.maxWidth;

          return Scaffold(
            body: Row(children: [
              if (!isPortait)
                NavigationRail(
                  destinations: railDestinations,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    if (index == 0 && _selectedIndex == 0) {
                      _pageScrollController.setIndex(998);
                    }
                    setState(() => _selectedIndex = index);
                  },
                ),
              Expanded(
                  child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              )),
            ]),
            bottomNavigationBar: isPortait
                ? NavigationBar(
                    destinations: barDestinations,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      if (index == 0 && _selectedIndex == 0) {
                        _pageScrollController.setIndex(998);
                      }
                      setState(() => _selectedIndex = index);
                    },
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                  )
                : null,
          );
        }));
  }
}
