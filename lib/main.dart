import 'dart:io';

import 'package:c001apk_flutter/utils/storage_util.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'components/custom_toast.dart';
import 'constants/constants.dart';
import 'providers/app_config_provider.dart';
import 'router/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      minimumSize: const Size(300, 700),
      size: const Size(300, 700),
      center: true,
      skipTaskbar: false,
      titleBarStyle:
          Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final AppConfigProvider appConfigProvider =
      AppConfigProvider(sharedPreferencesInstance: sharedPreferences);
  appConfigProvider.saveFromSharedPreferences();

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      statusBarBrightness: appConfigProvider.getBrightness(),
      systemNavigationBarIconBrightness: appConfigProvider.getBrightness(),
    ));
  }

  await GStorage.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appConfigProvider),
    ],
    child: const C001APKAPP(),
  ));
}

class C001APKAPP extends StatelessWidget {
  const C001APKAPP({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      appConfigProvider
          .setSupportsDynamicTheme(lightDynamic != null && darkDynamic != null);
      ColorScheme? lightColorScheme;
      ColorScheme? darkColorScheme;
      if (lightDynamic != null &&
          darkDynamic != null &&
          appConfigProvider.useDynamicColor) {
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Constants.seedColors[appConfigProvider.staticColor],
          brightness: Brightness.light,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Constants.seedColors[appConfigProvider.staticColor],
          brightness: Brightness.dark,
        );
      }

      return GetMaterialApp(
        title: 'c001apk',
        theme: ThemeData(
          colorScheme: appConfigProvider.selectedTheme == 2
              ? darkColorScheme
              : lightColorScheme,
          useMaterial3: true,
          navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor:
                  (lightDynamic != null && appConfigProvider.useDynamicColor)
                      ? lightColorScheme.surfaceTint
                      : lightColorScheme.surfaceContainer),
          snackBarTheme: SnackBarThemeData(
            actionTextColor: lightColorScheme.primary,
            backgroundColor: lightColorScheme.secondaryContainer,
            closeIconColor: lightColorScheme.secondary,
            contentTextStyle: TextStyle(color: lightColorScheme.secondary),
            elevation: 20,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                allowEnterRouteSnapshotting: false,
              ),
            },
          ),
          popupMenuTheme: PopupMenuThemeData(
            surfaceTintColor: lightColorScheme.surfaceTint,
          ),
          cardTheme: CardTheme(
            surfaceTintColor: lightColorScheme.surfaceTint,
            shadowColor: Colors.transparent,
          ),
          dialogTheme: DialogTheme(
            surfaceTintColor: lightColorScheme.surfaceTint,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: lightColorScheme.surfaceVariant,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            refreshBackgroundColor: lightColorScheme.onSecondary,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: appConfigProvider.selectedTheme == 1
              ? lightColorScheme
              : darkColorScheme,
          useMaterial3: true,
          navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor:
                  (lightDynamic != null && appConfigProvider.useDynamicColor)
                      ? darkColorScheme.surfaceTint
                      : darkColorScheme.surfaceContainer),
          snackBarTheme: SnackBarThemeData(
            actionTextColor: darkColorScheme.primary,
            backgroundColor: darkColorScheme.secondaryContainer,
            closeIconColor: darkColorScheme.secondary,
            contentTextStyle: TextStyle(color: darkColorScheme.secondary),
            elevation: 20,
          ),
          popupMenuTheme: PopupMenuThemeData(
            surfaceTintColor: darkColorScheme.surfaceTint,
          ),
          cardTheme: CardTheme(
            surfaceTintColor: darkColorScheme.surfaceTint,
            shadowColor: Colors.transparent,
          ),
          dialogTheme: DialogTheme(
            surfaceTintColor: darkColorScheme.surfaceTint,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: darkColorScheme.surfaceVariant,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            refreshBackgroundColor: darkColorScheme.onSecondary,
          ),
        ),
        themeMode: appConfigProvider.getThemeMode(),
        getPages: AppPages.getPages,
        initialRoute: '/',
        builder: (BuildContext context, Widget? child) {
          return FlutterSmartDialog(
            toastBuilder: (String msg) => CustomToast(msg: msg),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(appConfigProvider.fontScale)),
              child: child!,
            ),
          );
        },
      );
    });
  }
}
