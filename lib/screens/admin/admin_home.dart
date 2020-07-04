import 'package:flutter/material.dart';

import 'admin_insert_data.dart';
import 'admin_view_data.dart';

class AdminHome extends StatefulWidget {
  final email;

  const AdminHome({Key key, this.email}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Admin Console',
            style: TextStyle(fontSize: 25),
          ),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Insert Data',
              ),
              Tab(
                text: 'View Data',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AdminInsertData(),
            AdminViewData(),
          ],
        ),
      ),
    );
  }
}
