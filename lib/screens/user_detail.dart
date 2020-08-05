import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String _pinCode = "default", _state = "default", _cityDistrict = "default";
  double _latitude = 0, _longitude = 0;
  var currentLocation;

  Location location = new Location();

  Future<void> uploadUserInfo() async {
    setLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone = await prefs.get("phone");

    Firestore.instance
        .collection('customers')
        .where('email', isEqualTo: _emailController.text)
        .getDocuments()
        .then((value) {
      if (value.documents.length <= 0) {
        Map<String, dynamic> _loc = new HashMap();
        _loc['lat'] = _latitude != null ? _latitude : 'default';
        _loc['long'] = _longitude != null ? _longitude : 'default';
        _loc['pinCode'] = _pinCode != null ? _pinCode : 'default';
        _loc['state'] = _state != null ? _state.toLowerCase() : 'default';
        _loc['cityDistrict'] =
            _cityDistrict != null ? _cityDistrict.toLowerCase() : 'default';
        Map<String, dynamic> _search = new HashMap();
        _search['area'] =
            _cityDistrict != null ? _cityDistrict.toLowerCase() : null;
        _search['category'] = null;
        _search['state'] = _state != null ? _state.toLowerCase() : null;
        _search['subCategory'] = null;
        Firestore.instance
            .collection('customers')
            .document(widget.uid)
            .setData({
          'name': _nameController.text.toLowerCase(),
          'email': _emailController.text,
          'phone': phone,
          'isBlocked': false,
          'image':
              'https://i.pinimg.com/originals/f6/65/32/f66532b96256ccd192361c6bb5e15360.jpg',
          'alternatePhoneNumber': 'default',
          'gender': 'default',
          'permanentAddress': 'default',
          'location': _loc,
          'search': _search,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
        });
        Firestore.instance
            .collection('interested')
            .document(widget.uid)
            .setData({'interested': []});
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
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
      bool serviceStatus = await location.serviceEnabled();
      if (!serviceStatus) {
        await location.requestService();
      }
      myLocation = await location.getLocation();
      await getLocationInfo(myLocation);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
        return;
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied, please enable it from app settings';
        print(error);
        return;
      }
      if (error != null)
        Utils().toast(context, error,
            bgColor: Colors.red[800], textColor: Colors.white);
      myLocation = null;
    } catch (e) {
      Utils().toast(context, e.toString(),
          bgColor: Colors.red[800], textColor: Colors.white);
      myLocation = null;
    }
  }

  Future getLocationInfo(LocationData myLocation) async {
    currentLocation = myLocation;
    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _latitude = myLocation.latitude;
    _longitude = myLocation.longitude;
    _pinCode = first.postalCode;
    _state = first.adminArea;
    _cityDistrict =
        first.locality == null ? first.subAdminArea : first.locality;
    handleSetState();
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
        !_emailController.text.endsWith('.com') ||
        !_emailController.text.contains('@')) {
      Utils().toast(context, 'Enter valid e-mail');
      return;
    }

    uploadUserInfo();
  }

  void setLoading(bool value) {
    isLoading = value;
    handleSetState();
  }

  @override
  void initState() {
    locationPerm();
    super.initState();
  }

  Future locationPerm() async {
    location.hasPermission().asStream().listen((event) async {
      if (event == PermissionStatus.granted) {
        requestLocation();
      } else if (event == PermissionStatus.denied) {
        await location.requestPermission();
        locationPerm();
      }
    });
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
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  getUserLocation();
                },
                child: Text('Continue'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: SpinKitRing(
                    color: Colors.cyan,
                    lineWidth: 5,
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
                        decoration: Utils().textFieldDecoration(
                            label: 'E-mail', hint: "E-mail"),
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
    } catch (e) {
      Utils().errorWidget(e.toString());
    }
  }

  handleSetState() => (mounted) ? setState(() {}) : null;
}
