import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

///Utility class to provide snackbars
class AppSnackbar {
  static showSnackbar(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    if (scaffoldKey.currentState == null) {
      print('AppSnackbar.showSnackbar --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: textColor),
      ),
      duration: new Duration(seconds: 15),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackbarWithProgressIndicator(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    if (scaffoldKey.currentState == null) {
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            ),
          ),
          new Text(
            message,
            style: new TextStyle(color: textColor),
          ),
        ],
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackbarWithAction(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor,
      @required String actionLabel,
      @required SnackBarListener listener,
      @required IconData icon,
      @required int action}) {
    if (scaffoldKey.currentState == null) {
      print(
          'AppSnackbar.showSnackbarWithAction --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: Icon(icon),
            ),
          ),
          new Text(
            message,
            style: new TextStyle(color: textColor),
          ),
        ],
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          listener.onActionPressed(action);
        },
      ),
    ));
  }

  static showErrorSnackbar(
      {@required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required SnackBarListener listener,
      @required String actionLabel}) {
    if (scaffoldKey.currentState == null) {
      print('AppSnackbar.showErrorSnackbar --- currentState is NULL, quit ..');
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    var snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.white),
      ),
      duration: new Duration(seconds: 20),
      backgroundColor: Colors.red.shade900,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          listener.onActionPressed(Error);
        },
      ),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  static const Error = 0, Action = 1;
}

abstract class SnackBarListener {
  onActionPressed(int action);
}
