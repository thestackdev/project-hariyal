import 'package:flutter/material.dart';

import 'admin_screens/admins.dart';
import 'admin_screens/all_customers.dart';
import 'admin_screens/extras.dart';
import 'admin_screens/push_data.dart';
import 'admin_screens/reports.dart';
import 'admin_screens/requests.dart';
import 'admin_screens/sold_items.dart';
import 'admin_screens/user_intrests.dart';

class SuperuserHome extends StatefulWidget {
  final uid;

  const SuperuserHome({Key key, this.uid}) : super(key: key);

  @override
  _SuperuserHomeState createState() => _SuperuserHomeState();
}

class _SuperuserHomeState extends State<SuperuserHome> {
  String uid;
  int currentScreen = 0;
  final screenList = [
    Requests(),
    PushData(),
    SoldItems(),
    Reports(),
    UserIntrests(),
    AllCustomers(),
    Admins(),
    Extras(),
  ];
  final titleList = [
    'Requests',
    'PushData',
    'SoldItems',
    'Reports',
    'UserIntrests',
    'AllCustomers',
    'Admins',
    'Extras'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleList[currentScreen],
          style: TextStyle(
              letterSpacing: 1.0, fontSize: 23, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Container(
        width: 225,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 70,
                child: Text('//TODO Logo'),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 0;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[0])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 1;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[1])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 2;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[2])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 3;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[3])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 4;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[4])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 5;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[5])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 6;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[6])),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentScreen = 7;
                  });
                  Navigator.pop(context);
                },
                title: Center(child: Text(titleList[7])),
              ),
            ],
          ),
        ),
      ),
      body: screenList[currentScreen],
    );
  }
}
