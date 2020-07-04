import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project_hariyal/screens/admin/admin_home.dart';

import 'screens/superuser/superuser_home.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences _pref = await SharedPreferences.getInstance();
  final isSuperuser = _pref.getBool('SuperAdmin');
  final isAdmin = _pref.getString('Admin');

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(
    Phoenix(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isSuperuser == true
            ? SuperuserHome()
            : isAdmin != null
                ? AdminHome(email: isAdmin)
                : AuthServices().handleAuth(),
      ),
    ),
  );
}
