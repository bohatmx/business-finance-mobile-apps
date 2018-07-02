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

List<DropdownMenuItem<int>> _items = List();
var bold = TextStyle(fontWeight: FontWeight.bold);
List<DropdownMenuItem<int>> buildDaysDropDownItems() {
  var item1 = DropdownMenuItem<int>(
    value: 7,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.pink,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '7 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item1);
  var item2 = DropdownMenuItem<int>(
    value: 14,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.teal,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '14 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item2);

  var item3 = DropdownMenuItem<int>(
    value: 30,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.brown,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '30 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item3);
  var item4 = DropdownMenuItem<int>(
    value: 60,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.purple,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '60 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item4);
  var item5 = DropdownMenuItem<int>(
    value: 90,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.deepOrange,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '90 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item5);

  var item6 = DropdownMenuItem<int>(
    value: 120,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.blue,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '120 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item6);
  var item7 = DropdownMenuItem<int>(
    value: 365,
    child: Row(
      children: <Widget>[
        Icon(
          Icons.apps,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '365 Days Under Review',
            style: bold,
          ),
        ),
      ],
    ),
  );
  _items.add(item7);

  return _items;
}

String _toTwoDigitString(int value) {
  return value.toString().padLeft(2, '0');
}
