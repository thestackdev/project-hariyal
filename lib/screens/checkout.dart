import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:the_project_hariyal/screens/payment.dart';
import 'package:the_project_hariyal/utils.dart';

import 'widgets/network_image.dart';

class CheckOut extends StatefulWidget {
  final info;

  CheckOut({this.info});

  @override
  _CheckOutState createState() => _CheckOutState(
      name: info['name'],
      phone: info['phone'],
      address: info['address'],
      pid: info['pid'],
      uid: info['uid']);
}

class _CheckOutState extends State<CheckOut> {
  Firestore firestore;
  Utils utils;
  dynamic name, phone, uid, pid, address;
  Razorpay razorpay;

  _CheckOutState({this.name, this.phone, this.uid, this.pid, this.address});

  @override
  void initState() {
    super.initState();
    firestore = Firestore.instance;
    utils = Utils();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  details(String status, {paymentId, errorReason}) {
    return {
      'pid': pid,
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': widget.info['email'],
      'address': address,
      'status': status,
      'reason': errorReason,
      'payment_id': paymentId,
      'timeStamp': DateTime.now().millisecondsSinceEpoch.toString()
    };
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    changeScreen(Payment(details('SUCCESS',
        paymentId: response.paymentId, errorReason: 'default')));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    changeScreen(Payment(
        details('ERROR', errorReason: response.message, paymentId: 'default')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    utils.toast("EXTERNAL_WALLET: " + response.walletName);
  }

  void changeScreen(screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection('products').document(pid).snapshots(),
          builder: (context, productSnap) {
            return productSnap != null && productSnap.data != null
                ? buildUI(productSnap)
                : utils.loadingIndicator();
          },
        ),
      );
    } catch (e) {
      return utils.errorWidget(e.toString());
    }
  }

  Widget buildUI(AsyncSnapshot<DocumentSnapshot> productSnap) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: EdgeInsets.all(12),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height - 50,
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
                              edit(context, EditType.UserInfo);
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
                    child: address != 'default'
                        ? Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(12),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          child: Text(
                            '$name, $address',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              edit(context, EditType.Address);
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
                                edit(context, EditType.Address);
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
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        border: Border.all(color: Colors.grey)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'C-GST',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.start,
                            ),
                            Spacer(),
                            Text(
                              '0 Rs.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'S-GST',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.start,
                            ),
                            Spacer(),
                            Text(
                              '0 Rs.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Product Price',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.start,
                            ),
                            Spacer(),
                            Text(
                              '${productSnap.data.data['price']
                                  .toString()} Rs.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.start,
                            ),
                            Spacer(),
                            Text(
                              '${productSnap.data.data['price']
                                  .toString()} Rs.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        )
                      ],
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
                  var options = {
                    'key': 'rzp_test_xRqW3eFH7qCf8l',
                    'amount':
                    num.parse(productSnap.data.data['price'].toString()) *
                        100,
                    'name': utils.camelCase(name),
                    'description':
                    utils.camelCase(productSnap.data.data['title']),
                    'prefill': {'contact': phone, 'email': widget.info['email']}
                  };

                  try {
                    razorpay.open(options);
                  } catch (e) {
                    debugPrint(e);
                  }
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

  void edit(BuildContext context, editType) {
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
                            ..text = address == 'default' ? "" : address,
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
                            if (_addressController.text.trim() != address &&
                                _addressController.text
                                    .trim()
                                    .length >= 10) {
                              address = _addressController.text.toLowerCase();
                            }
                          }
                          if (editType == EditType.UserInfo) {
                            if (_phoneController.text.trim() != phone &&
                                _phoneController.text
                                    .trim()
                                    .length == 10) {
                              phone = _phoneController.text;
                            }
                            if (_nameController.text != name &&
                                _nameController.text
                                    .trim()
                                    .length >= 3) {
                              name = _nameController.text.toLowerCase();
                            }
                          }
                          handleState();
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
