import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/misc_data.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:flutter/material.dart';
import 'package:govt/util.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
  List<DropdownMenuItem> items = List();

  var govtEntityType;
  @override
  Widget build(BuildContext context) {
    items = List();
    var item1 = DropdownMenuItem(
      value: GovtTypeUtil.National,
      child: Row(
        children: <Widget>[Icon(Icons.apps), Text('National')],
      ),
    );
    items.add(item1);
    var item2 = DropdownMenuItem(
      value: GovtTypeUtil.Provincial,
      child: Row(
        children: <Widget>[Icon(Icons.directions_car), Text('Provincial')],
      ),
    );
    items.add(item2);
    var item3 = DropdownMenuItem(
      value: GovtTypeUtil.Municipality,
      child: Row(
        children: <Widget>[Icon(Icons.directions_car), Text('Municipality')],
      ),
    );
    items.add(item3);

    return Scaffold(
      appBar: AppBar(
        title: Text('Government SignUp'),
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
                  new Row(
                    children: <Widget>[
                      DropdownButton(
                        items: items,
                        hint: Text(
                          'Select Category',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onChanged: (val) {
                          print('_SignUpPageState.build $val');

                          setState(() {
                            govtEntityType = val;
                          });
                        },
                      ),
                      Text(
                        govtEntityType == null ? '' : govtEntityType,
                      )
                    ],
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
    print('_SignUpPageState._onSavePressed');
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      print('GovtEntityForm._onSavePressed: will send submit now ....');

      GovtEntity govtEntity = GovtEntity(
        name: name,
        email: email,
        country: CountryUtil.SouthAfrica,
        govtEntityType: govtEntityType,
        dateRegistered: DateTime.now().toIso8601String(),
      );
      print('_SignUpPageState._onSavePressed ${govtEntity.toJson()}');
      User admin = User(
        firstName: firstName,
        lastName: lastName,
        email: adminEmail,
        password: password,
      );
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      SignUp signUp = SignUp(Util.getURL());
      var result = await signUp.signUpGovtEntity(govtEntity, admin);
      switch (result) {
        case SignUp.Success:
          print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');
          break;
        case SignUp.ErrorBlockchain:
          print('_SignUpPageState._onSavePressed  ErrorBlockchain');
          break;
        case SignUp.ErrorMissingOrInvalidData:
          print('_SignUpPageState._onSavePressed  ErrorMissingOrInvalidData');
          break;
        case SignUp.ErrorFirebaseUserExists:
          print('_SignUpPageState._onSavePressed  ErrorFirebaseUserExists');
          break;
        case SignUp.ErrorFireStore:
          print('_SignUpPageState._onSavePressed  ErrorFireStore');
          break;
        case SignUp.ErrorCreatingFirebaseUser:
          print('_SignUpPageState._onSavePressed  ErrorCreatingFirebaseUser');
          break;
      }
    }
  }
}
