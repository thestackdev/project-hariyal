import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project_hariyal/screens/admin/admin_home.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/signin.dart';
import 'package:the_project_hariyal/screens/superuser/superuser_home.dart';

class AuthServices {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences _preferences;

  clearAllData() async {
    _preferences = await SharedPreferences.getInstance();
    _preferences.clear();
  }

  handleAdminAuth() async {
    return StreamBuilder<FirebaseUser>(
      stream: _auth.onAuthStateChanged,
      builder: (_, snap) {
        if (snap.hasData) {
          if (snap.data.uid == null) {
            logout();
            return Signin();
          } else {
            return AdminHome(
              uid: snap.data.uid,
            );
          }
        } else {
          return Signin();
        }
      },
    );
  }

  handleSuperAdminAuth() {
    return StreamBuilder<FirebaseUser>(
      stream: _auth.onAuthStateChanged,
      builder: (_, snap) {
        if (snap.hasData) {
          if (snap.data.uid == null) {
            logout();
            return Signin();
          } else {
            return SuperuserHome(
              uid: snap.data.uid,
            );
          }
        } else {
          return Signin();
        }
      },
    );
  }

  handleAuth() {
    return StreamBuilder(
      stream: _auth.onAuthStateChanged,
      builder: (_, snap) {
        if (snap.hasData) {
          return Home();
        } else {
          return Signin();
        }
      },
    );
  }

  superuserLogin(email, password) async {
    Fluttertoast.showToast(msg: 'Authenticating...');
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _firestore
          .collection('admin')
          .document(result.user.uid)
          .get()
          .then(
        (value) async {
          if (value.data['super_admin'] == true) {
            _preferences = await SharedPreferences.getInstance();
            _preferences.setBool('SuperAdmin', true);
            return true;
          } else {
            _auth.signOut();
            Fluttertoast.showToast(msg: 'You are just an Admin !');
            return false;
          }
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  adminLogin(email, password) async {
    Fluttertoast.showToast(msg: 'Authenticating...');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _preferences = await SharedPreferences.getInstance();
      _preferences.setBool('Admin', true);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  logout() async {
    _auth.signOut();
    clearAllData();
  }

  addAdmin(email, password, name) async {
    Fluttertoast.showToast(msg: 'Just a sec...');
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _firestore.collection('admin').document(result.user.uid).setData(
        {
          'since': DateTime
              .now()
              .millisecondsSinceEpoch,
          'name': name,
          'super_amdin': false,
        },
      );

      Fluttertoast.showToast(msg: 'Admin Sucessfully Added !');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }
}
