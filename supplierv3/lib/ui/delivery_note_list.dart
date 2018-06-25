import 'dart:convert';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class DeliveryNoteList extends StatefulWidget {
  final List<DeliveryNote> deliveryNotes;

  DeliveryNoteList(this.deliveryNotes);

  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements SnackBarListener, DeliveryNoteCardListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  List<DeliveryNote> deliveryNotes;
  DeliveryNote deliveryNote;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryNote;

  @override
  void initState() {
    super.initState();
    _configMessaging();
    if (widget.deliveryNotes == null) {
      _getDeliveryNotes();
    }
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
          var acceptance = new DeliveryNote.fromJson(map);
          assert(acceptance != null);
          deliveryNotes.insert(0, acceptance);
          PrettyPrint.prettyPrint(map, 'Dashboard._configMessaging: ');
          isDeliveryNote = true;
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

  _getDeliveryNotes() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading delivery notes',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    deliveryNotes = await ListAPI.getDeliveryNotes(
        deliveryNote.supplierDocumentRef, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  _confirm(DeliveryNote note) {
    print('_DeliveryNoteListState._confirm');
    PrettyPrint.prettyPrint(note.toJson(), '_DeliveryNoteListState._confirm');
  }

  int count;
  @override
  Widget build(BuildContext context) {
    deliveryNotes = widget.deliveryNotes;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    supplier == null ? 'No Supplier?' : supplier.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 20.0),
                    child: Text(
                      count == null ? '0' : '$count',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(80.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: deliveryNotes == null ? 0 : deliveryNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        _confirm(deliveryNotes.elementAt(index));
                      },
                      child: DeliveryNoteCard(
                        deliveryNote: deliveryNotes.elementAt(index),
                        listener: this,
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
    print('_DeliveryNoteListState.onActionPressed');
  }

  @override
  onNoteTapped(DeliveryNote note) {
    PrettyPrint.prettyPrint(
        note.toJson(), '_DeliveryNoteListState.onAcceptanceTapped');
  }
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteCardListener listener;

  DeliveryNoteCard({this.deliveryNote, this.listener});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Colors.teal.shade50,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.event,
                  color: Colors.deepOrange.shade100,
                ),
              ),
              Text(
                Helper.getFormattedDate(deliveryNote.date),
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  deliveryNote.customerName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'PO Number',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      deliveryNote.purchaseOrderNumber,
                      style: TextStyle(
                          color: Colors.pink.shade100,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class DeliveryNoteCardListener {
  onNoteTapped(DeliveryNote note);
}
