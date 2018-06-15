import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signin.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/dashboard.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var adminEmail, password, adminCellphone, idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Supplier supplier;
  GovtEntity govtEntity;
  Investor investor;
  ProcurementOffice office;
  Auditor auditor;
  Bank bank;

  String participationId;
  List<DropdownMenuItem> items = List();

  var sectorType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supplier Sign In'),
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
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      var result = await SignIn.signIn(adminEmail, password);

      switch (result) {
        case SignIn.Success:
          print('_SignInPageState._onSavePressed SUCCESS!!!!!!');

          supplier = await SharedPrefs.getSupplier();
          if (supplier == null) {
            AppSnackbar.showErrorSnackbar(
                context: context,
                scaffoldKey: _scaffoldKey,
                message: 'Unable to sign you in as a  Supplier',
                actionLabel: "close");
          } else {
            AppSnackbar.showSnackbarWithAction(
                context: context,
                scaffoldKey: _scaffoldKey,
                message: 'Supplier Sign Up successful',
                textColor: Colors.white,
                backgroundColor: Colors.teal,
                actionLabel: 'Start',
                icon: Icons.lock_open);
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new Dashboard()),
            );
          }
          break;
        case SignIn.ErrorDatabase:
          print('_SignInPageState._onSavePressed  ErrorDatabase');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Error  in Databbasep',
              actionLabel: "Support");
          break;
        case SignIn.ErrorNoOwningEntity:
          print('_SignInPageState._onSavePressed  ErrorNoOwningEntity');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Missing or Invalid data in the form',
              actionLabel: "Support");
          break;
        case SignIn.ErrorUserNotInDatabase:
          print('_SignInPageState._onSavePressed  ErrorUserNotInDatabase');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'User not found',
              actionLabel: "Close");
          break;
      }
    }
  }
}
