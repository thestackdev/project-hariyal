import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/admin/admin_home.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/signin.dart';

class SplashScreen extends StatefulWidget {
  final bool isAdmin;

  const SplashScreen(bool bool, {Key key, this.isAdmin}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    handleAuth();
    super.initState();
  }

  handleAuth() async {
    Timer(Duration(seconds: 2), () {
      return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            if (widget.isAdmin) {
              return AdminHome(uid: snapshot.data.uid);
            } else {
              return Home(
                uid: snapshot.data.uid,
              );
            }
          } else {
            return Signin();
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'TODO LOGO',
              textScaleFactor: 2,
            ),
            Text(
              'Hariyal',
              textScaleFactor: 1.8,
            )
          ],
        ),
      ),
    );
  }
}
