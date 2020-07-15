import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:the_project_hariyal/screens/home.dart';
import 'package:the_project_hariyal/utils.dart';

class UserDetails extends StatefulWidget {
  final uid;

  UserDetails(this.uid);

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  bool isLoading = false;

  String _pinCode, _state, _cityDistrict;
  double _latitude, _longitude;
  var currentLocation;

  Location location = new Location();

  void checkLocationEnabled() async {
    bool serviceStatus = await location.serviceEnabled();

    if (!serviceStatus) {
      await location.requestService();
    }

    setLoading(true);

    await getUserLocation();
    uploadUserInfo();
  }

  void uploadUserInfo() {
    Firestore.instance
        .collection('customers')
        .where('email', isEqualTo: _emailController.text)
        .getDocuments()
        .then((value) {
      if (value.documents.length <= 0) {
        Map<String, dynamic> _loc = new HashMap();
        _loc['lat'] = _latitude != null ? _latitude : "default";
        _loc['long'] = _longitude != null ? _longitude : "default";
        _loc['pinCode'] = _pinCode != null ? _pinCode : "default";
        _loc['state'] = _state != null ? _state : "telangana";
        _loc['cityDistrict'] =
            _cityDistrict != null ? _cityDistrict : "hyderabad";
        Firestore.instance
            .collection('customers')
            .document(widget.uid)
            .setData({
          'name': _nameController.text,
          'email': _emailController.text,
          "location": _loc
        });
        Firestore.instance
            .collection('interested')
            .document(widget.uid)
            .setData({
          'interested': ["0"]
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(
                  uid: widget.uid,
                )));
      } else {
        setLoading(false);
        Utils().toast(context, 'E-mail already in use by another user');
      }
    });
  }

  getUserLocation() async {
    LocationData myLocation;
    String error;
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
        Navigator.pop(context);
        return;
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied, please enable it from app settings';
        print(error);
        Navigator.pop(context);
        return;
      }
      Utils().toast(context, error,
          bgColor: Colors.red[800], textColor: Colors.white);
      myLocation = null;
      Navigator.pop(context);
    }

    currentLocation = myLocation;
    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _latitude = myLocation.latitude;
      _longitude = myLocation.longitude;
      _pinCode = first.postalCode;
      _state = first.adminArea;
      _cityDistrict =
          first.locality == null ? first.subAdminArea : first.locality;
    });
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void next() async {
    if (_nameController.text.isEmpty) {
      Utils().toast(context, 'Enter valid name');
      return;
    }
    if (_emailController.text.isEmpty ||
        !_emailController.text.endsWith('.com')) {
      Utils().toast(context, 'Enter valid e-mail');
      return;
    }

    await requestLocation();
  }

  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        isLoading = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future requestLocation() async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Location Request'),
            content: Text(
                'We request location only for filtering products near by you'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  setLoading(true);
                  uploadUserInfo();
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  checkLocationEnabled();
                },
                child: Text('Continue'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(
                child: SpinKitWave(
                  color: Colors.orange,
                  size: 50.0,
                ),
              )
            : Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                      focusNode: _nameFocusNode,
                      controller: _nameController,
                      onFieldSubmitted: (_) {
                        fieldFocusChange(
                            context, _nameFocusNode, _emailFocusNode);
                      },
                      keyboardType: TextInputType.text,
                      decoration: Utils()
                          .textFieldDecoration(label: 'Name', hint: "Name"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      onFieldSubmitted: (_) {
                        next();
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: Utils()
                          .textFieldDecoration(label: 'E-mail', hint: "E-mail"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        color: Colors.blueAccent[400],
                        onPressed: next,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
