import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
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

String getFormattedDateLongWithTime(String date, BuildContext context) {
//  print(
//      '\n\getFormattedDateLongWithTime $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('EEEE, dd MMMM yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
//      print(
//          '++++++++++++++ Formatted date with locale == ${format.format(mDate.toLocal())}');
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    print(e);
    return 'NoDate';
  }
}

String getFormattedDateLong(String date, BuildContext context) {
  print('\n\getFormattedDateLong $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('EEEE, dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      print(
          '++++++++++++++ Formatted date with locale == ${format.format(mDate.toLocal())}');
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    print(e);
    return 'NoDate';
  }
}

String getFormattedDateShort(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      print(
          '++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    print(e);
    return 'NoDate';
  }
}

String getFormattedDateShortest(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('dd-MM-yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      print(
          '++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    print(e);
    return 'NoDate';
  }
}

int getIntDate(String date, BuildContext context) {
  print(
      '\n\n---------------> getIntDate $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  assert(context != null);
  initializeDateFormatting();
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return mDate.millisecondsSinceEpoch;
    } else {
      var mDate = DateTime.parse(date);
      return mDate.millisecondsSinceEpoch;
    }
  } catch (e) {
    print(e);
    return 0;
  }
}

String getFormattedDateHourMinute(String date, BuildContext context) {
  print('\n\getFormattedDateHourMinute $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      print(
          '++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate);
    }
  } catch (e) {
    print(e);
    return 'NoDate';
  }
}

DateTime getLocalDateFromGMT(String date, BuildContext context) {
  //print('getLocalDateFromGMT string: $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  //print('+++++++++++++++ locale: ${myLocale.toString()}');
  initializeDateFormatting();
  try {
    var mDate = translateGMTString(date);
    return mDate.toLocal();
  } catch (e) {
    print(e);
    throw e;
  }
}

DateTime translateGMTString(String date) {
  var strings = date.split(' ');
  var day = int.parse(strings[1]);
  var mth = strings[2];
  var year = int.parse(strings[3]);
  var time = strings[4].split(':');
  var hour = int.parse(time[0]);
  var min = int.parse(time[1]);
  var sec = int.parse(time[2]);
  var cc = DateTime.utc(year, getMonth(mth), day, hour, min, sec);

  //print('##### translated date: ${cc.toIso8601String()}');
  //print('##### translated local: ${cc.toLocal().toIso8601String()}');

  return cc;
}

int getMonth(String mth) {
  switch (mth) {
    case 'Jan':
      return 1;
    case 'Feb':
      return 2;
    case 'Mar':
      return 3;
    case 'Apr':
      return 4;
    case 'Jun':
      return 6;
    case 'Jul':
      return 7;
    case 'Aug':
      return 8;
    case 'Sep':
      return 9;
    case 'Oct':
      return 10;
    case 'Nov':
      return 11;
    case 'Dec':
      return 12;
  }
  return 0;
}

String getUTCDate() {
  initializeDateFormatting();
  String now = new DateTime.now().toUtc().toIso8601String();
  return now;
}

String getUTC(DateTime date) {
  initializeDateFormatting();
  String now = date.toUtc().toIso8601String();
  return now;
}

String getFormattedDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = new DateFormat.yMMMd();
    return format.format(d);
  } catch (e) {
    return date;
  }
}

