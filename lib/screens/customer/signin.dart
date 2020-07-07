import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_project_hariyal/screens/admin/authenticate.dart';
import 'package:the_project_hariyal/screens/customer/home.dart';
import 'package:the_project_hariyal/screens/customer/models/user_model.dart';
import 'package:the_project_hariyal/utils.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'signup.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _controller = new TextEditingController();
  final _codeController = new TextEditingController();
  var suffixColor = Colors.grey;
  bool _isOpen = false;

  GlobalKey _scaffoldKey = GlobalKey();

  void login() {
    if (_controller.text.length == 10) {
      FirebaseAuth _auth = FirebaseAuth.instance;

      _showDialog(text: 'Authenticating');

      Firestore.instance
          .collection('customers')
          .where('phoneNumber', isEqualTo: _controller.text)
          .snapshots()
          .listen((data) {
        if (data.documents.length <= 0) {
          _hideDialog();
          Utils().toast(context, 'User Not Found');
        } else {
          _hideDialog();
          _showDialog(text: 'Requesting Otp');
          _auth.verifyPhoneNumber(
              phoneNumber: '+91' + _controller.text,
              timeout: Duration(seconds: 60),
              verificationCompleted: (AuthCredential credential) async {
                AuthResult result =
                    await _auth.signInWithCredential(credential);

                FirebaseUser user = result.user;

                if (user != null) {
                  UserModel userModel = await getUserInfo();
                  _hideDialog();
                  Navigator.pushReplacement(
                      _scaffoldKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => Home(user.uid, userModel)));
                } else {
                  _hideDialog();
                  Utils().toast(_scaffoldKey.currentContext, 'Failed to SignUp',
                      bgColor: Utils().randomGenerator());
                  print("Error: Failed to SignUp");
                }
              },
              verificationFailed: (AuthException exception) {
                _hideDialog();
                Utils().toast(_scaffoldKey.currentContext, exception.message,
                    bgColor: Colors.red[800], textColor: Colors.white);
                print(exception);
              },
              codeSent: (String verificationId, [int forceResendingToken]) {
                _hideDialog();
                showDialog(
                    context: _scaffoldKey.currentContext,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Enter the code"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _codeController,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Confirm"),
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () async {
                              if (_codeController.text.length != 6) {
                                Utils().toast(_scaffoldKey.currentContext,
                                    'Enter valid code');
                                return;
                              }

                              Navigator.of(_scaffoldKey.currentContext).pop();
                              _showDialog(text: "Signing in");

                              final code = _codeController.text.trim();
                              AuthCredential credential =
                                  PhoneAuthProvider.getCredential(
                                      verificationId: verificationId,
                                      smsCode: code);

                              AuthResult result =
                                  await _auth.signInWithCredential(credential);

                              FirebaseUser user = result.user;

                              if (user != null) {
                                UserModel userModel = await getUserInfo();
                                _hideDialog();
                                Navigator.pushReplacement(
                                    _scaffoldKey.currentContext,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Home(user.uid, userModel)));
                              } else {
                                _hideDialog();
                                Utils().toast(_scaffoldKey.currentContext,
                                    'Failed to SignUp',
                                    bgColor: Utils().randomGenerator());
                                print("Error: Failed to SignUp");
                              }
                            },
                          )
                        ],
                      );
                    });
              },
              codeAutoRetrievalTimeout: null);
        }
      });
    }
  }

  getUserInfo() async {
    var user = await FirebaseAuth.instance.currentUser();

    var doc = Firestore.instance.collection('customers').document(user.uid);
    var document = await doc.get();
    return UserModel.fromMap(document.data);
  }

  Future<bool> _showDialog({String text}) async {
    setState(() {
      _isOpen = true;
    });

    return (await showDialog(
      context: _scaffoldKey.currentContext,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () {},
        child: AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                color: Colors.black12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      text != null && text.isNotEmpty ? text : 'Loading',
                      textScaleFactor: 1.2,
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  void _hideDialog() {
    if (_isOpen) {
      Navigator.of(_scaffoldKey.currentContext).pop(true);
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.text.length == 10) {
        setState(() {
          suffixColor = Colors.green;
        });
      } else {
        setState(() {
          suffixColor = Colors.red;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 650,
              child: RotatedBox(
                quarterTurns: 2,
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: [
                      [Colors.deepPurple, Colors.deepPurple.shade200],
                      [Colors.indigo.shade200, Colors.purple.shade200],
                    ],
                    durations: [19440, 10800],
                    heightPercentages: [0.20, 0.25],
                    blur: MaskFilter.blur(BlurStyle.solid, 10),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  waveAmplitude: 0,
                  size: Size(
                    double.infinity,
                    double.infinity,
                  ),
                ),
              ),
            ),
            ListView(
              children: [
                Container(
                  height: 500,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36.0)),
                        Card(
                          margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                          elevation: 11,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                          child: TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.call),
                                prefix: Text(
                                  '+91 ',
                                  style: TextStyle(color: Colors.black),
                                ),
                                suffixIcon: Icon(
                                  Icons.check_circle,
                                  color: suffixColor,
                                ),
                                hintText: "Phone Number",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40.0)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 16.0)),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(30.0),
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            color: Colors.pink[400],
                            onPressed: () {
                              login();
                            },
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                            child: Text("Request Otp",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        ),
                      ]),
                )
              ],
            ),
            SizedBox(
              height: 100,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "or, Login as",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Expanded(
                        child: RaisedButton(
                          child: Text(
                            "Admin",
                            style: TextStyle(fontSize: 16),
                          ),
                          textColor: Colors.white,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          onPressed: () {
                            Navigator.push(_scaffoldKey.currentContext,
                                MaterialPageRoute(builder: (_) {
                                  return AdminAuthenticate();
                                }));
                          },
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Don't have an account?"),
                      FlatButton(
                        child: Text(
                          "Sign up",
                          style: TextStyle(fontSize: 16),
                        ),
                        textColor: Colors.indigo,
                        onPressed: () {
                          Navigator.push(_scaffoldKey.currentContext,
                              MaterialPageRoute(builder: (_) {
                                return Signup();
                              }));
                        },
                      )
                    ],
                  ),
                  Divider()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
