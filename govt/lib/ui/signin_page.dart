import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _firestore = Firestore.instance;
  GovtEntity govtEntity;

  String participationId;
  List<DropdownMenuItem> items = List();

  String sectorType;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    // _test();
  }

  //thabo.nkosi@water.gov.za
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Government Sign In'),
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
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'BFN authenticating ... wait',
          textColor: Colors.white,
          backgroundColor: Colors.black);
      busy = true;
      var result = await SignIn.signIn(adminEmail, password);
      busy = false;
      _scaffoldKey.currentState.hideCurrentSnackBar();
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
  }

  @override
  onActionPressed() {
    print('_SignInPageState.onActionPressed ============= Yay!!');
  }
}
