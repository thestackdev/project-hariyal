import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' show Location;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;

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
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 27),
              child: Text(
                'Sign Up',
                style: titleStyle,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 9, horizontal: 27),
              child: Text(
                'Hi there! Register for Hariyal !',
                style: contentStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
              child: TextField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                  contentPadding: EdgeInsets.all(12),
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
                  prefix: Icon(
                    MdiIcons.accountOutline,
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 9),
              child: TextField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  isDense: true,
                  labelStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                  contentPadding: EdgeInsets.all(12),
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
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      MdiIcons.emailOutline,
                      color: Colors.red.shade300,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 18),
              child: TextField(
                maxLength: 10,
                maxLines: 1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    isDense: true,
                    labelStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    contentPadding: EdgeInsets.all(16),
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
                    prefix: Text('+91 ')),
              ),
            ),
            Center(
              child: RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 30),
                elevation: 0,
                onPressed: () async {
                  if (!(await Geolocator().isLocationServiceEnabled())) {
                    if (await Location.instance.requestService()) {
                      _getCurrentLocation();
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Sorry Please location services');
                    }
                  } else {
                    _getCurrentLocation();
                  }
                },
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
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an Account ? Sign in',
                  style: TextStyle(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
