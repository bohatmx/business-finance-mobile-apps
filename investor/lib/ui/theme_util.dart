import 'package:flutter/material.dart';

ThemeData getTheme() {
  ThemeData tData = ThemeData.light();

  Color primary = Colors.indigo.shade300;
  Color cardColor = Colors.grey.shade50;
  Color back = Colors.pink.shade50;
  Color tn = Colors.pink.shade100;

  ThemeData mData = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: primary,
    accentColor: Colors.purple,
    accentIconTheme: IconThemeData(color: Colors.white),
    cardColor: cardColor,
    backgroundColor: back,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(8.0),
      border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.elliptical(2.0, 2.0))),
    ),
    buttonColor: tn,
  );

  return mData;
}
