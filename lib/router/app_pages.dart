import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/app/app_page.dart';
import '../pages/blacklist/black_list_page.dart';
import '../pages/carousel/carousel_page.dart';
import '../pages/coolpic/coolpic_page.dart';
import '../pages/dyh/dyh_page.dart';
import '../pages/feed/feed_page.dart';
import '../pages/ffflist/ffflist_page.dart';
import '../pages/history/history_page.dart';
import '../pages/home/app/update/app_update_page.dart';
import '../pages/login/login_page.dart';
import '../pages/main/main_page.dart';
import '../pages/noitfication/notification_page.dart';
import '../pages/others/copy_page.dart';
import '../pages/others/imageview_page.dart';
import '../pages/search/search_page.dart';
import '../pages/search/search_result_page.dart';
import '../pages/settings/about_page.dart';
import '../pages/settings/params_page.dart';
import '../pages/topic/topic_page.dart';
import '../pages/user/user_page.dart';
import '../pages/webview/webview_page.dart';

class AppPages {
  static GetPage _getPage({
    required String name,
    required Widget Function() page,
  }) {
    return GetPage(
      name: name,
      page: page,
      transition: Transition.native,
    );
  }

  static final List<GetPage> getPages = [
    _getPage(
      name: '/',
      page: () => const MainPage(),
    ),
    _getPage(
      name: '/params',
      page: () => const ParamsPage(),
    ),
    _getPage(
      name: '/about',
      page: () => const AboutPage(),
    ),
    _getPage(
      name: '/copy',
      page: () => const CopyPage(),
    ),
    _getPage(
      name: '/feed/:id',
      page: () => const FeedPage(),
    ),
    _getPage(
      name: '/u/:uid',
      page: () => const UserPage(),
    ),
    _getPage(
      name: '/apk/:packageName',
      page: () => const AppPage(),
    ),
    _getPage(
      name: '/search',
      page: () => const SearchPage(),
    ),
    _getPage(
      name: '/searchResult',
      page: () => const SearchResultPage(),
    ),
    _getPage(
      name: '/t/:tag',
      page: () => const TopicPage(),
    ),
    _getPage(
      name: '/product/:id',
      page: () => const TopicPage(),
    ),
    _getPage(
      name: '/webview',
      page: () => const WebviewPage(),
    ),
    _getPage(
      name: '/appUpdate',
      page: () => const AppUpdatePage(),
    ),
    _getPage(
      name: '/carousel',
      page: () => const CarouselPage(),
    ),
    _getPage(
      name: '/dyh',
      page: () => const DyhPage(),
    ),
    _getPage(
      name: '/coolpic',
      page: () => const CoolpicPage(),
    ),
    _getPage(
      name: '/imageview',
      page: () => const ImageViewPage(),
    ),
    _getPage(
      name: '/login',
      page: () => const LoginPage(),
    ),
    _getPage(
      name: '/notification',
      page: () => const NotificationPage(),
    ),
    _getPage(
      name: '/ffflist',
      page: () => const FFFListPage(),
    ),
    _getPage(
      name: '/history',
      page: () => const HistoryPage(),
    ),
    _getPage(
      name: '/blacklist',
      page: () => const BlackListPage(),
    ),
  ];
}
