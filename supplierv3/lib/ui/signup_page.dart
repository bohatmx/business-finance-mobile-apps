import 'dart:math';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/dashboard.dart';

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

  Sector sector;
  Country country;
  TextEditingController ctrlName = TextEditingController();

  @override
  initState() {
    super.initState();
    _debug();
  }

  _debug() async {
    if (isInDebugMode) {
      Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
      var num = rand.nextInt(1000);
      name = 'Logistic Services $num';
      adminEmail = 'admin$num@supplier$num.co.za';
      email = 'sales$num@supplier$num.co.za';
      firstName = 'William $num';
      lastName = 'Johnson';
      password = 'pass123';
      country = Country(name: 'South Africa', code: 'ZA');

      setState(() {});
    }
  }

  _getSector() async {
    sector = await Navigator.push(
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

  List<Sector> sectors;

  var style = TextStyle(
      color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold);

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
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    initialValue: name == null ? '' : name,
                    style: style,
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
                    initialValue: email == null ? '' : email,
                    style: style,
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
                    initialValue: firstName == null ? '' : firstName,
                    style: style,
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
                    initialValue: lastName == null ? '' : lastName,
                    style: style,
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
                    initialValue: adminEmail == null ? '' : adminEmail,
                    style: style,
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
                    initialValue: password == null ? '' : password,
                    style: style,
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
                            fontSize: 24.0, fontWeight: FontWeight.w900),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: new GestureDetector(
                          onTap: _getSector,
                          child: Text(
                            'Get Sector',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      Text(
                        sector == null ? '' : sector.sectorName,
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
        sector: 'resource:com.oneconnect.biz.Sector#${sector.sectorId}',
        sectorName: sector.sectorName,
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
      AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Supplier Sign Up ... ',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black,
      );
      SignUp signUp = SignUp(getURL());
      var result = await signUp.signUpSupplier(supplier, admin);
      checkResult(result, supplier);
    }
  }

  void checkResult(int result, Supplier supplier) async {
    switch (result) {
      case SignUp.Success:
        print('_SignUpPageState.checkResult SUCCESS!!!!!!');
        var wallet = await SharedPrefs.getWallet();
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

          _subscribe(supplier);
        } else {
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

  void exit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }

  void _subscribe(Supplier supplier) {
    _firebaseMessaging
        .subscribeToTopic('purchaseOrders' + supplier.documentReference);
    _firebaseMessaging.subscribeToTopic('general');
    _firebaseMessaging
        .subscribeToTopic('settlements' + supplier.documentReference);
    _firebaseMessaging
        .subscribeToTopic('invoiceBids' + supplier.documentReference);
    _firebaseMessaging
        .subscribeToTopic('deliveryAcceptances' + supplier.documentReference);
    print('_SignUpPageState._subscribe to 5 topics');
  }

  @override
  onActionPressed(int action) {
    exit();
  }

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {
    // TODO: implement onCompanySettlement
  }

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {
    // TODO: implement onDeliveryAcceptance
  }

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {
    // TODO: implement onDeliveryNote
  }

  @override
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement) {
    // TODO: implement onGovtInvoiceSettlement
  }

  @override
  onInvestorSettlement(InvestorInvoiceSettlement settlement) {
    // TODO: implement onInvestorSettlement
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    // TODO: implement onInvoiceBidMessage
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    // TODO: implement onInvoiceMessage
  }

  @override
  onOfferMessage(Offer offer) {
    // TODO: implement onOfferMessage
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    // TODO: implement onPurchaseOrderMessage
  }

  @override
  onWalletError() {
    // TODO: implement onWalletError
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
