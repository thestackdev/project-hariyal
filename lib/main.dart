import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:the_project_hariyal/services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Ubuntu',
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  runApp(
    Phoenix(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthServices().handleAuth(),
        theme: appTheme,
      ),
    ),
  );
}
