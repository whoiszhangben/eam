import 'package:asset_management_system/index.dart';
import 'package:asset_management_system/login.dart';
import 'package:asset_management_system/scan.dart';
import 'package:asset_management_system/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    // overlays: [
    //   SystemUiOverlay.top,
    //   SystemUiOverlay.bottom,
    // ],
  );

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   systemNavigationBarColor: Colors.transparent,
  // ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // fix MediaQuery bug
    // https://stackoverflow.com/questions/58318641/textfield-focus-triggers-rebuilding-of-ui
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CH'),
          Locale('en', 'US'),
        ],
        locale: const Locale('zh'),
        routes: {
          'login': (context) => const Login(),
          'index': (context) => const Index(),
          'scan': (context) => const Scan(),
        },
        title: '资产管理系统',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFf2f5f9),
          primarySwatch: Colors.blue,
        ),
        home: const Login(),
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
      );
    });
  }
}
