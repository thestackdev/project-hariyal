import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _pref = await SharedPreferences.getInstance();
  final isSuperuser = _pref.getBool('SuperAdmin');
  final isAdmin = _pref.getBool('Admin');

  try {
    runApp(Phoenix(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: getScreen(isSuperuser, isAdmin),
      ),
    ));
  } catch (e) {
    AuthServices().logout();
    main();
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
