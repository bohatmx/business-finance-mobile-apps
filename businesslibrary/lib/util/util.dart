import 'package:flutter/material.dart';

const DEBUG_URL_HOME = 'http://192.168.86.238:3003/api/'; //FIBRE
const DEBUG_URL_ROUTER = 'http://192.168.8.237:3003/api/'; //ROUTER
const RELEASE_URL = 'http://192.168.86.238:3003/api/'; //CLOUD

String getURL() {
  var url;
  if (isInDebugMode) {
    url = DEBUG_URL_HOME; //switch  to DEBUG_URL_ROUTER before demo
  } else {
    url = RELEASE_URL;
  }
  return url;
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

TextStyle getTitleTextWhite() {
  return TextStyle(
    color: Colors.white,
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
  );
}

TextStyle getTextWhiteMedium() {
  return TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
}

TextStyle getTextWhiteSmall() {
  return TextStyle(
    color: Colors.white,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );
}

//String getFormattedDate(String date) {
//  DateTime d = DateTime.parse(date);
//  var format = new DateFormat.yMMMd();
//  return format.format(d);
//}
//
//String getFormattedLongDate(String date) {
//  DateTime d = DateTime.parse(date);
//  var format = new DateFormat.yMMMMEEEEd();
//  return format.format(d);
//}
//
//String getFormattedAmount(String amount) {
//  final oCcy = new NumberFormat("#,##0.00", "en_ZA");
//  double m = double.parse(amount);
//  return oCcy.format(m);
//}
