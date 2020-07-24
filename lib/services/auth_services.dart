import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_data_stream_builder/flutter_data_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:the_project_hariyal/screens/home.dart';
import 'package:the_project_hariyal/screens/signin.dart';
import 'package:the_project_hariyal/utils.dart';

class AuthServices {
  final Utils utils = Utils();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  final appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Ubuntu',
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  handleAuth() {
    return DataStreamBuilder<FirebaseUser>(
      errorBuilder: (context, error) => utils.errorWidget(error.toString()),
      loadingBuilder: (context) =>
          Container(color: Colors.white, child: utils.loadingIndicator()),
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot != null) {
          return MultiProvider(
            providers: [
              StreamProvider<DocumentSnapshot>.value(
                initialData: null,
                value: firestore
                    .collection('customers')
                    .document(snapshot.uid)
                    .snapshots(),
              ),
              StreamProvider<QuerySnapshot>.value(
                initialData: null,
                value: firestore.collection('extras').snapshots(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: appTheme,
              home: Home(),
            ),
          );
        } else {
          return Signin();
        }
      },
    );
  }

  logout() async {
    _auth.signOut();
  }
}
