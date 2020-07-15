import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfile extends StatefulWidget {
  final uid;

  const EditProfile({Key key, this.uid}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Firestore firestore;

  String img =
      "https://i.pinimg.com/originals/f6/65/32/f66532b96256ccd192361c6bb5e15360.jpg";

  @override
  void initState() {
    firestore = Firestore.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            firestore.collection('customers').document(widget.uid).snapshots(),
        builder: (context, usersnap) {
          return SingleChildScrollView(
              child: Column(
            children: <Widget>[
              profileHeader(usersnap.data),
              const SizedBox(height: 10.0),
              userInfo(usersnap.data)
              //UserInfo(),
            ],
          ));
        },
      ),
    );
  }

  Widget profileHeader(DocumentSnapshot usersnap) {
    return Stack(
      children: <Widget>[
        Ink(
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
          ),
        ),
        Container(
          width: double.infinity,
          height: 250,
          padding: const EdgeInsets.only(bottom: 0.0, right: 0.0),
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialButton(
                color: Colors.white,
                shape: CircleBorder(),
                elevation: 0,
                child: Icon(Icons.edit),
                onPressed: () {
                  editFields(context, usersnap);
                },
              )
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 160),
          child: Column(
            children: <Widget>[
              avatar(),
              Text(
                usersnap.data['name'],
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget avatar() {
    return CircleAvatar(
      radius: 80 + 6.0,
      backgroundColor: Colors.grey.shade300,
      child: CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey.shade300,
        child: CircleAvatar(
          radius: 80 - 6.0,
          backgroundImage: NetworkImage(img),
        ),
      ),
    );
  }

  Widget userInfo(DocumentSnapshot usersnap) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            alignment: Alignment.topLeft,
            child: Text(
              "User Information",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Card(
            elevation: 6,
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ...ListTile.divideTiles(
                        color: Colors.grey,
                        tiles: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            leading: Icon(Icons.my_location),
                            title: Text("Location"),
                            subtitle: Text(usersnap['location']['state']),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text("Email"),
                            subtitle: Text(usersnap['email']),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text("Phone"),
                            subtitle: Text(usersnap['phone']),
                          ),
                          if (usersnap['alternatePhoneNumber'] != "default")
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Text("Alternate Phone"),
                              subtitle: Text(
                                  usersnap['alternatePhoneNumber'] == null
                                      ? ""
                                      : usersnap['alternatePhoneNumber']),
                            ),
                          if (usersnap['gender'] != "default")
                            ListTile(
                              leading: Icon(Icons.person_pin),
                              title: Text("Gender"),
                              subtitle: Text(usersnap['gender'] == null
                                  ? ""
                                  : usersnap['gender']),
                            ),
                          if (usersnap['permanentAddress'] != "default")
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text("Address"),
                              subtitle: Text(
                                  usersnap['permanentAddress'] == null
                                      ? ""
                                      : usersnap['permanentAddress']),
                            ),
                          if (usersnap['alternatePhoneNumber'] == "default" ||
                              usersnap['gender'] == "default" ||
                              usersnap['permanentAddress'] == "default")
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width - 32,
                              margin: EdgeInsets.only(top: 20),
                              child: RaisedButton(
                                onPressed: () =>
                                    addMoreFields(context, usersnap),
                                color: Colors.blueAccent.shade200,
                                child: Text(
                                  'Add more fields',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void addMoreFields(BuildContext context, DocumentSnapshot usersnap) {
    var genderValue = 'default';
    final _addressController = TextEditingController();
    final _alternatePhoneController = TextEditingController();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6))),
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              padding: MediaQuery.of(context).viewInsets,
              child: Wrap(
                children: [
                  if (usersnap['permanentAddress'] == 'default')
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      child: TextFormField(
                        controller: _addressController,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.pin_drop),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue)),
                          filled: true,
                          contentPadding: EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0),
                          labelText: 'Address',
                        ),
                      ),
                    ),
                  if (usersnap['alternatePhoneNumber'] == 'default')
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      child: TextFormField(
                        controller: _alternatePhoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        maxLength: 10,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue)),
                          filled: true,
                          contentPadding: EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0),
                          labelText: 'Alternate Phone',
                        ),
                      ),
                    ),
                  if (usersnap['gender'] == 'default')
                    Container(
                      margin: EdgeInsets.only(top: 24, bottom: 24),
                      child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            isDense: true,
                            labelStyle: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.blue)),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.blue)),
                          ),
                          isExpanded: true,
                          iconEnabledColor: Colors.grey,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          iconSize: 30,
                          elevation: 0,
                          onChanged: (newValue) {
                            setState(() {
                              genderValue = newValue;
                            });
                          },
                          items: <String>['Male', 'Female', 'default']
                              .map<DropdownMenuItem<String>>((e) {
                            return DropdownMenuItem<String>(
                                value: e,
                                child: Text(
                                  e.toString(),
                                  style: TextStyle(color: Colors.black),
                                ));
                          }).toList()),
                    ),
                  Container(
                    width: MediaQuery.of(context).size.width - 32,
                    child: RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        if (_alternatePhoneController.text.isNotEmpty) {
                          firestore
                              .collection('customers')
                              .document(widget.uid)
                              .updateData({
                            "alternatePhoneNumber":
                                _alternatePhoneController.text
                          });
                        }

                        if (_addressController.text.isNotEmpty) {
                          firestore
                              .collection('customers')
                              .document(widget.uid)
                              .updateData({
                            "permanentAddress": _addressController.text
                          });
                        }

                        if (genderValue != 'default') {
                          firestore
                              .collection('customers')
                              .document(widget.uid)
                              .updateData({"gender": genderValue});
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  void editFields(BuildContext context, DocumentSnapshot usersnap) {
    var genderValue = usersnap['gender'];
    final _addressController = TextEditingController();
    final _alternatePhoneController = TextEditingController();
    final _nameController = TextEditingController();

    showModalBottomSheet(
        isDismissible: false,
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6))),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: MediaQuery.of(context).viewInsets,
                child: Wrap(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      child: TextFormField(
                        controller: _nameController..text = usersnap['name'],
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue)),
                          filled: true,
                          contentPadding: EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 10.0),
                          labelText: 'Name',
                        ),
                      ),
                    ),
                    if (usersnap['permanentAddress'] != 'default')
                      Container(
                        margin: EdgeInsets.only(top: 24),
                        child: TextFormField(
                          controller: _addressController
                            ..text = usersnap['permanentAddress'],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          decoration: new InputDecoration(
                            prefixIcon: Icon(Icons.pin_drop),
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.blue)),
                            filled: true,
                            contentPadding: EdgeInsets.only(
                                bottom: 10.0, left: 10.0, right: 10.0),
                            labelText: 'Address',
                          ),
                        ),
                      ),
                    if (usersnap['alternatePhoneNumber'] != 'default')
                      Container(
                        margin: EdgeInsets.only(top: 24),
                        child: TextFormField(
                          controller: _alternatePhoneController
                            ..text = usersnap['alternatePhoneNumber'],
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          maxLength: 10,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          decoration: new InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: Colors.blue)),
                            filled: true,
                            contentPadding: EdgeInsets.only(
                                bottom: 10.0, left: 10.0, right: 10.0),
                            labelText: 'Alternate Phone',
                          ),
                        ),
                      ),
                    if (usersnap['gender'] != 'default')
                      Container(
                        margin: EdgeInsets.only(top: 24, bottom: 24),
                        child: DropdownButtonFormField(
                            value: usersnap['gender'],
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              isDense: true,
                              labelStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.blue)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.blue)),
                            ),
                            isExpanded: true,
                            iconEnabledColor: Colors.grey,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            iconSize: 30,
                            elevation: 0,
                            onChanged: (newValue) {
                              setState(() {
                                genderValue = newValue;
                              });
                            },
                            items: <String>['Male', 'Female', 'default']
                                .map<DropdownMenuItem<String>>((e) {
                              return DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e.toString(),
                                    style: TextStyle(color: Colors.black),
                                  ));
                            }).toList()),
                      ),
                    Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: RaisedButton(
                        color: Colors.blueAccent,
                        onPressed: () {
                          if (_alternatePhoneController.text.isNotEmpty &&
                              _alternatePhoneController.text.length == 10 &&
                              _alternatePhoneController.text !=
                                  usersnap['alternatePhoneNumber']) {
                            firestore
                                .collection('customers')
                                .document(widget.uid)
                                .updateData({
                              "alternatePhoneNumber":
                              _alternatePhoneController.text
                            });
                          }

                          if (_addressController.text.isNotEmpty &&
                              _addressController.text !=
                                  usersnap['permanentAdress']) {
                            firestore
                                .collection('customers')
                                .document(widget.uid)
                                .updateData({
                              "permanentAddress": _addressController.text
                            });
                          }

                          if (_addressController.text != usersnap['gender']) {
                            firestore
                                .collection('customers')
                                .document(widget.uid)
                                .updateData({"gender": genderValue});
                          }

                          if (_nameController.text.isNotEmpty &&
                              _nameController.text != usersnap['name']) {
                            firestore
                                .collection('customers')
                                .document(widget.uid)
                                .updateData({"name": _nameController.text});
                          }

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }
}
