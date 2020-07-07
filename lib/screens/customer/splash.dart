import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/admin/admin_home.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';
import 'package:the_project_hariyal/screens/customer/signin.dart';

class SplashScreen extends StatefulWidget {
  final bool isAdmin;

  SplashScreen(this.isAdmin);

  @override
  _SplashScreenState createState() => _SplashScreenState(isAdmin);
}

class _SplashScreenState extends State<SplashScreen> {
  final bool isAdmin;

  _SplashScreenState(this.isAdmin);

  @override
  void initState() {
    isAdmin != null
        ? isAdmin ? adminLogin() : getUserInfo()
        : Timer(Duration(seconds: 2), () {
            return Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) => Signin()));
          });
    ;
    super.initState();
  }

  Future adminLogin() async {
    var user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      Timer(Duration(seconds: 1), () {
        return Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Signin()));
      });
      return;
    }

    Timer(Duration(seconds: 1), () {
      return Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => AdminHome(
                uid: user.uid,
              )));
    });
  }

  Future getUserInfo() async {
    var user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      Timer(Duration(seconds: 1), () {
        return Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Signin()));
      });
      return;
    }

    var doc = Firestore.instance.collection('customers').document(user.uid);
    var document = await doc.get();
    UserModel userModel = UserModel.fromMap(document.data);

    Timer(Duration(seconds: 1), () {
      return Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => Home(user.uid, userModel)));
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
