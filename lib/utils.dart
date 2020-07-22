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

  textFieldDecoration(
      {String hint, label, prefixText, Icon prefixIcon, suffixIcon}) {
    return new InputDecoration(
      border: new OutlineInputBorder(),
      labelStyle: TextStyle(fontSize: 18),
      hintText: hint != null ? hint : "",
      labelText: label != null ? label : "",
      prefixIcon: prefixIcon != null ? prefixIcon : null,
      prefixText: prefixText != null ? prefixText : null,
      suffixIcon: suffixIcon != null ? suffixIcon : null,
    );
  }

  String camelCase(String text) {
    if (text == null) throw ArgumentError("string: $text");

    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1)
            : word.toUpperCase())
        .join(' ');
  }
}
