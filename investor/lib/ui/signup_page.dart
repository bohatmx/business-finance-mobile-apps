import 'dart:convert';
import 'dart:math';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/dashboard.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> implements SnackBarListener {
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
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String participationId;

  Country country;
  @override
  initState() {
    super.initState();
    _debug();
    _configMessaging();
  }

  _debug() {
    if (isInDebugMode) {
      Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
      var num = rand.nextInt(100);
      name = 'Finance Investors$num LLC';
      adminEmail = 'admin$num@brokers.co.za';
      email = 'sales$num@brokers.co.za';
      firstName = 'Luke John$num';
      lastName = 'Cage$num';
      password = 'pass123';
      country = Country(name: 'South Africa', code: 'ZA');
    }
  }

  void _configMessaging() async {
    print(
        '_SignUpPageState._configMessaging starting _firebaseMessaging config shit');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var messageType = message["messageType"];
        if (messageType == "WALLET") {
          print(
              'Dashboard._configMessaging: ############## receiving WALLET message from FCM');
          Map map = json.decode(message["json"]);
          var wallet = new Wallet.fromJson(map);
          assert(wallet != null);
          prettyPrint(map, 'Dashboard._configMessaging: wallet:');
          await SharedPrefs.saveWallet(wallet);
        }
        if (messageType == "WALLET_ERROR") {
          print(
              'Dashboard._configMessaging: ############## receiving WALLET_ERROR message from FCM');
//          Map map = json.decode(message["json"]);
//          acceptance = new DeliveryAcceptance.fromJson(map);
//          assert(acceptance != null);
//          prettyPrint(map, 'Dashboard._configMessaging: ');
//          _scaffoldKey.currentState.hideCurrentSnackBar();
          AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Wallet creation failed',
            actionLabel: 'Error',
            listener: this,
          );
        }
      },
      onLaunch: (Map<String, dynamic> message) {},
      onResume: (Map<String, dynamic> message) {},
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      var oldToken = await SharedPrefs.getFCMToken();
      if (token != oldToken) {
        await SharedPrefs.saveFCMToken(token);
        //  TODO - update user's token on Firestore
        print('_SignUpPageState._configMessaging fcm token saved: $token');
      } else {
        print(
            '_SignUpPageState._configMessaging: token has not changed. no need to save');
      }
    }).catchError((e) {
      print('_SignUpPageState._configMessaging ERROR fcmToken $e');
    });
  }

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    setState(() {});
  }

  var style = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0);
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
              padding: const EdgeInsets.all(16.0),
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
                    style: style,
                    initialValue: name == null ? '' : name,
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
                    style: style,
                    initialValue: adminEmail == null ? '' : adminEmail,
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
                    style: style,
                    initialValue: firstName == null ? '' : firstName,
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
                    style: style,
                    initialValue: lastName == null ? '' : lastName,
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
                    style: style,
                    initialValue: adminEmail == null ? '' : adminEmail,
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
                    style: style,
                    initialValue: password == null ? '' : password,
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
                      new InkWell(
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

      Investor investor = Investor(
        name: name,
        email: email,
        country: country.name,
        dateRegistered: DateTime.now().toIso8601String(),
      );
      print('_SignUpPageState._onSavePressed ${investor.toJson()}');
      User admin = User(
        firstName: firstName,
        lastName: lastName,
        email: adminEmail,
        password: password,
      );
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      SignUp signUp = SignUp(getURL());
      var result = await signUp.signUpInvestor(investor, admin);

      switch (result) {
        case SignUp.Success:
          print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');
          AppSnackbar.showSnackbarWithAction(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Supplier Sign Up successful',
              textColor: Colors.white,
              backgroundColor: Colors.teal,
              actionLabel: 'Start',
              icon: Icons.lock_open);

          subscribe(investor);
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => new Dashboard()),
          );

          break;
        case SignUp.ErrorBlockchain:
          print('_SignUpPageState._onSavePressed  ErrorBlockchain');
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Blockchain failed to process Sign Up',
              actionLabel: "Support");
          break;
        case SignUp.ErrorMissingOrInvalidData:
          print('_SignUpPageState._onSavePressed  ErrorMissingOrInvalidData');
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Missing or Invalid data in the form',
              actionLabel: "Support");
          break;
        case SignUp.ErrorFirebaseUserExists:
          print('_SignUpPageState._onSavePressed  ErrorFirebaseUserExists');
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'This user already  exists',
              actionLabel: "Close");
          break;
        case SignUp.ErrorFireStore:
          print('_SignUpPageState._onSavePressed  ErrorFireStore');
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Database Error',
              actionLabel: "Support");
          break;
        case SignUp.ErrorCreatingFirebaseUser:
          print('_SignUpPageState._onSavePressed  ErrorCreatingFirebaseUser');
          AppSnackbar.showErrorSnackbar(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Database Error',
              actionLabel: "Support");
          break;
      }
    }
  }

  void subscribe(Investor investor) {
    var topic2 = 'general';
    _firebaseMessaging.subscribeToTopic(topic2);
    var topic3 = 'settlements' + investor.documentReference;
    _firebaseMessaging.subscribeToTopic(topic3);
    var topic4 = 'invoiceOffers';
    _firebaseMessaging.subscribeToTopic(topic4);

    print(
        '_SignInState._configMessaging ... ############# subscribed to FCM topics '
        ' \n $topic2 \n $topic3 \n $topic4 \n ');
  }

  @override
  onActionPressed(int action) {
    print('_SignUpPageState.onActionPressed .............. yay!');
  }
}
