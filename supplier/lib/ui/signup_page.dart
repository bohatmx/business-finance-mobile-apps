import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:supplier/ui/dashboard.dart';
import 'package:supplier/ui/selectors.dart';
import 'package:supplier/util.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var name,
      email,
      address,
      cellphone,
      firstName,
      lastName,
      adminEmail,
      password,
      adminCellphone,
      idNumber;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String participationId;

  PrivateSectorType sectorType;
  Country country;
  @override
  initState() {
    super.initState();
  }

  _getSector() async {
    sectorType = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SectorSelectorPage()),
    );
    setState(() {});
  }

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supplier SignUp'),
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
                  Text(
                    'Organisation Details',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w900),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Organisation Name',
                        hintText: 'Enter organisation name'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the name';
                      }
                    },
                    onSaved: (val) => name = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Organisation email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the email';
                      }
                    },
                    onSaved: (val) => email = val,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Text(
                      'Administrator Details',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your first name';
                      }
                    },
                    onSaved: (val) => firstName = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Surname',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your surname';
                      }
                    },
                    onSaved: (val) => lastName = val,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Administrator Email',
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
                  Column(
                    children: <Widget>[
                      new GestureDetector(
                        onTap: _getCountry,
                        child: Text(
                          'Get Country',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Text(
                        country == null ? '' : country.name,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w900),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: new GestureDetector(
                          onTap: _getSector,
                          child: Text(
                            'Get Sector',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      Text(
                        sectorType == null ? '' : sectorType.type,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w900),
                      ),
                    ],
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

      Supplier supplier = Supplier(
        name: name,
        email: email,
        country: country.name,
        privateSectorType: sectorType.type,
        dateRegistered: DateTime.now().toIso8601String(),
      );
      print('_SignUpPageState._onSavePressed ${supplier.toJson()}');
      User admin = User(
        firstName: firstName,
        lastName: lastName,
        email: adminEmail,
        password: password,
      );
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      SignUp signUp = SignUp(Util.getURL());
      var result = await signUp.signUpSupplier(supplier, admin);

      switch (result) {
        case SignUp.Success:
          print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');
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

          break;
        case SignUp.ErrorBlockchain:
          print('_SignUpPageState._onSavePressed  ErrorBlockchain');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Blockchain failed to process Sign Up',
              actionLabel: "Support");
          break;
        case SignUp.ErrorMissingOrInvalidData:
          print('_SignUpPageState._onSavePressed  ErrorMissingOrInvalidData');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Missing or Invalid data in the form',
              actionLabel: "Support");
          break;
        case SignUp.ErrorFirebaseUserExists:
          print('_SignUpPageState._onSavePressed  ErrorFirebaseUserExists');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'This user already  exists',
              actionLabel: "Close");
          break;
        case SignUp.ErrorFireStore:
          print('_SignUpPageState._onSavePressed  ErrorFireStore');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Database Error',
              actionLabel: "Support");
          break;
        case SignUp.ErrorCreatingFirebaseUser:
          print('_SignUpPageState._onSavePressed  ErrorCreatingFirebaseUser');
          AppSnackbar.showErrorSnackbar(
              context: context,
              scaffoldKey: _scaffoldKey,
              message: 'Database Error',
              actionLabel: "Support");
          break;
      }
    }
  }
}
