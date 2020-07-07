import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  void getUserInfo() async {
    var user = await FirebaseAuth.instance.currentUser();

    var doc = Firestore.instance.collection('customers').document(user.uid);
    var document = await doc.get();
    UserModel userModel = UserModel.fromMap(document.data);

    Timer(
        Duration(seconds: 1),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => Home(user.uid, userModel))));
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
