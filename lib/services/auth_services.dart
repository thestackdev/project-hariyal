import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:the_project_hariyal/screens/admin/admin_home.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/signin.dart';

class AuthServices {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  handleAuth() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.email != null) {
            return AdminHome(uid: snapshot.data.uid);
          } else {
            return Home(uid: snapshot.data.uid);
          }
        } else {
          return Signin();
        }
      },
    );
  }

  adminLogin(email, password) async {
    Fluttertoast.showToast(msg: 'Authenticating...');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  logout() async {
    _auth.signOut();
  }

  addAdmin(email, password, name) async {
    Fluttertoast.showToast(msg: 'Just a sec...');
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _db.collection('admin').document(result.user.uid).setData(
        {
          'since': DateTime.now().millisecondsSinceEpoch,
          'name': name,
          'super_admin': false,
        },
      );

      Fluttertoast.showToast(msg: 'Admin Successfully Added!');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }
}
