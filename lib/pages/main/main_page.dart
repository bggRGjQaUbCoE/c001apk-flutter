import 'dart:async';
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
  final _indexSctream = StreamController<int>.broadcast();
  late final MainController _mainController = Get.put(MainController());
  final _contrller = PageController();

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
      onDestinationSelected(0);
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
      child: LayoutBuilder(
        builder: (_, constriants) {
          bool isPortait = constriants.maxHeight > constriants.maxWidth;

          return Scaffold(
            body: Row(children: [
              if (!isPortait)
                StreamBuilder(
                  initialData: _selectedIndex,
                  stream: _indexSctream.stream,
                  builder: (_, snapshot) => NavigationRail(
                    destinations: railDestinations,
                    selectedIndex: snapshot.data,
                    onDestinationSelected: onDestinationSelected,
                  ),
                ),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _contrller,
                  children: pages,
                ),
              ),
            ]),
            bottomNavigationBar: isPortait
                ? StreamBuilder(
                    initialData: _selectedIndex,
                    stream: _indexSctream.stream,
                    builder: (_, snapshot) => NavigationBar(
                      destinations: barDestinations,
                      selectedIndex: snapshot.data!,
                      onDestinationSelected: onDestinationSelected,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.onlyShowSelected,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void onDestinationSelected(int index) {
    if (index == 0 && _selectedIndex == 0) {
      _pageScrollController.setIndex(998);
    }
    _contrller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    _selectedIndex = index;
    _indexSctream.add(index);
  }
}
