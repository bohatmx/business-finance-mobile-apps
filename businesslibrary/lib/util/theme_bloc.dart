import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';

class ThemeBloc {
  final StreamController<int> _themeController = StreamController<int>();
  final _rand = Random(DateTime.now().millisecondsSinceEpoch);
  get changeToTheme0 => _themeController.sink.add(0);
  get changeToTheme1 => _themeController.sink.add(1);
  get changeToTheme2 => _themeController.sink.add(2);

  changeToTheme(int index) {
    _themeController.sink.add(index);
  }
  changeToRandomTheme() {
    var index = _rand.nextInt(ThemeUtil.getThemeCount() - 1);
    _themeController.sink.add(index);
  }

  get newThemeStream => _themeController.stream;
}

final bloc = ThemeBloc();

class ThemeUtil {
  static List<ThemeData> _themes = List();

  static int index;
  static ThemeData getTheme({int themeIndex})  {
    if (_themes.isEmpty) {
      _setThemes();
    }
    if (themeIndex == null) {
      if (index == null) {
        index = 0;
      } else {
        index++;
        if (index == _themes.length) {
          index = 0;
        }
      }
    } else {
      index = themeIndex;
    }
    return _themes.elementAt(index);

  }

  static int getThemeCount() {
    _setThemes();
    return _themes.length;
  }
  static var _rand = Random(DateTime.now().millisecondsSinceEpoch);

  static ThemeData getRandomTheme() {
    var index = _rand.nextInt(_themes.length - 1);
    return _themes.elementAt(index);
  }
  static ThemeData getThemeByIndex(int index) {
    if (index >= _themes.length || index < 0) index = 0;
    return _themes.elementAt(index);
  }
  static void _setThemes() {
    _themes .clear();

    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.indigo.shade400,
      accentColor: Colors.pink,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.pink,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.indigo,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.teal,
      accentColor: Colors.purple,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.indigo,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.brown,
      accentColor: Colors.yellow.shade900,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.blue,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.lime.shade800,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.blue,
      accentColor: Colors.red,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.blue,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.blueGrey,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.purple,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.amber.shade700,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.deepOrange,
      accentColor: Colors.brown,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.deepOrange,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.orange,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      buttonColor: Colors.pink,
    ));
  }

}