String getFormattedDateHour(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = new DateFormat.Hm();
    return format.format(d);
  } catch (e) {
    DateTime d = DateTime.now();
    var format = new DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedNumber(int number, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = myLocale.languageCode + '_' + myLocale.countryCode;
  final oCcy = new NumberFormat("###,###,###,###,###", val);

  return oCcy.format(number);
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
      print('\n\nRECEIVED FCM message, onMessage:\n$message \n');
      var data = message['data'];
      String messageType = data["messageType"];
      try {
        if (messageType.contains("INVOICE_BID")) {
          var invoiceBid = InvoiceBid.fromJson(json.decode(data['json']));
          listener.onInvoiceBidMessage(invoiceBid);
        }
        if (messageType.contains("OFFER")) {
          var offer = Offer.fromJson(json.decode(data['json']));
          listener.onOfferMessage(offer);
        }
        if (messageType.contains("HEARTBEAT")) {
          Map map = json.decode(data['json']);
          listener.onHeartbeat(map);
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
  onInvoiceBidMessage(InvoiceBid invoiceBid);

  onOfferMessage(Offer offer);

  onHeartbeat(Map map);
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

Future<String> createWallet(
    {@required String name,
    @required String participantId,
    @required int type,
    String seed}) async {
  var debugData = {
    'debug': 'true',
  };
  var prodData = {'debug': 'false', 'sourceSeed': seed};
  String url;
  var body;
  if (isInDebugMode) {
    url = DEBUG_URL;
    body = debugData;
  } else {
    url = PROD_URL;
    body = prodData;
    seed = SignUp.privateKey;
  }
  url += 'directWallet';
  http.Response result;
  Wallet wallet;
  print('createWallet ------- making the http.post call -----\n $url');
  try {
    result = await http.post(url, body: body).catchError((e) {
      print('createWallet ----- ERROR $e');
      return '0';
    });
    print('createWallet - done calling http post');
    Map map = json.decode(result.body);
    wallet = Wallet.fromJson(map);
    wallet.name = name;
    print(
        'createWallet ###>> Status Code: ${result.statusCode} \n\nBody: ${result.body}\n\n');
    var walletDocId =
        await _writeWalletToFirestore(type, wallet, participantId);
    if (walletDocId == '0') {
      return walletDocId;
    }

    wallet.documentReference = walletDocId;
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addWallet(wallet);
      if (res != '0') {
        print(
            'Wallet created and ready for use: #######################))))))))');
        return wallet.stellarPublicKey;
      } else {
        print('createWallet ERROR  writing wallet to BFN blockchain');
        throw Exception('createWallet ERROR  writing wallet to BFN blockchain');
      }
    }
  } catch (e) {
    print('createWallet ERROR - WALLET failed $e');
    throw Exception('createWallet ERROR - WALLET failed $e');
  }

  return '0';
}

Future<String> _writeWalletToFirestore(
    int type, Wallet wallet, String participantId) async {
  print(
      '\n\n_writeWalletToFirestore  ######## type: $type participantId: $participantId\n\n');

  switch (type) {
    case GovtEntityType:
      wallet.govtEntity = NameSpace + 'GovtEntity#' + participantId;
      break;
    case SupplierType:
      wallet.supplier = NameSpace + 'Supplier#' + participantId;
      break;
    case InvestorType:
      wallet.investor = NameSpace + 'Investor#' + participantId;
      break;
    case ProcurementOfficeType:
      wallet.procurementOffice =
          NameSpace + 'ProcurementOffice#' + participantId;
      break;
    case AuditorType:
      wallet.auditor = NameSpace + 'Auditor#' + participantId;
      break;
    case BankType:
      wallet.bank = NameSpace + 'Bank#' + participantId;
      break;
    case OneConnectType:
      wallet.oneConnect = NameSpace + 'OneConnect#' + participantId;
      break;
    case CompanyType:
      wallet.company = NameSpace + 'Company#' + participantId;
      break;
  }
  try {
    print('_writeWalletToFirestore: about to write wallet to FS....');
    var ref = await _firestore
        .collection('wallets')
        .add(wallet.toJson())
        .catchError((e) {
      print('createWallet FAILED to write wallet to Firestore: $e');
      throw Exception('Failed to write wallet to firestore $e');
    });
    print('createWallet added to Firestore, documentRef: ${ref.documentID}');
    wallet.documentReference = ref.documentID;
    await SharedPrefs.saveWallet(wallet);
    return ref.documentID;
  } catch (e) {
    throw Exception('Failed to write wallet to firestore $e');
  }
}

const GovtEntityType = 1,
    SupplierType = 2,
    InvestorType = 3,
    CompanyType = 4,
    AuditorType = 5,
    ProcurementOfficeType = 6,
    BankType = 7,
    OneConnectType = 8;

const NameSpace = 'resource:com.oneconnect.biz.';
