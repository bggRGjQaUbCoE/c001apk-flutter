// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class Constants {
  static const APP_NAME = 'c001apk-flutter';

  static const REQUEST_WITH = 'XMLHttpRequest';
  static const LOCALE = 'zh-CN';
  static const APP_ID = 'com.coolapk.market';
  static const DARK_MODE = '0';
  static const CHANNEL = 'coolapk';
  static const MODE = 'universal';
  static const APP_LABEL =
      'token://com.coolapk.market/dcf01e569c1e3db93a3d0fcf191a622c';
  static const VERSION_NAME = '13.4.1';
  static const API_VERSION = '13';
  static const VERSION_CODE = '2312121';

  static const PREFIX_COOLMARKET = 'coolmarket://';
  static const PREFIX_HTTP = 'http';
  static const PREFIX_APP = '/apk/';
  static const PREFIX_GAME = '/game/';
  static const PREFIX_FEED = '/feed/';
  static const PREFIX_PRODUCT = '/product/';
  static const PREFIX_TOPIC = '/t/';
  static const PREFIX_USER = '/u/';
  static const PREFIX_CAROUSEL = '/page?url=';
  static const PREFIX_CAROUSEL1 = '#/';
  static const PREFIX_USER_LIST = '/user/';
  static const PREFIX_DYH = '/dyh/';
  static const PREFIX_COLLECTION = '/collection/';
  static const SUFFIX_THUMBNAIL = '.s.jpg';
  static const SUFFIX_GIF = '.gif';

  static const UTF8 = 'UTF-8';
  static const EMPTY_STRING = '';
  static const LOADING_FAILED = 'FAILED';
  static const URL_COOLAPK = 'https://www.coolapk.com/';
  static const URL_LOGIN = 'https://account.coolapk.com/auth/login?type=mobile';
  static const URL_SOURCE_CODE =
      'https://github.com/bggRGjQaUbCoE/c001apk-flutter';
  static const URL_API_SERVICE = 'https://api.coolapk.com';
  static const URL_API2_SERVICE = 'https://api2.coolapk.com';
  static const URL_ACCOUNT_SERVICE = 'https://account.coolapk.com';

  static const entityTypeList = [
    'feed',
    'apk',
    'product',
    'user',
    'topic',
    'notification',
    'productBrand',
    'contacts',
    'recentHistory',
    'feed_reply',
    'message',
    'collection',
  ];

  static const entityTemplateList = [
    'imageCarouselCard_1',
    'iconLinkGridCard',
    'iconMiniScrollCard',
    'iconMiniGridCard',
    'imageSquareScrollCard',
    'titleCard',
    'iconScrollCard',
    'imageTextScrollCard',
    'iconTabLinkGridCard',
    'verticalColumnsFullPageCard',
    'noMoreDataCard',
    'time',
  ];

  static Map<int, Color> getSwatch(int r, int g, int b) {
    return {
      50: Color.fromRGBO(r, g, b, .1),
      100: Color.fromRGBO(r, g, b, .2),
      200: Color.fromRGBO(r, g, b, .3),
      300: Color.fromRGBO(r, g, b, .4),
      400: Color.fromRGBO(r, g, b, .5),
      500: Color.fromRGBO(r, g, b, .6),
      600: Color.fromRGBO(r, g, b, .7),
      700: Color.fromRGBO(r, g, b, .8),
      800: Color.fromRGBO(r, g, b, .9),
      900: Color.fromRGBO(r, g, b, 1),
    };
  }

  static final List<MaterialColor> seedColors = [
    MaterialColor(0xFF6650A4, getSwatch(102, 80, 164)),
    // Colors.deepPurple,
    MaterialColor(0xFFF44336, getSwatch(244, 67, 54)),
    MaterialColor(0xFFE91E63, getSwatch(233, 30, 99)),
    MaterialColor(0xFF9C27B0, getSwatch(156, 39, 176)),
    MaterialColor(0xFF3F51B5, getSwatch(63, 81, 181)),
    MaterialColor(0xFF2196F3, getSwatch(33, 150, 243)),
    MaterialColor(0xFF03A9F4, getSwatch(3, 169, 244)),
    MaterialColor(0xFF00BCD4, getSwatch(0, 188, 212)),
    MaterialColor(0xFF009688, getSwatch(0, 150, 136)),
    MaterialColor(0xFF4FAF50, getSwatch(79, 175, 80)),
    MaterialColor(0xFF8BC3A4, getSwatch(139, 195, 164)),
    MaterialColor(0xFFCDDC39, getSwatch(205, 220, 57)),
    MaterialColor(0xFFFFEB3B, getSwatch(255, 235, 59)),
    MaterialColor(0xFFFFC107, getSwatch(255, 193, 7)),
    MaterialColor(0xFFFF9800, getSwatch(255, 152, 0)),
    MaterialColor(0xFFFF5722, getSwatch(255, 87, 34)),
    MaterialColor(0xFF795548, getSwatch(121, 85, 72)),
    MaterialColor(0xFF607D8F, getSwatch(96, 125, 143)),
    MaterialColor(0xFFFF9CA8, getSwatch(255, 156, 168)),
  ];

  static const List<String> themeType = [
    'Default',
    'Red',
    'Pink',
    'Purple',
    'Indigo',
    'Blue',
    'LightBlue',
    'Cyan',
    'Teal',
    'Green',
    'LightGreen',
    'Lime',
    'Yellow',
    'Amber',
    'Orange',
    'DeepOrange',
    'Brown',
    'BlueGrey',
    'Sakura',
    // 'Custom',
  ];
}
