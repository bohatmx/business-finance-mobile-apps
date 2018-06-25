import 'dart:convert';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/make_offer.dart';

class InvoiceList extends StatefulWidget {
  final List<Invoice> invoices;

  InvoiceList(this.invoices);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static const MakeOffer = '1', CancelOffer = '2', EditInvoice = '3';
  List<Invoice> invoices;
  Invoice invoice;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isInvoice;
  List<DropdownMenuItem<String>> items = List();

  @override
  void initState() {
    super.initState();
    _configMessaging();

    _getCached();
    if (widget.invoices == null) {
      _getInvoices();
    }
  }

  _showMenuDialog(Invoice invoice) {
    this.invoice = invoice;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Actions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 240.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Invoice Number: ${invoice.invoiceNumber}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildItems(),
                  ],
                ),
              ),
            ));
  }

  Widget _buildItems() {
    var item1 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.attach_money,
                color: Colors.green.shade800,
              ),
            ),
            Text('Make Invoice Offer'),
          ],
        ),
      ),
    );
    var item2 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _cancelOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.cancel,
                color: Colors.red.shade800,
              ),
            ),
            Text('Cancel Invoice Offer'),
          ],
        ),
      ),
    );
    var item3 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _confirm,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.description,
                color: Colors.blue.shade800,
              ),
            ),
            Text('View Invoice Details'),
          ],
        ),
      ),
    );

    return Column(
      children: <Widget>[
        item1,
        item2,
        item3,
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          ),
        ),
      ],
    );
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
          var purchaseOrder = new PurchaseOrder.fromJson(map);
          assert(purchaseOrder != null);
          PrettyPrint.prettyPrint(map, 'Dashboard._configMessaging: ');
          isPurchaseOrder = true;
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
          var acceptance = new Invoice.fromJson(map);
          assert(acceptance != null);
          invoices.insert(0, acceptance);
          PrettyPrint.prettyPrint(map, 'Dashboard._configMessaging: ');
          isInvoice = true;
          _scaffoldKey.currentState.hideCurrentSnackBar();
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Delivery Note accepted',
              textColor: Colors.white,
              backgroundColor: Colors.black,
              actionLabel: 'Close',
              listener: this,
              icon: Icons.done);
          setState(() {});
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

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    setState(() {});
  }

  _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoices ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    invoices =
        await ListAPI.getInvoices(invoice.supplierDocumentRef, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _calculateTotal();
  }

  void _calculateTotal() {
    if (invoices.isNotEmpty) {
      double total = 0.00;
      invoices.forEach((inv) {
        double amt = double.parse(inv.amount);
        total += amt;
      });

      totalAmount = Helper.getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  void _confirm() {
    print('_InvoiceListState._confirm');
    PrettyPrint.prettyPrint(invoice.toJson(), '_InvoiceListState._confirm');
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Handling",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Invoice Number: ${invoice.invoiceNumber}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Do you want  to offer this invoice to the Business Finance Network?",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onOffer,
                  child: Text(
                    'YES',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _onCancel,
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.pink, fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ));
  }

  String totalAmount;
  @override
  Widget build(BuildContext context) {
    invoices = widget.invoices;
    if (invoices == null) {
      _getInvoices();
    } else {
      _calculateTotal();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    supplier == null ? 'Blank Supplier?' : supplier.name,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 20.0, top: 10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          totalAmount == null ? '0.00' : totalAmount,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(110.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: invoices == null ? 0 : invoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        _showMenuDialog(invoices.elementAt(index));
                      },
                      child: InvoiceCard(
                        invoice: invoices.elementAt(index),
                        context: context,
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  onActionPressed() {
    print('_InvoiceListState.onActionPressed');
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';
  void _onOffer() {
    print('_InvoiceListState._onOffer');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
    );
  }

  void _onCancel() {
    print('_InvoiceListState._onCancel');
    Navigator.pop(context);
  }

  void _cancelOffer() {
    print('_InvoiceListState._cancelOffer ..........');
  }

  void _viewInvoice() {
    print('_InvoiceListState._viewInvoice ............');
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  InvoiceCard({this.invoice, this.context});

  @override
  Widget build(BuildContext context) {
    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 2.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  Helper.getFormattedLongestDate(invoice.date),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      invoice.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 10.0, top: 10.0),
              child: Row(
                children: <Widget>[
                  Text('Amount'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      amount == null ? '0.00' : amount,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String amount;
  String _getFormattedAmt() {
    amount = Helper.getFormattedAmount(invoice.amount, context);
    print('InvoiceCard._getFormattedAmt $amount');
    return amount;
  }
}
