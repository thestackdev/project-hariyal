import 'package:flutter/material.dart';
import 'package:the_project_hariyal/services/auth_services.dart';

class AdminExtras extends StatefulWidget {
  @override
  _AdminExtrasState createState() => _AdminExtrasState();
}

class _AdminExtrasState extends State<AdminExtras> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          onTap: () async {
            await AuthServices().logout();
          },
          title: Center(
            child: Text('Logout'),
          ),
        )
      ],
    );
  }
}
