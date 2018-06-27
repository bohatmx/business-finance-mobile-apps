import 'dart:convert';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class DeliveryAcceptanceList extends StatefulWidget {
  @override
  _DeliveryAcceptanceListState createState() => _DeliveryAcceptanceListState();
}

class _DeliveryAcceptanceListState extends State<DeliveryAcceptanceList>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  List<DeliveryAcceptance> acceptances;
  DeliveryAcceptance deliveryAcceptance;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryAcceptance;

  DeliveryAcceptance acceptance;

  @override
  void initState() {
    super.initState();
    _configMessaging();
    _getAcceptances();
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
          prettyPrint(map, 'Dashboard._configMessaging: ');
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
          var acceptance = new DeliveryAcceptance.fromJson(map);
          assert(acceptance != null);
          acceptances.insert(0, acceptance);
          prettyPrint(map, 'Dashboard._configMessaging: ');
          isDeliveryAcceptance = true;
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

  _getAcceptances() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();

    setState(() {});
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading delivery note acceptances',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    print('_DeliveryAcceptanceListState._getAcceptances ... calling api');
    acceptances = await ListAPI.getDeliveryAcceptances(
        supplier.documentReference, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {});
    if (acceptances.isEmpty) {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'No delivery acceptances',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'Close',
          listener: this,
          icon: Icons.error);
    }
  }

  _confirm() {
    print('_DeliveryAcceptanceListState._confirm');
    prettyPrint(acceptance.toJson(), '_DeliveryAcceptanceListState._confirm');
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
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Delivery Acceptance: ${acceptance.customerName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                        'Do you want to create an Invoice based on this Delivery Acceptance?'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'NO',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    onPressed: _onInvoiceToCreate,
                    elevation: 4.0,
                    color: Colors.amber.shade300,
                    child: Text(
                      'Create Invoice',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ));
  }

  _onInvoiceToCreate() {
    print(
        '_DeliveryAcceptanceListState._onInvoiceToCreate ... go to NewInvoicePage');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new NewInvoicePage(acceptance)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Acceptances'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    supplier == null ? '' : supplier.name,
                    style: getTitleTextWhite(),
                  ),
                )
              ],
            ),
            preferredSize: Size.fromHeight(40.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: acceptances == null ? 0 : acceptances.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        acceptance = acceptances.elementAt(index);
                        _confirm();
                      },
                      child: DeliveryAcceptanceCard(
                        deliveryAcceptance: acceptances.elementAt(index),
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
  onActionPressed(int action) {
    print('_DeliveryAcceptanceListState.onActionPressed');
    Navigator.pop(context);
  }
}

class DeliveryAcceptanceCard extends StatelessWidget {
  final DeliveryAcceptance deliveryAcceptance;

  DeliveryAcceptanceCard({this.deliveryAcceptance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.event,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  getFormattedDate(deliveryAcceptance.date),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    deliveryAcceptance.customerName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
