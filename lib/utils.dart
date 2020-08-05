import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  Widget loadingIndicator() {
    return Center(
      child: SpinKitRing(
        color: Colors.cyan,
        lineWidth: 5,
      ),
    );
  }

  Widget errorWidget(String error) {
    if (error == null)
      error = 'Something wen\'t wrong, try restarting app or contact developer';
    else
      error =
          '$error\nSomething wen\'t wrong, try restarting app or contact developer';
    return Center(
      child: Text(error),
    );
  }

  Widget productInputDropDown({
    String label,
    List items,
    Function onChanged,
    String value,
    bool isShowroom = false,
    String Function(dynamic) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27, vertical: 9),
      child: DropdownButtonFormField(
        validator: (value) => value == null ? 'Field can\'t be empty' : null,
        value: value,
        decoration: inputDecoration(label: label),
        isExpanded: true,
        iconEnabledColor: Colors.grey,
        style: inputTextStyle(),
        iconSize: 30,
        elevation: 9,
        onChanged: onChanged,
        items: items.map((e) {
          return DropdownMenuItem(
            value: isShowroom ? e.data['name'] : e,
            child: Text(isShowroom ? e.data['name'] : e),
          );
        }).toList(),
      ),
    );
  }

  TextStyle inputTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.grey.shade700,
    );
  }

  TextStyle textStyle({Color color, double fontSize}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      letterSpacing: 1.0,
      color: color,
    );
  }

  InputDecoration inputDecoration({String label, IconData iconData}) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      labelStyle: textStyle(color: Colors.red),
      contentPadding: EdgeInsets.all(16),
      border: InputBorder.none,
      fillColor: Colors.grey.shade100,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade100,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade100,
        ),
      ),
    );
  }

  nullWidget(String nullMessage) {
    if (nullMessage == null) nullMessage = 'Something wen\'t wrong, Empty';
    return Center(
      child: Text(
        nullMessage,
        style: textStyle(
          color: Colors.grey.shade700,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget drawerTile({String label, Function onTap}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 48),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.start,
        ),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}
