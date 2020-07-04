import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/signin.dart';

class AuthServices {
  Firestore _firestore = Firestore.instance;
  SharedPreferences _preferences;
  handleAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (_, snap) {
        if (snap.hasData) {
          return Home();
        } else {
          return Signin();
        }
      },
    );
  }

  superuserLogin(email, password) {
    return _firestore
        .collection('admin')
        .document('super_admin')
        .get()
        .then((value) async {
      if (value.data['email'] == email && value.data['password'] == password) {
        _preferences = await SharedPreferences.getInstance();
        _preferences.setBool('SuperAdmin', true);
        return true;
      } else {
        return false;
      }
    });
  }

  adminLogin(email, password) {
    return _firestore
        .collection('admin')
        .document(email)
        .get()
        .then((value) async {
      try {
        if (value.data['password'] == password) {
          _preferences = await SharedPreferences.getInstance();
          _preferences.setString('Admin', email);
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    });
  }

  Future superuserLogout() async {
    _preferences = await SharedPreferences.getInstance();
    _preferences.remove('SuperAdmin');
  }
}
