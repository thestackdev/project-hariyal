import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project_hariyal/utils.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _phoneController = new TextEditingController();
  var suffixColor = Colors.grey;
  bool isLoading = false, showOtp = false, acceptTermsAndConditions = true;
  String loadingText = "", otp;

  GlobalKey<_SigninState> _scaffoldKey = GlobalKey<_SigninState>();

  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        if (value) {
          isLoading = true;
        } else {
          isLoading = false;
        }
      });
    }
  }

  void setLoadingText(String text) {
    if (mounted) {
      setState(() {
        loadingText = text;
      });
    }
  }

  void login() {
    FirebaseAuth _auth = FirebaseAuth.instance;

    if (!acceptTermsAndConditions) {
      Utils().toast(context, 'Accept to terms & conditions to continue');
      return;
    }

    if (_phoneController.text.length == 10) {
      setLoading(true);
      setLoadingText('Requesting Otp');
      try {
        _auth.verifyPhoneNumber(
          phoneNumber: '+91' + _phoneController.text,
          timeout: Duration(seconds: 60),
          verificationCompleted: (AuthCredential credential) {
            signIn(credential);
          },
          verificationFailed: (AuthException exception) {
            setLoading(false);
            Utils().toast(_scaffoldKey.currentContext, exception.message,
                bgColor: Colors.red[800], textColor: Colors.white);
          },
          codeSent: (String verificationId, [int forceResendingToken]) {
            setState(() {
              showOtp = true;
            });
            setLoading(false);
            if (otp.length == 6) {
              AuthCredential credential = PhoneAuthProvider.getCredential(
                  verificationId: verificationId, smsCode: otp);
              signIn(credential);
            }
          },
          codeAutoRetrievalTimeout: null,
        );
      } on PlatformException catch (e) {
        setLoading(false);
        print(e.details);
        Utils().toast(context, e.message);
      } catch (e) {
        setLoading(false);
        Utils().toast(context, e.toString());
      }
    }
  }

  signIn(AuthCredential credential) async {
    setLoading(true);
    setLoadingText("Signing In");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("phone", _phoneController.text);
      await FirebaseAuth.instance.signInWithCredential(credential);
      setLoading(false);
    } catch (e) {
      setLoading(false);
      Utils()
          .toast(_scaffoldKey.currentContext, 'Wrong Otp', bgColor: Colors.red);
    }
  }

  @override
  void initState() {
    _phoneController.addListener(() {
      if (_phoneController.text.length == 10) {
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        key: _scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: isLoading
                ? loadingUI()
                : ListView(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    children: [showOtp ? buildOtpView() : buildLoginUI()],
                  ),
          ),
        ),
      );
    } catch (e) {
      Utils().errorWidget(e.toString());
    }
  }

  Widget loadingUI() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SpinKitWave(
                color: Colors.blueAccent,
                size: 50.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              loadingText,
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
            )
          ]),
    );
  }

  Widget buildLoginUI() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Image.asset(
            'assets/hariyal.png',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height / 1.6,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: Utils().textFieldDecoration(
                        hint: "Phone Number",
                        label: "Phone Number",
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.blueAccent,
                        ),
                        suffixIcon: Icon(
                          Icons.check_circle,
                          color: suffixColor,
                        ),
                        prefixText: "+91  ")),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      onChanged: (bool value) {
                        setState(() {
                          acceptTermsAndConditions = value;
                        });
                      },
                      value: acceptTermsAndConditions,
                    ),
                    Text(
                      'I Agree To ',
                      style: TextStyle(fontSize: 18),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {},
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    color: Colors.blueAccent[400],
                    onPressed: () {
                      login();
                    },
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40.0),
                      ),
                    ),
                    child: Text(
                      'Request Otp',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOtpView() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Text(
                'ENTER OTP',
                textScaleFactor: 1.5,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'We have sent a one time verification code to your phone number ${_phoneController.text}',
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    showOtp = false;
                  });
                },
                textColor: Colors.blueAccent,
                child: Text(
                  'Change Number',
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width - 48,
                fieldWidth: 40,
                style: TextStyle(fontSize: 18),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.underline,
                keyboardType: TextInputType.number,
                onCompleted: (pin) {
                  if (pin.length != 6) {
                    Utils().toast(
                      _scaffoldKey.currentContext,
                      'Enter valid code',
                    );
                    return;
                  }
                  setState(() {
                    otp = pin;
                  });
                  login();
                },
              )
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 150,
            right: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                color: Colors.blueAccent[400],
                onPressed: () {
                  login();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(40.0),
                  ),
                ),
                elevation: 6,
                child: Text(
                  'Verify',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
