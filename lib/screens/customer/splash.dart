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
    handleAuth();
    super.initState();
  }

  Future handleAuth() async {
    var user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      Timer(Duration(seconds: 2), () {
        return Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Signin()));
      });
      return;
    }

    if (isAdmin != null && isAdmin) {
      adminLogin(user);
      return;
    }

    getUserInfo(user);
  }

  Future adminLogin(FirebaseUser user) async {
    var doc = Firestore.instance.collection('admin').document(user.uid);
    var document = await doc.get();
    if (document.exists) {
      Timer(Duration(seconds: 1), () {
        return Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => AdminHome(
                  uid: user.uid,
                )));
      });
      return;
    }
    FirebaseAuth.instance.signOut();
    Timer(Duration(milliseconds: 1500), () {
      return Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => Signin()));
    });
  }

  Future getUserInfo(FirebaseUser user) async {
    var doc = Firestore.instance.collection('customers').document(user.uid);
    var document = await doc.get();
    if (document.exists) {
      UserModel userModel = UserModel.fromMap(document.data);
      Timer(Duration(milliseconds: 1500), () {
        return Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => Home(user.uid, userModel)));
      });
      return;
    }
    FirebaseAuth.instance.signOut();
    Timer(Duration(milliseconds: 1500), () {
      return Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => Signin()));
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
