import 'dart:convert';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/util.dart';

class NewInvoicePage extends StatefulWidget {
  final DeliveryAcceptance deliveryAcceptance;

  NewInvoicePage(this.deliveryAcceptance);

  @override
  _NewInvoicePageState createState() => _NewInvoicePageState();
}

///
class _NewInvoicePageState extends State<NewInvoicePage>
    implements SnackBarListener {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  DeliveryAcceptance deliveryAcceptance;
  List<DeliveryAcceptance> deliveryAcceptances;
  User _user;
  String invoiceNumber, amount;
  Invoice invoice;
  Supplier supplier;

  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
    _configMessaging();
    _getDeliveryAcceptances();
  }

  _getDeliveryAcceptances() async {
    deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        supplier.documentReference, 'suppliers');
    print(
        '_NewInvoicePageState._getDeliveryAcceptances deliveryAcceptances: ${deliveryAcceptances.length}');
  }

  void _configMessaging() async {
    supplier = await SharedPrefs.getSupplier();
    print('Dashboard._configMessaging starting _firebaseMessaging config shit');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        var messageType = message["messageType"];
        if (messageType == "PURCHASE_ORDER") {
          print(
              'Dashboard._configMessaging: ############## receiving PURCHASE_ORDER message from FCM');
          Map map = json.decode(message["json"]);
          var po = new PurchaseOrder.fromJson(map);
          assert(po != null);
          prettyPrint(map, 'Dashboard._configMessaging: ');
          _scaffoldKey.currentState.hideCurrentSnackBar();
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Purchase Order received',
              textColor: Colors.white,
              backgroundColor: Colors.black,
              actionLabel: 'INVOICE',
              listener: this,
              icon: Icons.done);
        }
        if (messageType == "DELIVERY_ACCEPTANCE") {
          print(
              'Dashboard._configMessaging: ############## receiving DELIVERY_ACCEPTANCE message from FCM');
          Map map = json.decode(message["json"]);
          var acceptance = new DeliveryAcceptance.fromJson(map);
          assert(acceptance != null);
          prettyPrint(map, 'Dashboard._configMessaging: ');
          _scaffoldKey.currentState.hideCurrentSnackBar();
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Delivery Note accepted',
              textColor: Colors.white,
              backgroundColor: Colors.black,
              actionLabel: 'INVOICE',
              listener: this,
              icon: Icons.done);
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
        print('Dashboard._configMessaging fcm token saved: $token');
      } else {
        print(
            'Dashboard._configMessaging: token has not changed. no need to save');
      }
    }).catchError((e) {
      print('Dashboard._configMessaging ERROR fcmToken $e');
    });
  }

  _getCachedPrefs() async {
    _user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';
  void _onSavePressed() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      invoice = Invoice(
        invoiceNumber: invoiceNumber,
        user: NameSpace + 'User#' + _user.userId,
        govtEntity: deliveryAcceptance.govtEntity,
        company: deliveryAcceptance.company,
        supplier: deliveryAcceptance.supplier,
        govtDocumentRef: deliveryAcceptance.govtDocumentRef,
        companyDocumentRef: deliveryAcceptance.companyDocumentRef,
        supplierDocumentRef: deliveryAcceptance.supplierDocumentRef,
        purchaseOrder: deliveryAcceptance.purchaseOrder,
        deliveryNote: deliveryAcceptance.deliveryNote,
        supplierName: supplier.name,
        customerName: deliveryAcceptance.customerName,
        purchaseOrderNumber: deliveryAcceptance.purchaseOrderNumber,
        amount: amount,
        date: new DateTime.now().toIso8601String(),
      );

      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Submitting Invoice ...',
          textColor: Colors.white,
          backgroundColor: Colors.black);

      DataAPI api = DataAPI(Util.getURL());
      var result = await api.registerInvoice(invoice);
      if (result == '0') {
        isSuccess = false;
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice submission failed',
            listener: this,
            actionLabel: "ERROR ");
      } else {
        isSuccess = true;
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice submitted OK',
            textColor: Colors.white,
            icon: Icons.done,
            listener: this,
            actionLabel: 'DONE',
            backgroundColor: Colors.black);
      }
    }
  }

  bool isSuccess = false;
  @override
  Widget build(BuildContext context) {
    deliveryAcceptance = widget.deliveryAcceptance;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Invoice',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  deliveryAcceptance == null
                      ? 'Customer Name Here'
                      : deliveryAcceptance.customerName,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
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
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Invoice Details',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w900),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: _onSavePressed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextFormField(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Invoice Number',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the Invoice Number';
                        }
                      },
                      onSaved: (val) => invoiceNumber = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the invoice amount';
                        }
                      },
                      onSaved: (val) => amount = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 12.0,
                      left: 12.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('PO Number:')),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Text(
                            deliveryAcceptance == null
                                ? ''
                                : deliveryAcceptance.purchaseOrderNumber,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('Customer:')),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            deliveryAcceptance == null
                                ? ''
                                : deliveryAcceptance.customerName,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, top: 12.0),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('Supplier:')),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            supplier == null ? 'WhatTheFuck' : supplier.name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                        left: 28.0, right: 20.0, top: 30.0),
                    child: RaisedButton(
                      elevation: 8.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: _onSavePressed,
                      child: new Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit Invoice',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
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

  @override
  onActionPressed() {
    print('_NewInvoicePageState.onActionPressed');
    if (isSuccess) {
      Navigator.pop(context);
    }
  }
}

class InvoiceDetailsPage extends StatelessWidget {
  final Invoice invoice;

  InvoiceDetailsPage(this.invoice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: .0),
                  child: Text(
                    invoice.customerName,
                    style: getTitleTextWhite(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 48.0, top: 10.0, bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Invoice Number',
                        style: getTextWhiteSmall(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          invoice.invoiceNumber,
                          style: getTextWhiteMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(60.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: <Widget>[
              Text('More coming ....'),
            ],
          ),
        ),
      ),
    );
  }
}
