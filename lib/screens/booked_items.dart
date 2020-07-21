import 'package:flutter/material.dart';

class BookedItems extends StatefulWidget {
  @override
  _BookedItemsState createState() => _BookedItemsState();
}

class _BookedItemsState extends State<BookedItems> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Items'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'No Items Booked Yet',
            textScaleFactor: 3,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
