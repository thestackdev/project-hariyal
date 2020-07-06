import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  final List<Color> colors = [
    Colors.yellow[900],
    Colors.blue[800],
    Colors.green[700],
    Colors.black,
    Colors.brown[700],
    Colors.teal
  ];

  Color randomGenerator() {
    return colors[new Random().nextInt(6)];
  }

  void toast(BuildContext context, String text, {Color bgColor, textColor}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor:
            bgColor != null ? bgColor : Theme.of(context).accentColor,
        textColor: textColor != null ? textColor : Colors.white,
        fontSize: 16.0,
        webPosition: 'center');
  }
}
