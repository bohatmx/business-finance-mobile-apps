import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/dashboard.dart';
import 'package:supplierv3/util.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var adminEmail, password, adminCellphone, idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  Supplier supplier;
  GovtEntity govtEntity;
  Investor investor;
  ProcurementOffice office;
  Auditor auditor;
  Bank bank;

  String participationId;
  List<DropdownMenuItem> items = List();
  @override
  initState() {
    super.initState();

    isDebug = Util.isInDebugMode;
    if (isDebug) {
      _buildUserList();
    }
  }

  var sectorType;
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
        title: Text('Supplier Sign In'),
        bottom: Util.isInDebugMode ? _getPreferredSize() : Container(),
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
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit SignUp',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
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

  void _onSavePressed() async {
    if (Util.isInDebugMode) {
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
        supplier = await SharedPrefs.getSupplier();
        if (supplier == null) {
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Unable to sign you in as a  Supplier',
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
    var topic = 'purchaseOrders' + supplier.documentReference;
    _firebaseMessaging.subscribeToTopic(topic);
    var topic2 = 'general';
    _firebaseMessaging.subscribeToTopic(topic2);
    var topic3 = 'settlements' + supplier.documentReference;
    _firebaseMessaging.subscribeToTopic(topic3);
    var topic4 = 'invoiceBids' + supplier.documentReference;
    _firebaseMessaging.subscribeToTopic(topic4);
    var topic5 = 'deliveryAcceptances' + supplier.documentReference;
    _firebaseMessaging.subscribeToTopic(topic5);
    print(
        '_SignInState._configMessaging ... ############# subscribed to FCM topics '
        '\n $topic \n $topic2 \n $topic3 \n $topic4 \n  $topic5');
  }

  @override
  onActionPressed() {
    print('_SignInPageState.onActionPressed ,,,,,,,,,,,,  yay!');
  }

  bool isDebug;

  void _buildUserList() {
    var item1 = new DropdownMenuItem(
      child: Text('dmkhize@mkhize.com'),
      value: 'dmkhize@mkhize.com',
    );
    var item2 = new DropdownMenuItem(
      child: Text('ddlam@dlamini.com'),
      value: 'ddlam@dlamini.com',
    );
    var item3 = new DropdownMenuItem(
      child: Text('mosesd@femevent.com'),
      value: 'mosesd@femevent.com',
    );
    var item4 = new DropdownMenuItem(
      child: Text('dkhoza@femevent.com'),
      value: 'dkhoza@femevent.com',
    );
    var item5 = new DropdownMenuItem(
      child: Text('danielkk@engineers.com'),
      value: 'danielkk@engineers.com',
    );
    var item6 = new DropdownMenuItem(
      child: Text('petejohn@dhhtransport.com'),
      value: 'petejohn@dhhtransport.com',
    );
    var item7 = new DropdownMenuItem(
      child: Text('susanoak@zamatransport.com'),
      value: 'susanoak@zamatransport.com',
    );

    items.add(item1);
    items.add(item2);
    items.add(item3);
    items.add(item4);
    items.add(item5);
    items.add(item6);
    items.add(item7);
  }
}
