import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FCMessageListener {
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder);
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance);
  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance);
  onInvoiceBidMessage(InvoiceBid invoiceBid);
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement);
  onInvestorSettlement(InvestorInvoiceSettlement settlement);
  onCompanySettlement(CompanyInvoiceSettlement settlement);
}

configureAppMessaging(FCMessageListener listener) async {
  print(
      '\n\n################ configureAppMessaging starting ############## \n\n');
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      var messageType = message["messageType"];

      if (messageType == "PURCHASE_ORDER") {
        print(
            'configureMessaging: ############## receiving PURCHASE_ORDER message from FCM ....');
        Map map = json.decode(message["json"]);
        var po = new PurchaseOrder.fromJson(map);
        assert(po != null);
        print('configureMessaging .... about to tell listener about po');
        listener.onPurchaseOrderMessage(po);
      }

      if (messageType == "DELIVERY_ACCEPTANCE") {
        print(
            'configureMessaging: ############## receiving DELIVERY_ACCEPTANCE message from FCM');
        Map map = json.decode(message["json"]);
        var m = new DeliveryAcceptance.fromJson(map);
        assert(m != null);
        print('configureMessaging #### about to send acceptance via listener');
        listener.onDeliveryAcceptance(m);
      }
      //
      if (messageType == "INVOICE_ACCEPTANCE") {
        print(
            'configureMessaging: \n\n############## receiving INVOICE_ACCEPTANCE from FCM');
        try {
          Map map = json.decode(message["json"]);
          var m = new InvoiceAcceptance.fromJson(map);
          //assert(m != null);
          print(
              'configureMessaging -- about to tell listener about invoice ...');
          prettyPrint(map, 'received: ++++++++++++++++++++++++=');
          listener.onInvoiceAcceptance(m);
        } catch (e) {
          print('configureMessaging ERROR $e');
        }
      }
      //

      if (messageType == "INVOICE_BID") {
        print(
            'configureMessaging: ############## receiving INVOICE_BID message from FCM: $message');
        Map map = json.decode(message["json"]);
        prettyPrint(map, 'Invoice Bid received ........');
        var m = new InvoiceBid.fromJson(map);
        assert(m != null);

        listener.onInvoiceBidMessage(m);
      }
      if (messageType == "GOVT_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving GOVT_INVOICE_SETTLEMENT message from FCM');
        Map map = json.decode(message["json"]);
        var m = new GovtInvoiceSettlement.fromJson(map);
        assert(m != null);
        listener.onGovtInvoiceSettlement(m);
      }
      if (messageType == "INVESTOR_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving INVESTOR_INVOICE_SETTLEMENT message from FCM');
        Map map = json.decode(message["json"]);
        var m = new InvestorInvoiceSettlement.fromJson(map);
        assert(m != null);
        listener.onInvestorSettlement(m);
      }
      if (messageType == "COMPANY_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving COMPANY_INVOICE_SETTLEMENT message from FCM');
        Map map = json.decode(message["json"]);
        var m = new CompanyInvoiceSettlement.fromJson(map);
        assert(m != null);
        listener.onCompanySettlement(m);
      }
    },
    onLaunch: (Map<String, dynamic> message) {
      print('configureMessaging onLaunch *********** ');
      prettyPrint(message, 'message delivered on LAUNCH!');
    },
    onResume: (Map<String, dynamic> message) {
      print('configureMessaging onResume *********** ');
      prettyPrint(message, 'message delivered on RESUME!');
    },
  );

  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true));

  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {});

  _firebaseMessaging.getToken().then((String token) async {
    assert(token != null);
    var oldToken = await SharedPrefs.getFCMToken();
    if (token != oldToken) {
      await SharedPrefs.saveFCMToken(token);
      print('configureMessaging fcm token saved: $token');
      _updateToken(token);
    } else {
      print('configureMessaging: token has not changed. no need to save');
    }
  }).catchError((e) {
    print('configureMessaging ERROR fcmToken $e');
  });
}

_updateToken(String token) async {
  print('_updateToken #################  update user FCM token');
  Firestore _firestore = Firestore.instance;
  var user = await SharedPrefs.getUser();
  if (user == null) {
    print('_updateToken - user NULL, no need to update -----');
    return;
  }
  var qs = await _firestore
      .collection('users')
      .where('userId', isEqualTo: user.userId)
      .getDocuments();
  User mUser = User.fromJson(qs.documents.first.data);
  mUser.fcmToken = token;
  await _firestore
      .collection('users')
      .document(qs.documents.first.documentID)
      .updateData(mUser.toJson());
  SharedPrefs.saveUser(mUser);
}
