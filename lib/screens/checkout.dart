import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_project_hariyal/utils.dart';

import 'widgets/network_image.dart';

class CheckOut extends StatefulWidget {
  final pid, uid;

  CheckOut({this.pid, this.uid});

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  Firestore firestore;
  bool isLoading = false;
  String _name = '', _phone = '';

  @override
  void initState() {
    firestore = Firestore.instance;
    super.initState();
  }

  void setLoading(bool value) {
    isLoading = value;
    handleState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Loading Item Details', style: TextStyle(fontSize: 21))
                ],
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: firestore
                  .collection('customers')
                  .document(widget.uid)
                  .snapshots(),
              builder: (context, userSnap) {
                _name = Utils().camelCase(userSnap.data.data['name']);
                _phone = userSnap.data.data['phone'];
                return userSnap != null && userSnap.hasData
                    ? StreamBuilder<DocumentSnapshot>(
                        stream: firestore
                            .collection('products')
                            .document(widget.pid)
                            .snapshots(),
                        builder: (context, productSnap) {
                          return productSnap != null && productSnap.hasData
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.all(12),
                                  child: Stack(
                                    children: <Widget>[
                                      SingleChildScrollView(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              50,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                    child: PNetworkImage(
                                                      productSnap.data
                                                          .data['images'][0],
                                                      fit: BoxFit.fitWidth,
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        Utils().camelCase(
                                                            productSnap.data
                                                                .data['title']),
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${productSnap.data.data['price']} Rs',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors
                                                                .grey[700]),
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
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(6)),
                                                  border: Border.all(
                                                      color: Colors.grey[700]),
                                                ),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(_name,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18)),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(_phone,
                                                              style: TextStyle(
                                                                  fontSize: 18))
                                                        ],
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: GestureDetector(
                                                        onTap: () {},
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(6),
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0)),
                                                              color: Colors
                                                                  .black26),
                                                          child: Icon(
                                                            Icons.edit,
                                                            color:
                                                                Colors.black87,
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(6)),
                                                  border: Border.all(
                                                      color: Colors.grey[700]),
                                                ),
                                                child: userSnap.data.data[
                                                            'permanentAddress'] !=
                                                        'default'
                                                    ? Stack(
                                                        children: <Widget>[
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                1.2,
                                                            child: Text(
                                                              '$_name, ${userSnap.data.data['permanentAddress']}',
                                                              style: TextStyle(
                                                                  fontSize: 20),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {},
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                0),
                                                                        topRight:
                                                                            Radius.circular(
                                                                                0),
                                                                        bottomLeft:
                                                                            Radius.circular(
                                                                                12),
                                                                        bottomRight:
                                                                            Radius.circular(
                                                                                0)),
                                                                    color: Colors
                                                                        .black26),
                                                                child: Icon(
                                                                  Icons.edit,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : Container(
                                                        child: FlatButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                              'Add New Address',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18)),
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(6)),
                                                    border: Border.all(
                                                        color: Colors.grey)),
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: RaisedButton(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.0),
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
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _error();
                        },
                      )
                    : _error();
              },
            ),
    );
  }

  Widget _error() {
    Center(
      child: Text(
        'Something went wrong',
        style: TextStyle(fontSize: 22),
      ),
    );
  }

  handleState() => (mounted) ? setState(() => null) : null;
}
