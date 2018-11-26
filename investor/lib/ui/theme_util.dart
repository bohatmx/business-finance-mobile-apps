import 'package:flutter/material.dart';

ThemeData getTheme() {
  Color primary = Colors.lime.shade900;
  Color cardColor = Colors.grey.shade50;
  Color back = Colors.pink.shade50;
  Color buttonColor = Colors.indigo.shade600;

  ThemeData mData = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: primary,
    accentColor: Colors.pink,
    cardColor: cardColor,
    backgroundColor: back,
    buttonColor: buttonColor,
  );

  return mData;
}
