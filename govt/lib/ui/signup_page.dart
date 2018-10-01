import 'dart:async';
import 'dart:math';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/misc_data.dart';
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
import 'package:govt/ui/dashboard.dart';
import 'package:govt/ui/theme_util.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    implements SnackBarListener, FCMListener {
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
  bool autoAccept = false;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String participationId;
  List<DropdownMenuItem> items = List();
  Country country;
  var govtEntityType;

  @override
  initState() {
    super.initState();
    configureMessaging(this);
    _debug();
    _checkSectors();
  }

  _debug() {
    if (isInDebugMode) {
      Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
      var num = rand.nextInt(1000);
      name = '${entities.elementAt(rand.nextInt(entities.length - 1))}';
      adminEmail = 'admin$num@gov.co.za';
      email = 'info$num@gov.co.za';
      firstName =
          '${firstNames.elementAt(rand.nextInt(firstNames.length - 1))}';
      lastName = '${lastNames.elementAt(rand.nextInt(lastNames.length - 1))}';
      password = 'pass123';
      autoAccept = true;
      country = Country(name: 'South Africa', code: 'ZA');
    }
  }

  List<String> firstNames = ['Maria', 'Jonathan', 'David', 'Thabiso', 'Fikile'];
  List<String> lastNames = [
    'Nkosi',
    'Maluleke',
    'Hanyane',
    'Mokoena',
    'Chauke'
  ];
  List<String> entities = [
    'Dept of Public Works',
    'Dept of Health',
    'Dept of Transport',
    'Dept of Education',
    'Dept of Communications',
    'Dept of Finance',
    'Dept of Social Services',
  ];

  _getCountry() async {
    country = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CountrySelectorPage()),
    );
    setState(() {});
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      var api = DataAPI(getURL());
      api.addSectors();
    }
  }

  List<Sector> sectors;

  var style = TextStyle(
      fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
//    _debug();
    items = List();
    var item1 = DropdownMenuItem(
      value: GovtTypeUtil.National,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.indigo,
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('National'),
          )
        ],
      ),
    );
    items.add(item1);
    var item2 = DropdownMenuItem(
      value: GovtTypeUtil.Provincial,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.pink,
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Provincial'),
          )
        ],
      ),
    );
    items.add(item2);
    var item3 = DropdownMenuItem(
      value: GovtTypeUtil.Municipality,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.teal,
          ),
          new Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('Municipality'),
          )
        ],
      ),
    );
    items.add(item3);

    return Scaffold(
      key: _scaffoldKey,
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
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  new Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Organisation Details',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
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
                      new Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          govtEntityType == null ? '' : govtEntityType,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Switch(value: false, onChanged: _autoChanged),
                    ],
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: new Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Administrator Details',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900),
                      ),
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
                    initialValue: name == adminEmail ? '' : adminEmail,
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
                          style: TextStyle(color: Colors.blue, fontSize: 16.0),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          country == null ? '' : country.name,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w900),
                        ),
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
    print('_SignUpPageState._onSavePressed');
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (govtEntityType == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Please select Category',
            listener: this,
            actionLabel: 'Close');
        return;
      }
      print('GovtEntityForm._onSavePressed: will send submit now ....');

      GovtEntity govtEntity = GovtEntity(
        name: name,
        email: email,
        country: country.name,
        govtEntityType: govtEntityType,
        allowAutoAccept: autoAccept,
        dateRegistered: getUTCDate(),
      );
      print('_SignUpPageState._onSavePressed ${govtEntity.toJson()}');
      User admin = User(
        firstName: firstName,
        lastName: lastName,
        email: adminEmail,
        password: password,
      );
      print('_SignUpPageState._onSavePressed ${admin.toJson()}');
      AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Govt Entity Sign Up ... ',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black,
      );
      SignUp signUp = SignUp(getURL());
      var result = await signUp.signUpGovtEntity(govtEntity, admin);
      await checkResult(result);
    }
  }

  Future checkResult(int result) async {
    switch (result) {
      case SignUp.Success:
        print('_SignUpPageState._onSavePressed SUCCESS!!!!!!');
        await _subscribeToFCM();
        var wallet = await SharedPrefs.getWallet();
        if (wallet != null) {
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Sign up and wallet OK',
              textColor: Colors.white,
              backgroundColor: Colors.teal.shade800,
              actionLabel: 'DONE',
              listener: this,
              action: 0,
              icon: Icons.done_all);
        } else {
          //TODO - deal with error - wallet NOT on blockchain
          exit();
        }
        break;
      case SignUp.ErrorBlockchain:
        print('_SignUpPageState._onSavePressed  ErrorBlockchain');
        _showSignUpError('Blockchain error');
        break;
      case SignUp.ErrorMissingOrInvalidData:
        print('_SignUpPageState._onSavePressed  ErrorMissingOrInvalidData');
        _showSignUpError('Missing sign up data');
        break;
      case SignUp.ErrorFirebaseUserExists:
        print('_SignUpPageState._onSavePressed  ErrorFirebaseUserExists');
        _showSignUpError('User already exists');
        break;
      case SignUp.ErrorFireStore:
        print('_SignUpPageState._onSavePressed  ErrorFireStore');
        _showSignUpError('Database error');
        break;
      case SignUp.ErrorCreatingFirebaseUser:
        print('_SignUpPageState._onSavePressed  ErrorCreatingFirebaseUser');
        _showSignUpError('Authentication error');
        break;
    }
  }

  void _showSignUpError(String message) {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        listener: this,
        actionLabel: 'CLOSE');
  }

  void exit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }

  Future _subscribeToFCM() async {
    var govtEntity = await SharedPrefs.getGovEntity();
    var topic = 'invoices' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic);
    var topic2 = 'general';
    _firebaseMessaging.subscribeToTopic(topic2);
    var topic3 = 'settlements' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic3);
    var topic4 = 'deliveryNotes' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic4);

    print(
        '_StartPageState._configMessaging ... ############# subscribed to FCM topics '
        '\n $topic \n $topic2 \n $topic3 \n $topic4');
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
  onInvoiceMessage(Invoice invoice) {
    prettyPrint(invoice.toJson(), 'SignUp - onInvoiceMessage: ');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice arrived',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        action: InvoiceConstant,
        icon: Icons.done_all);
  }

  @override
  onOfferMessage(Offer offer) {}

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {}

  @override
  onWalletError() {}

  @override
  onWalletMessage(Wallet wallet) async {
    print('_SignUpPageState.onWalletMessage ++++++++++++++ wallet received');

    if (_scaffoldKey.currentState != null) {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Wallet created',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'OK',
          listener: this,
          action: WalletConstant,
          icon: Icons.done_all);
    } else {
      print(
          '_SignUpPageState.onWalletMessage _scaffoldKey.currentState = null');
    }
  }

  void _autoChanged(bool value) {
    autoAccept = value;
    setState(() {});
  }
}
