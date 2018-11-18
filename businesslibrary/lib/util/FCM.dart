import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
  static const TOPIC_HEARTBEATS = 'heartbeats';
  static const TOPIC_SUPPLIERS = 'suppliers';
  static const TOPIC_CUSTOMERS = 'customers';
  static const TOPIC_INVESTORS = 'investors';
  static const TOPIC_PEACH_NOTIFY = "peachNotify";
  static const TOPIC_PEACH_ERROR = "peachError";
  static const TOPIC_PEACH_CANCEL = "peachCancel";
  static const TOPIC_PEACH_SUCCESS = "peachSuccess";
  static const TOPIC_INVESTOR_INVOICE_SETTLEMENTS =
      "investorInvoiceSettlements";

  static configureFCM(
      {BuildContext context,
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
      GeneralMessageListener generalMessageListener,
      InvestorInvoiceSettlementListener investorInvoiceSettlementListener,
      PeachCancelListener peachCancelListener,
      PeachErrorListener peachErrorListener,
      PeachSuccessListener peachSuccessListener,
      PeachNotifyListener peachNotifyListener}) async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');
/*
################ Message from FCM ================>>>> : 	{
I/flutter (  684): 	notification : {body: Invoice Bid from CashFlow Kings amount: 297321, title: Invoice Bid} ,
I/flutter (  684): 	data : {messageType: INVOICE_BID, json: {"invoiceBidId":"2c7520c0-ea35-11e8-b1bd-a5190111f651","amount":297321,"reservePercent":100,"autoTradeOrder":"resource:com.oneconnect.biz.AutoTradeOrder#38c0b3a0-bd30-11e8-a376-7950af1e4f7d","investor":"resource:com.oneconnect.biz.Investor#319dc450-bd30-11e8-e859-abf5c10894c0","offer":"resource:com.oneconnect.biz.Offer#684cc990-e440-11e8-f5ef-e125c834330a","investorName":"CashFlow Kings","wallet":"resource:com.oneconnect.biz.Wallet#GDDX6YCRMYWX6VYTND5KBGZM4VZRKAYBNEB2AGII6IQUKFQYQA44TS6S","date":"2018-11-17T06:51:13.484Z","isSettled":false,"supplier":"resource:com.oneconnect.biz.Supplier#e0860820-bd30-11e8-d59e-91e011144075","discountPercent":7,"startTime":"2018-11-17T06:51:13.484Z","endTime":"2018-11-17T06:51:13.484Z"}} ,
I/flutter (  684):
I/flutter (  684): }
 */
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n################ Message from FCM ================>>>> :');

        bool ios = Theme.of(context).platform == TargetPlatform.iOS;
        String messageType = 'unknown';
        String mJSON;
        if (ios) {
          messageType = map["messageType"];
          mJSON = map['json'];
          print('FCM.configureFCM platform is iOS');
        } else {
          var data = map['data'];
          messageType = data["messageType"];
          mJSON = data["json"];
          print('FCM.configureFCM platform is Android');
        }

        print(
            'FCM.configureFCM ************************** messageType: $messageType');
        try {
          switch (messageType) {
            case 'PURCHASE_ORDER':
              var m = PurchaseOrder.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM PURCHASE_ORDER MESSAGE :');
              purchaseOrderListener.onPurchaseOrderMessage(m);
              break;
            case 'DELIVERY_NOTE':
              var m = DeliveryNote.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM DELIVERY_NOTE MESSAGE :');
              deliveryNoteListener.onDeliveryNoteMessage(m);
              break;
            case 'DELIVERY_ACCEPTANCE':
              var m = DeliveryAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(),
                  '\n\n########## FCM DELIVERY_ACCEPTANCE MESSAGE :');
              deliveryAcceptanceListener.onDeliveryAcceptanceMessage(m);
              break;
            case 'INVOICE':
              var m = Invoice.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM MINVOICE ESSAGE :');
              invoiceListener.onInvoiceMessage(m);
              break;
            case 'INVOICE_ACCEPTANCE':
              var m = InvoiceAcceptance.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), ' FCM INVOICE_ACCEPTANCE MESSAGE :');
              invoiceAcceptanceListener.onInvoiceAcceptanceMessage(m);
              break;
            case 'OFFER':
              var m = Offer.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM OFFER MESSAGE :');
              offerListener.onOfferMessage(m);
              break;
            case 'INVOICE_BID':
              var m = InvoiceBid.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM INVOICE_BID MESSAGE :');
              invoiceBidListener.onInvoiceBidMessage(m);
              break;
            case 'HEARTBEAT':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM HEARTBEAT MESSAGE :');
              heartbeatListener.onHeartbeat(map);
              break;
            case 'PEACH_NOTIFY':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM PEACH_NOTIFY :');
              peachNotifyListener
                  .onPeachNotify(PeachNotification.fromJson(map));
              break;
            case 'PEACH_SUCCESS':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM PEACH_SUCCESS :');
              peachSuccessListener.onPeachSuccess(map);
              break;
            case 'PEACH_CANCEL':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM PEACH_CANCEL :');
              peachCancelListener.onPeachCancel(map);
              break;
            case 'PEACH_ERROR':
              Map map = json.decode(mJSON);
              prettyPrint(map, '\n\n########## FCM PEACH_ERROR :');
              peachErrorListener.onPeachError(PeachNotification.fromJson(map));
              break;
            case 'INVESTOR_INVOICE_SETTLEMENT':
              Map map = json.decode(mJSON);
              prettyPrint(
                  map, '\n\n########## FCM INVESTOR_INVOICE_SETTLEMENT :');
              investorInvoiceSettlementListener.onInvestorInvoiceSettlement(
                  InvestorInvoiceSettlement.fromJson(map));
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
        print('\nFCM: access token has not changed. no need to save. duh!');
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
//    Firestore _firestore = Firestore.instance;
//    var qs = await _firestore
//        .collection('users')
//        .where('userId', isEqualTo: user.userId)
//        .getDocuments();
//    User mUser = User.fromJson(qs.documents.first.data);
//    mUser.fcmToken = token;
//    await _firestore
//        .collection('users')
//        .document(qs.documents.first.documentID)
//        .updateData(mUser.toJson());
//    SharedPrefs.saveUser(mUser);
  }
}

abstract class InvestorInvoiceSettlementListener {
  onInvestorInvoiceSettlement(InvestorInvoiceSettlement settlement);
}

abstract class PeachSuccessListener {
  onPeachSuccess(Map map);
}

abstract class PeachErrorListener {
  onPeachError(PeachNotification notification);
}

abstract class PeachCancelListener {
  onPeachCancel(Map map);
}

abstract class PeachNotifyListener {
  onPeachNotify(PeachNotification notification);
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

abstract class GeneralMessageListener {
  onGeneralMessage(Map map);
}
