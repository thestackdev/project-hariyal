import 'package:catcher/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/email_manual_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _pref = await SharedPreferences.getInstance();
  final isSuperuser = _pref.getBool('SuperAdmin');
  final isAdmin = _pref.getBool('Admin');

  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(), [
    EmailManualHandler(["shanmukeshwar1028@gmail.com"])
  ]);

  try {
    Catcher(
      Phoenix(
        child: MaterialApp(
          navigatorKey: Catcher.navigatorKey,
          debugShowCheckedModeBanner: false,
          home: getScreen(isSuperuser, isAdmin),
        ),
      ),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions,
    );
  } catch (error) {
    AuthServices().logout();
  }
}

getScreen(isSuperuser, isAdmin) {
  if (isSuperuser == true) {
    return AuthServices().handleSuperAdminAuth();
  } else if (isAdmin == true) {
    return AuthServices().handleAdminAuth();
  } else {
    return AuthServices().handleAuth();
  }
}
