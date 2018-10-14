import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/dashboard.dart';

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

  String sectorType;
  bool busy = false;
  List<User> users;
  @override
  void initState() {
    super.initState();

    if (isInDebugMode) {
      _getUsers();
    }
    _checkSectors();
  }

  _getUsers() async {
    print('_SignInPageState._getUsers ..............');
    users = await ListAPI.getGovtUsers();
    _buildUserList();
    setState(() {});
  }

  List<DropdownMenuItem<User>> items = List();
  void _buildUserList() {
    print('_SignInPageState._buildUserList: ${users.length} ..............');
    users.forEach((user) {
      var item1 = new DropdownMenuItem(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('${user.firstName} ${user.lastName}'),
            ),
          ],
        ),
        value: user,
      );
      items.add(item1);
    });
    setState(() {});
  }

  User user;
  Widget _getPreferredSize() {
    return PreferredSize(
      preferredSize: new Size.fromHeight(100.0),
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 300.0,
                child: items.length == 0
                    ? Container()
                    : DropdownButton<User>(
                        items: items,
                        hint: Text(
                          'Select User',
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                        onChanged: (val) {
                          print(
                              '_SignInPageState._getDropdown ################# val: $val');
                          setState(() {
                            user = val;
                            adminEmail = user.email;
                            password = user.password;
                          });
                        },
                      ),
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
        title: Text('Customer Sign In'),
        bottom: isInDebugMode ? _getPreferredSize() : Container(),
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
    if (isInDebugMode) {
      if (user == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Please select user',
            listener: this,
            actionLabel: 'OK');
        busy = false;
        return;
      }
      if (password == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Please enter password',
            listener: this,
            actionLabel: 'Close');
        busy = false;
        return;
      }
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

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;
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
          //get wallet
          Wallet wallet = await ListAPI.getWallet(
              'govtEntity',
              'resource:com.oneconnect.biz.GovtEntity#' +
                  govtEntity.participantId);
          print(
              '_SignInPageState.checkResult ------- wallet recovered ${wallet.toJson()}');
          String msg;
          if (wallet != null) {
            msg = 'Wallet recovered';
          }
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new Dashboard(msg)),
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
  onActionPressed(int action) {
    print('_SignInPageState.onActionPressed ============= Yay!!');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }
}
