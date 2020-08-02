import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:splashscreen/splashscreen.dart' as splash;
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
        home: splash.SplashScreen(
          seconds: 2,
          loadingText: Text('Loading User Info'),
          image: Image.asset('assets/hariyal.png'),
          navigateAfterSeconds: AuthServices().handleAuth(),
          backgroundColor: Colors.white,
          styleTextUnderTheLoader: TextStyle(),
          photoSize: 160.0,
          loaderColor: Colors.red,
        ),
        theme: appTheme,
      ),
    ),
  );
}
