import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:the_project_hariyal/screens/home.dart';
import 'package:the_project_hariyal/utils.dart';

class Payment extends StatefulWidget {
  final order;

  Payment(this.order);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isLoading = true;
  Firestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = Firestore.instance;
    if (widget.order['status'] == 'SUCCESS') {
      firestore.collection('orders').add(widget.order);
      firestore
          .collection('products')
          .document(widget.order['pid'])
          .updateData({
        'isSold': true,
        'soldReason': 'Sold to ${widget.order['name']}',
        'soldTo': widget.order['uid'],
        'sold_timestamp': widget.order['timeStamp']
      }).then((value) {
        isLoading = false;
        handleState();
        return null;
      });
    } else {
      isLoading = false;
      handleState();
    }
  }

  handleState() => (mounted) ? setState(() => null) : null;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (isLoading) {
          Utils().toast('Please wait until payment is completed');
          return;
        }
        widget.order['status'] == 'SUCCESS'
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Home(),
                ),
              )
            : Navigator.of(context).pop(true);
        return;
      },
      child: isLoading
          ? Container(
              color: Colors.white,
              child: SpinKitRing(
                color: Theme.of(context).accentColor,
              ),
            )
          : Scaffold(
              body: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey[200]),
                          child: Icon(
                            widget.order['status'] == 'SUCCESS'
                                ? Icons.done
                                : Icons.error_outline,
                            size: 100,
                            color: widget.order['status'] == 'SUCCESS'
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                        ListTile(
                          title: Text(
                            widget.order['status'] == 'SUCCESS'
                                ? 'Thank You!'
                                : 'Failed',
                            style: TextStyle(
                                fontSize: 42,
                                color: Colors.black45,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: FittedBox(
                            child: Text(
                              widget.order['status'] == 'SUCCESS'
                                  ? '\nYour Product is Booked Successfully.'
                                  : '\nPayment Failed, Please try again or contact support',
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        if (widget.order['status'] == 'ERROR')
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            padding: EdgeInsets.all(12),
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              color: Colors.transparent,
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6.0),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        Container(
                          width: widget.order['status'] != 'ERROR'
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width / 2,
                          padding: EdgeInsets.all(12),
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            color: Colors.blueAccent[400],
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Home(),
                                ),
                              );
                            },
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                            ),
                            child: Text(
                              'Home',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
