import 'dart:math';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
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

class _SignUpPageState extends State<SignUpPage>
    implements SnackBarListener, FCMListener {
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
    configureMessaging(this);
    _checkSectors();
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

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    print(
        '_SignUpPageState._getCountry - back from selection: ${country.name}');
    setState(() {});
  }

  var style = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Investor SignUp'),
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
                      onPressed: _onSubmit,
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

  void _onSubmit() async {
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
      AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Investor Sign Up ... ',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black,
      );

      SignUp signUp = SignUp(getURL());
      var result = await signUp.signUpInvestor(investor, admin);

      checkResult(result, investor);
    }
  }

  void checkResult(int result, Investor investor) {
    switch (result) {
      case SignUp.Success:
        print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');

        var wallet = SharedPrefs.getWallet();
        if (wallet != null) {
          AppSnackbar.showSnackbarWithAction(
              listener: this,
              scaffoldKey: _scaffoldKey,
              message: 'Sign Up and Wallet OK',
              textColor: Colors.white,
              backgroundColor: Colors.teal,
              actionLabel: 'Start',
              action: 0,
              icon: Icons.done_all);

          subscribe(investor);
        } else {
          //TODO - wallet not on blockchain.
          exit();
        }

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

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      var api = DataAPI(getURL());
      api.addSectors();
    }
  }

  List<Sector> sectors;

  void exit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
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
    exit();
  }

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {}

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {}

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {}

  @override
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement) {}

  @override
  onInvestorSettlement(InvestorInvoiceSettlement settlement) {}

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {}

  @override
  onInvoiceMessage(Invoice invoice) {}

  @override
  onOfferMessage(Offer offer) {}

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {}

  @override
  onWalletError() {
    print('_SignUpPageState.onWalletError ......');
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Wallet creation failed',
        listener: this,
        actionLabel: 'CLOSE');
  }

  @override
  onWalletMessage(Wallet wallet) async {
    prettyPrint(
        wallet.toJson(), 'SignUpPage +++++++++++ onWalletMessage ......');

    if (_scaffoldKey.currentState != null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Wallet created',
          textColor: Colors.white,
          backgroundColor: Colors.teal);
    } else {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Dashboard('Wallet created')),
      );
    }
  }
}
