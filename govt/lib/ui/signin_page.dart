import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/dashboard.dart';
import 'package:govt/util.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var adminEmail, password, adminCellphone, idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  GovtEntity govtEntity;

  String participationId;
  List<DropdownMenuItem> items = List();

  String sectorType;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    _buildUserList();
  }

  void _buildUserList() {
    var item1 = new DropdownMenuItem(
      child: Text('thabo.nkosi@water.gov.za'),
      value: 'thabo.nkosi@water.gov.za',
    );
    var item2 = new DropdownMenuItem(
      child: Text('ntombi.m@publicworks.gov.za'),
      value: 'ntombi.m@publicworks.gov.za',
    );

    items.add(item1);
    items.add(item2);
  }

  Widget _getPreferredSize() {
    return PreferredSize(
      preferredSize: new Size.fromHeight(100.0),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              DropdownButton(
                items: items,
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.white),
                ),
                onChanged: (val) {
                  print(
                      '_SignInPageState._getDropdown ################# val: $val');
                  setState(() {
                    adminEmail = val;
                  });
                },
              ),
              new Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, bottom: 20.0, top: 20.0),
                child: Text(
                  adminEmail == null ? '' : adminEmail,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Government Sign In'),
        bottom: Util.isInDebugMode ? _getPreferredSize() : Container(),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 6.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Text(
                      'User Details',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'User Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your email address';
                      }
                    },
                    onSaved: (val) => adminEmail = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    maxLength: 20,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your password';
                      }
                    },
                    onSaved: (val) => password = val,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 28.0, right: 20.0, top: 30.0),
                    child: RaisedButton(
                      elevation: 8.0,
                      color: Theme.of(context).accentColor,
                      onPressed: _onSavePressed,
                      child: new Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() async {
    if (busy == true) {
      print('_SignInPageState._onSavePressed I am busy ... so piss off!');
      return;
    }

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'BFN authenticating ... wait',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    busy = true;
    if (Util.isInDebugMode) {
      if (adminEmail == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Please select user',
            listener: this,
            actionLabel: 'OK');
        busy = false;
        return;
      }
      password = 'pass123';
      var result = await SignIn.signIn(adminEmail, password);
      busy = false;
      await _checkResult(result);
    } else {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        var result = await SignIn.signIn(adminEmail, password);
        busy = false;
        await _checkResult(result);
      }
    }
  }

  Future _checkResult(int result) async {
    switch (result) {
      case SignIn.Success:
        print(
            '_SignInPageState._onSavePressed SUCCESS!!!!!! User has signed in  ############');

        govtEntity = await SharedPrefs.getGovEntity();
        if (govtEntity == null) {
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Unable to sign you in as a Government Entity',
              actionLabel: "close");
        } else {
          var govtEntity = await SharedPrefs.getGovEntity();

          var topic2 = 'general';
          _firebaseMessaging.subscribeToTopic(topic2);
          var topic3 = 'settlements' + govtEntity.documentReference;
          _firebaseMessaging.subscribeToTopic(topic3);
          var topic4 = 'deliveryNotes' + govtEntity.documentReference;
          _firebaseMessaging.subscribeToTopic(topic4);
          var topic0 = 'invoices' + govtEntity.documentReference;
          _firebaseMessaging.subscribeToTopic(topic0);
          print(
              '_SignInPageState._onSavePressed ... ############# subscribed to FCM topics '
              '\n $topic0 \n $topic2 \n $topic3 \n $topic4');
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new Dashboard()),
          );
        }
        break;
      case SignIn.ErrorDatabase:
        print('_SignInPageState._onSavePressed  ErrorDatabase');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Error  in Databbasep',
            actionLabel: "Support");
        break;
      case SignIn.ErrorNoOwningEntity:
        print('_SignInPageState._onSavePressed  ErrorNoOwningEntity');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Missing or Invalid data in the form',
            actionLabel: "Support");
        break;
      case SignIn.ErrorUserNotInDatabase:
        print('_SignInPageState._onSavePressed  ErrorUserNotInDatabase');
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'User not found',
            actionLabel: "Close");
        break;
      case SignIn.ErrorSignIn:
        print('_SignInPageState._onSavePressed  ErrorUserNotInDatabase');
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            listener: this,
            message: 'User authentication failed. Try again',
            actionLabel: "Close");
        break;
      default:
        print('_SignInPageState._onSavePressed  ErrorUserNotInDatabase');
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            listener: this,
            message: 'User authentication failed. Unknown error',
            actionLabel: "Close");
        break;
    }
  }

  @override
  onActionPressed() {
    print('_SignInPageState.onActionPressed ============= Yay!!');
  }
}
