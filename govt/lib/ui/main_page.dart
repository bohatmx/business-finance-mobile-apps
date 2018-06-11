import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          elevation: 4.0,
          title: Text('Business Finance App'),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.info),
              onPressed: _infoPressed,
            ),
          ],
        ),
      ),
    );
  }

  void _infoPressed() {
    print('_MainPageState._infoPressed .............');
  }
}
