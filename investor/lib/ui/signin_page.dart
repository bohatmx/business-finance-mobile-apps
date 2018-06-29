import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/dashboard.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var adminEmail, password, adminCellphone, idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  Investor investor;
  String participationId;
  List<DropdownMenuItem> items = List();
  @override
  initState() {
    super.initState();

    isDebug = isInDebugMode;
    if (isDebug) {
      _buildUserList();
    }
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

  void _onSavePressed() async {
    if (isInDebugMode) {
      if (adminEmail == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Select user',
            listener: this,
            actionLabel: 'Close');
        return;
      }
      password = 'pass123';
      await signIn();
    } else {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        await signIn();
      }
    }
  }

  Future signIn() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'BBFN is authenticating ....',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var result = await SignIn.signIn(adminEmail, password);
    await checkResult(result);
  }

  Future checkResult(int result) async {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    switch (result) {
      case SignIn.Success:
        print('_SignInPageState._onSavePressed ############## SUCCESS!!!!!!');
        investor = await SharedPrefs.getInvestor();
        if (investor == null) {
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Unable to sign you in as an Investor',
              actionLabel: "close");
        } else {
          subscribeToFCM();
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
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Error authenticating user. Try again',
            actionLabel: "Close");
        break;
    }
  }

  void subscribeToFCM() {
    var topic = 'invoiceOffers';
    _firebaseMessaging.subscribeToTopic(topic);
    var topic2 = 'general';
    _firebaseMessaging.subscribeToTopic(topic2);

    print(
        '_SignInState._configMessaging ... ############# subscribed to FCM topics '
        '\n $topic \n $topic2  \n');
  }

  @override
  onActionPressed(int action) {
    print('_SignInPageState.onActionPressed ,,,,,,,,,,,,  yay!');
  }

  bool isDebug;

  void _buildUserList() {
    var item1 = new DropdownMenuItem(
      child: Text('robert.vdm@fincap.com'),
      value: 'robert.vdm@fincap.com',
    );
    var item2 = new DropdownMenuItem(
      child: Text('rogers.m@invbrokers.co.za'),
      value: 'rogers.m@invbrokers.co.za',
    );

    items.add(item1);
    items.add(item2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Investor Sign In'),
        bottom: isInDebugMode ? _getPreferredSize() : Container(),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  new Padding(
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
                  new Padding(
                    padding: const EdgeInsets.only(
                        left: 28.0, right: 20.0, top: 30.0),
                    child: RaisedButton(
                      elevation: 8.0,
                      color: Theme.of(context).accentColor,
                      onPressed: _onSavePressed,
                      child: new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Submit SignUp',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
