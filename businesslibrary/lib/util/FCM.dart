import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCM {
  static final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  static const TOPIC_PURCHASE_ORDERS = 'purchaseOrders';
  static const TOPIC_DELIVERY_NOTES = 'deliveryNotes';
  static const TOPIC_DELIVERY_ACCEPTANCES = 'deliveryAcceptances';
  static const TOPIC_INVOICES = 'invoices';
  static const TOPIC_INVOICE_ACCEPTANCES = 'invoiceAcceptances';
  static const TOPIC_OFFERS = 'offers';
  static const TOPIC_AUTO_TRADES = 'autoTrades';
  static const TOPIC_GENERAL_MESSAGE = 'messages';
  static const TOPIC_INVOICE_BIDS = 'invoiceBids';
  static const TOPIC_SUPPLIERS = 'suppliers';
  static const TOPIC_CUSTOMERS = 'customers';
  static const TOPIC_INVESTORS = 'investors';

  static configureFCM({
    PurchaseOrderListener purchaseOrderListener,
    DeliveryNoteListener deliveryNoteListener,
    DeliveryAcceptanceListener deliveryAcceptanceListener,
    InvoiceListener invoiceListener,
    InvoiceAcceptanceListener invoiceAcceptanceListener,
    OfferListener offerListener,
    InvoiceBidListener invoiceBidListener,
    SupplierListener supplierListener,
    InvestorListener investorListener,
    CustomerListener customerListener,
    HeartbeatListener heartbeatListener,
  }) async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('\n\nRECEIVED FCM message, onMessage:\n$message \n');
        var data = message['data'];
        String messageType = data["messageType"];
        try {
          switch (messageType) {
            case 'PURCHASE_ORDER':
              var m = PurchaseOrder.fromJson(json.decode(data['json']));
              purchaseOrderListener.onPurchaseOrderMessage(m);
              break;
            case 'DELIVERY_NOTE':
              var m = DeliveryNote.fromJson(json.decode(data['json']));
              deliveryNoteListener.onDeliveryNoteMessage(m);
              break;
            case 'DELIVERY_ACCEPTANCE':
              var m = DeliveryAcceptance.fromJson(json.decode(data['json']));
              deliveryAcceptanceListener.onDeliveryAcceptanceMessage(m);
              break;
            case 'INVOICE':
              var m = Invoice.fromJson(json.decode(data['json']));
              invoiceListener.onInvoiceMessage(m);
              break;
            case 'INVOICE_ACCEPTANCE':
              var m = InvoiceAcceptance.fromJson(json.decode(data['json']));
              invoiceAcceptanceListener.onInvoiceAcceptanceMessage(m);
              break;
            case 'OFFER':
              var m = Offer.fromJson(json.decode(data['json']));
              offerListener.onOfferMessage(m);
              break;
            case 'INVOICE_BID':
              var m = InvoiceBid.fromJson(json.decode(data['json']));
              invoiceBidListener.onInvoiceBidMessage(m);
              break;
            case 'HEARTBEAT':
              Map map = json.decode(data['json']);
              heartbeatListener.onHeartbeat(map);
              break;
          }
        } catch (e) {
          print(e);
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

  static _updateToken(String token) async {
    print('_updateToken #################  update user FCM token');
    var user = await SharedPrefs.getUser();
    if (user == null) {
      print('_updateToken - user NULL, no need to update -----');
      return;
    }
    Firestore _firestore = Firestore.instance;
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
}

abstract class CustomerListener {
  onCustomerMessage(GovtEntity customer);
}

abstract class PurchaseOrderListener {
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder);
}

abstract class InvoiceBidListener {
  onInvoiceBidMessage(InvoiceBid invoiceBid);
}

abstract class DeliveryNoteListener {
  onDeliveryNoteMessage(DeliveryNote deliveryNote);
}

abstract class DeliveryAcceptanceListener {
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance);
}

abstract class InvoiceListener {
  onInvoiceMessage(Invoice invoice);
}

abstract class InvoiceAcceptanceListener {
  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance);
}

abstract class OfferListener {
  onOfferMessage(Offer offer);
}

abstract class SupplierListener {
  onSupplierMessage(Supplier supplier);
}

abstract class GovtEntityListener {
  onGovtEntityMessage(GovtEntity customer);
}

abstract class InvestorListener {
  onInvestorMessage(Investor investor);
}

abstract class HeartbeatListener {
  onHeartbeat(Map map);
}
