import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_project_hariyal/utils.dart';

import 'widgets/network_image.dart';

class CheckOut extends StatefulWidget {
  final pid, uid, name, phone;

  CheckOut({this.pid, this.uid, this.name, this.phone});

  @override
  _CheckOutState createState() => _CheckOutState(name: name, phone: phone);
}

class _CheckOutState extends State<CheckOut> {
  Firestore firestore;
  bool isLoading = false;
  Utils utils;
  dynamic name, phone;

  _CheckOutState({this.name, this.phone});

  @override
  void initState() {
    firestore = Firestore.instance;
    utils = new Utils();
    super.initState();
  }

  void setLoading(bool value) {
    isLoading = value;
    handleState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<DocumentSnapshot>(
          stream: firestore
              .collection('customers')
              .document(widget.uid)
              .snapshots(),
          builder: (context, userSnap) {
            return userSnap != null && userSnap.data != null
                ? StreamBuilder<DocumentSnapshot>(
                    stream: firestore
                        .collection('products')
                        .document(widget.pid)
                        .snapshots(),
                    builder: (context, productSnap) {
                      return productSnap != null && productSnap.data != null
                          ? buildUI(
                              productSnap: productSnap, userSnap: userSnap)
                          : utils.loadingIndicator();
                    },
                  )
                : utils.loadingIndicator();
          },
        ),
      );
    } catch (e) {
      utils.errorWidget(e.toString());
    }
  }

  Widget buildUI({AsyncSnapshot<DocumentSnapshot> productSnap, userSnap}) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(12),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: PNetworkImage(
                          productSnap.data.data['images'][0],
                          fit: BoxFit.fitWidth,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Utils().camelCase(productSnap.data.data['title']),
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${productSnap.data.data['price']} Rs',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'User Info',
                    style: TextStyle(fontSize: 21),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: Colors.grey[700]),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(utils.camelCase(name),
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(
                                height: 20,
                              ),
                              Text(phone, style: TextStyle(fontSize: 18))
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              edit(context, userSnap, EditType.UserInfo);
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(0)),
                                  color: Colors.black26),
                              child: Icon(
                                Icons.edit,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Address',
                    style: TextStyle(fontSize: 21),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: Colors.grey[700]),
                    ),
                    child: userSnap.data['permanentAddress'] != 'default'
                        ? Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(12),
                                width: MediaQuery.of(context).size.width / 1.2,
                                child: Text(
                                  '${name}, ${userSnap.data.data['permanentAddress']}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    edit(context, userSnap, EditType.Address);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(0)),
                                        color: Colors.black26),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(
                            child: FlatButton(
                              onPressed: () {
                                edit(context, userSnap, EditType.Address);
                              },
                              child: Text('Add New Address',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 21),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        border: Border.all(color: Colors.grey)),
                    child: Column(
                      children: <Widget>[],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                color: Colors.blueAccent[400],
                onPressed: () {
                  //login();
                },
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(40.0),
                  ),
                ),
                child: Text(
                  'Proceed to payment ',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void edit(BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnap,
      editType) {
    final _addressController = TextEditingController();
    final _phoneController = TextEditingController();
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
                  children: <Widget>[
                    if (editType == EditType.Address)
                      Container(
                        margin: EdgeInsets.only(top: 24),
                        child: TextFormField(
                          controller: _addressController
                            ..text =
                                userSnap.data['permanentAddress'] == 'default'
                                    ? ""
                                    : userSnap.data['permanentAddress'],
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
                    if (editType == EditType.UserInfo)
                      Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 24),
                            child: TextFormField(
                              controller: _nameController..text = name,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
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
                          Container(
                            margin: EdgeInsets.only(top: 24),
                            child: TextFormField(
                              controller: _phoneController..text = phone,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
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
                                labelText: 'Phone',
                              ),
                            ),
                          )
                        ],
                      ),
                    Container(
                      width: MediaQuery.of(context).size.width - 32,
                      child: RaisedButton(
                        color: Colors.blueAccent,
                        onPressed: () async {
                          if (editType == EditType.Address) {
                            await firestore
                                .collection('customers')
                                .document(widget.uid)
                                .updateData({
                              "permanentAddress": _addressController.text
                            });
                          }
                          if (editType == EditType.UserInfo) {
                            if (_phoneController.text != phone) {
                              if (mounted) {
                                state(() {
                                  phone = _phoneController.text;
                                });
                              }
                            }
                            if (_nameController.text != name) {
                              if (mounted) {
                                state(() {
                                  name = _nameController.text;
                                });
                              }
                            }
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

  handleState() => (mounted) ? setState(() => null) : null;
}

enum EditType { Address, UserInfo }
