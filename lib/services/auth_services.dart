import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:the_project_hariyal/screens/home.dart';
import 'package:the_project_hariyal/screens/signin.dart';

class AuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;

  handleAuth() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Home(uid: snapshot.data.uid);
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
