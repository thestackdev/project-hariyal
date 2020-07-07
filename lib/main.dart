import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _pref = await SharedPreferences.getInstance();
  final isAdmin = _pref.getBool('Admin');

  final appTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Ubuntu',
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }));

  try {
    runApp(Phoenix(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isAdmin
            ? AuthServices().handleAdminAuth()
            : AuthServices().handleAuth(),
        theme: appTheme,
      ),
    ));
  } catch (e) {
    AuthServices().logout();
    main();
  }
}
