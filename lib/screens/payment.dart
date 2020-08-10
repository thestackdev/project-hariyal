import 'package:flutter/material.dart';
import 'package:the_project_hariyal/screens/home.dart';

class Payment extends StatelessWidget {
  final order;

  Payment(this.order);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        order['status'] == 'SUCCESS'
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Home(),
                ),
              )
            : Navigator.of(context).pop(true);
        return;
      },
      child: Scaffold(
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
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        color: Colors.grey[200]),
                    child: Icon(
                      order['status'] == 'SUCCESS'
                          ? Icons.done
                          : Icons.error_outline,
                      size: 100,
                      color: order['status'] == 'SUCCESS'
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      order['status'] == 'SUCCESS' ? 'Thank You!' : 'Failed',
                      style: TextStyle(
                          fontSize: 42,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: FittedBox(
                      child: Text(
                        order['status'] == 'SUCCESS'
                            ? '\nYour Product is Booked Successfully.'
                            : '\nPayment Failed, Please try again or contact support',
                        style: TextStyle(
                            color: Colors.black38, fontWeight: FontWeight.bold),
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
                  if (order['status'] == 'ERROR')
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
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ),
                  Container(
                    width: order['status'] != 'ERROR'
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
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
