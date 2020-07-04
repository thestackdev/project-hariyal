import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/admin/authenticate.dart';
import 'package:the_project_hariyal/screens/superuser/authenticate.dart';

import 'signup.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
        color: Colors.grey.shade700, fontSize: 30, fontWeight: FontWeight.bold);
    final contentStyle = TextStyle(
        color: Colors.grey, fontSize: 18, fontWeight: FontWeight.normal);
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 70),
              child: Center(child: Text('//TODO Logo')),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 27),
              child: Text(
                'Sign In',
                style: titleStyle,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 27),
              child: Text(
                'Hi there! Nice to see you again.',
                style: contentStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
              child: TextField(
                maxLength: 10,
                maxLines: 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                  contentPadding: EdgeInsets.all(18),
                  border: InputBorder.none,
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefix: Text('+91 '),
                ),
              ),
            ),
            Center(
              child: RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 30),
                elevation: 0,
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                color: Colors.red.shade300,
                child: Text(
                  'Request OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return Signup();
                  }));
                },
                child: Text(
                  'Sign Up?',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return AdminAthenticate();
                  }));
                },
                child: Text(
                  'Superuser ?',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return AdminAuthenticate();
                  }));
                },
                child: Text(
                  'Admin ?',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
