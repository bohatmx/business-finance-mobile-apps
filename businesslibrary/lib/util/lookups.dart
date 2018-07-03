import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/comms.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class Lookups {
  static Firestore _firestore = Firestore.instance;

  static Future<List<PrivateSectorType>> getTypes() async {
    List<PrivateSectorType> list = List();

    var qs = await _firestore
        .collection('privateSectorTypes')
        .orderBy('type')
        .getDocuments()
        .catchError((e) {
      return list;
    });
    qs.documents.forEach((doc) {
      var type = new PrivateSectorType.fromJson(doc.data);
      list.add(type);
    });

    return list;
  }

  static Future<List<Country>> getCountries() async {
    print('Lookups.getCountries ................................');
    List<Country> list = List();

    var qs =
        await _firestore.collection('countries').getDocuments().catchError((e) {
      print('Lookups.getCountries ERROR $e');
      return list;
    });
    qs.documents.forEach((doc) {
      var country = new Country.fromJson(doc.data);
      list.add(country);
    });

    print('Lookups.getCountries ########## found ${list.length}');
    return list;
  }

  static Future<int> storeCountries() async {
    var t1 = new Country(name: 'South Africa', code: 'ZA');
    await _firestore.collection('countries').add(t1.toJson()).catchError((e) {
      return 1;
    });
    var t2 = new Country(name: 'Zimbabbwe', code: 'ZA');
    await _firestore.collection('countries').add(t2.toJson()).catchError((e) {
      return 1;
    });
    var t3 = new Country(name: 'Lesotho', code: 'ZA');
    await _firestore.collection('countries').add(t3.toJson()).catchError((e) {
      return 1;
    });
    var t4 = new Country(name: 'Mozambique', code: 'ZA');
    await _firestore.collection('countries').add(t4.toJson()).catchError((e) {
      return 1;
    });
    var t5 = new Country(name: 'Namibia', code: 'ZA');
    await _firestore.collection('countries').add(t5.toJson()).catchError((e) {
      return 1;
    });
    var t6 = new Country(name: 'Kenya', code: 'ZA');
    await _firestore.collection('countries').add(t6.toJson()).catchError((e) {
      return 1;
    });
    var t7 = new Country(name: 'Botswana', code: 'ZA');
    await _firestore.collection('countries').add(t7.toJson()).catchError((e) {
      return 1;
    });
    var t8 = new Country(name: 'Swaziland', code: 'ZA');
    await _firestore.collection('countries').add(t8.toJson()).catchError((e) {
      return 1;
    });
    var t9 = new Country(name: 'Uganda', code: 'ZA');
    await _firestore.collection('countries').add(t9.toJson()).catchError((e) {
      return 1;
    });
    var t10 = new Country(name: 'Tanzania', code: 'ZA');
    await _firestore.collection('countries').add(t10.toJson()).catchError((e) {
      return 1;
    });
    var t11 = new Country(name: 'Zambia', code: 'ZA');
    await _firestore.collection('countries').add(t11.toJson()).catchError((e) {
      return 1;
    });
    var t12 = new Country(name: 'Malawi', code: 'ZA');
    await _firestore.collection('countries').add(t12.toJson()).catchError((e) {
      return 1;
    });
    return 0;
  }

  static Future<int> storePrivateSectorTypes() async {
    var t1 = new PrivateSectorType(type: 'Retail');
    await _firestore
        .collection('privateSectorTypes')
        .add(t1.toJson())
        .catchError((e) {
      return 1;
    });
    var t2 = new PrivateSectorType(type: 'Financial Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t2.toJson())
        .catchError((e) {
      return 1;
    });
    var t3 = new PrivateSectorType(type: 'Education & Training');
    await _firestore
        .collection('privateSectorTypes')
        .add(t3.toJson())
        .catchError((e) {
      return 1;
    });
    var t4 = new PrivateSectorType(type: 'Agriculture');
    await _firestore
        .collection('privateSectorTypes')
        .add(t4.toJson())
        .catchError((e) {
      return 1;
    });
    var t5 = new PrivateSectorType(type: 'Professional Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t5.toJson())
        .catchError((e) {
      return 1;
    });
    var t6 = new PrivateSectorType(type: 'Industrial');
    await _firestore
        .collection('privateSectorTypes')
        .add(t6.toJson())
        .catchError((e) {
      return 1;
    });
    var t7 = new PrivateSectorType(type: 'Health');
    await _firestore
        .collection('privateSectorTypes')
        .add(t7.toJson())
        .catchError((e) {
      return 1;
    });
    var t8 = new PrivateSectorType(type: 'Transportation');
    await _firestore
        .collection('privateSectorTypes')
        .add(t8.toJson())
        .catchError((e) {
      return 1;
    });
    var t9 = new PrivateSectorType(type: 'Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t9.toJson())
        .catchError((e) {
      return 1;
    });
    var t10 = new PrivateSectorType(type: 'Infrastructure');
    await _firestore
        .collection('privateSectorTypes')
        .add(t10.toJson())
        .catchError((e) {
      return 1;
    });
    var t11 = new PrivateSectorType(type: 'Event Management');
    await _firestore
        .collection('privateSectorTypes')
        .add(t11.toJson())
        .catchError((e) {
      return 1;
    });
    var t12 = new PrivateSectorType(type: 'Catering');
    await _firestore
        .collection('privateSectorTypes')
        .add(t12.toJson())
        .catchError((e) {
      return 1;
    });
    var t13 = new PrivateSectorType(type: 'Electrical Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t13.toJson())
        .catchError((e) {
      return 1;
    });
    var t14 = new PrivateSectorType(type: 'Construction');
    await _firestore
        .collection('privateSectorTypes')
        .add(t14.toJson())
        .catchError((e) {
      return 1;
    });
    var t15 = new PrivateSectorType(type: 'Information & Technology');
    await _firestore
        .collection('privateSectorTypes')
        .add(t15.toJson())
        .catchError((e) {
      return 1;
    });
    var t16 = new PrivateSectorType(type: 'Engineering');
    await _firestore
        .collection('privateSectorTypes')
        .add(t16.toJson())
        .catchError((e) {
      return 1;
    });
    var t17 = new PrivateSectorType(type: 'Manufacturing');
    await _firestore
        .collection('privateSectorTypes')
        .add(t17.toJson())
        .catchError((e) {
      return 1;
    });
    var t18 = new PrivateSectorType(type: 'Social Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t18.toJson())
        .catchError((e) {
      return 1;
    });

    return 0;
  }
}

class PrivateSectorType {
  String type;

  PrivateSectorType({@required this.type});
  PrivateSectorType.fromJson(Map data) {
    this.type = data['type'];
  }
  Map<String, String> toJson() => <String, String>{
        'type': type,
      };
}

class Country {
  String name, code;

  Country({this.name, this.code});
  Country.fromJson(Map data) {
    this.name = data['name'];
    this.code = data['code'];
  }
  Map<String, String> toJson() => <String, String>{
        'name': name,
        'code': code,
      };
}

String getFormattedDateMedium(String date, BuildContext context) {
  var cc = MaterialLocalizations.of(context);
  return cc.formatMediumDate(DateTime.parse(date));
}

String getFormattedDateLong(String date, BuildContext context) {
  var cc = MaterialLocalizations.of(context);
  return cc.formatFullDate(DateTime.parse(date));
}

String getFormattedDate(String date) {
  DateTime d = DateTime.parse(date);
  var format = new DateFormat.yMMMd();
  return format.format(d);
}

String getFormattedLongestDate(String date) {
  DateTime d = DateTime.parse(date);
  var format = new DateFormat.yMMMMEEEEd();
  return format.format(d);
}

String getFormattedAmount(String amount, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = myLocale.languageCode + '_' + myLocale.countryCode;
  //print('getFormattedAmount ----------- locale is  $val');
  final oCcy = new NumberFormat("#,##0.00", val);
  double m = double.parse(amount);

  return oCcy.format(m);
}

prettyPrint(Map map, String name) {
  print('\n\n$name \t{\n');
  map.forEach((key, val) {
    print('\t$key : $val ,\n');
  });
  print('\n}\n\n');
}

configureMessaging(FCMListener listener) async {
  print('configureMessaging starting _firebaseMessaging config shit');
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      var messageType = message["messageType"];
      if (messageType == "WALLET") {
        print(
            'configureMessaging: \n\n############## receiving WALLET message from FCM:\n ${message["json"]}\n\n');
        Map map = json.decode(message["json"]);
        var wallet = new Wallet.fromJson(map);
        if (wallet != null) {
          prettyPrint(map, 'configureMessaging: --------> wallet received:');
          wallet.sourceSeed = null;
          var dec =
              await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
          wallet.secret = dec;
          await SharedPrefs.saveWallet(wallet);
          //get acct from stellar and save in sharedPrefs
          DataAPI api = DataAPI(getURL());
          wallet.secret = null;
          var key = await api.addWallet(wallet);
          if (key == '0') {
            print('configureMessaging ERROR blockchain wallet write failed');
            listener.onWalletError();
            return;
          }
          var acct = await StellarCommsUtil.getAccount(wallet.stellarPublicKey);
          await SharedPrefs.saveAccount(acct);
          print('configureMessaging -- about to send wallet via listener');
          listener.onWalletMessage(wallet);
        } else {
          print('configureMessaging: ERROR ERROR wallet from FCM is null');
          listener.onWalletError();
        }
      }
      if (messageType == "WALLET_ERROR") {
        print(
            'configureMessaging: ############## receiving WALLET_ERROR message from FCM');
        listener.onWalletError();
      }
      if (messageType == "PURCHASE_ORDER") {
        print(
            'configureMessaging: ############## receiving PURCHASE_ORDER message from FCM');
        Map map = json.decode(message["json"]);
        var po = new PurchaseOrder.fromJson(map);
        assert(po != null);
        listener.onPurchaseOrderMessage(po);
      }
      if (messageType == "DELIVERY_NOTE") {
        print(
            'configureMessaging: ############## receiving DELIVERY_NOTE message from FCM');
        Map map = json.decode(message["json"]);
        var m = new DeliveryNote.fromJson(map);
        assert(m != null);
        listener.onDeliveryNote(m);
      }
      if (messageType == "DELIVERY_ACCEPTANCE") {
        print(
            'configureMessaging: ############## receiving DELIVERY_ACCEPTANCE message from FCM');
        Map map = json.decode(message["json"]);
        var m = new DeliveryAcceptance.fromJson(map);
        assert(m != null);
        listener.onDeliveryAcceptance(m);
      }
      if (messageType == "INVOICE") {
        print(
            'configureMessaging: ############## receiving INVOICE message from FCM');
        Map map = json.decode(message["json"]);
        var m = new Invoice.fromJson(map);
        assert(m != null);
        listener.onInvoiceMessage(m);
      }
      if (messageType == "INVOICE_OFFER") {
        print(
            'configureMessaging: ############## receiving INVOICE_OFFER message from FCM');
        Map map = json.decode(message["json"]);
        var m = new Offer.fromJson(map);
        assert(m != null);
        listener.onOfferMessage(m);
      }
      if (messageType == "INVOICE_BID") {
        print(
            'configureMessaging: ############## receiving INVOICE_BID message from FCM');
        Map map = json.decode(message["json"]);
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
    onLaunch: (Map<String, dynamic> message) {},
    onResume: (Map<String, dynamic> message) {},
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

final Firestore _firestore = Firestore.instance;

_updateToken(String token) async {
  print('_updateToken #################  update user FCM token');
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

abstract class FCMListener {
  onWalletMessage(Wallet wallet);
  onWalletError();
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder);
  onDeliveryNote(DeliveryNote deliveryNote);
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance);
  onInvoiceMessage(Invoice invoice);
  onOfferMessage(Offer offer);
  onInvoiceBidMessage(InvoiceBid invoiceBid);
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement);
  onInvestorSettlement(InvestorInvoiceSettlement settlement);
  onCompanySettlement(CompanyInvoiceSettlement settlement);
}

const DEBUG_URL =
    'https://us-central1-business-finance-dev.cloudfunctions.net/';
const PROD_URL =
    'https://us-central1-business-finance-prod.cloudfunctions.net/';

Future<String> encrypt(String accountId, String secret) async {
  if (accountId == null || secret == null) {
    return null;
  }
  print('encrypt ++++++++++++ accountId: $accountId secret: $secret');

  var data = {'accountId': accountId, 'secret': secret};
  var url;
  if (isInDebugMode) {
    url = DEBUG_URL;
  } else {
    url = PROD_URL;
  }
  url += 'encryptor';
  var result = await http.post(url, body: data);
  print('encrypt ############ RESULT: ${result.body}');
  return result.body;
}

Future<String> decrypt(String accountId, String encrypted) async {
  if (accountId == null || encrypted == null) {
    return null;
  }
  print('decrypt -------- accountId: $accountId encrypted: $encrypted');

  var data = {'accountId': accountId, 'encrypted': encrypted};
  var url;
  if (isInDebugMode) {
    url = DEBUG_URL;
  } else {
    url = PROD_URL;
  }
  url += 'decryptor';
  var result = await http.post(url, body: data);

  print('decrypt ############ RESULT: ${result.body}');
  return result.body;
}
