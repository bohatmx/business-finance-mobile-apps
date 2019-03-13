import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class Lookups {
  static Firestore _firestore = Firestore.instance;

  static Future<List<Sector>> getTypes() async {
    List<Sector> list = List();

    var qs = await _firestore
        .collection('sectors')
        .orderBy('sectorName')
        .getDocuments()
        .catchError((e) {
      return list;
    });
    qs.documents.forEach((doc) {
      var type = Sector.fromJson(doc.data);
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
}

String getFormattedDateLongWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('EEEE, dd MMMM yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
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

String getFormattedDateShortWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = new DateFormat('dd MMMM yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
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
//  print('\n\getFormattedDateLong $date'); //Sun, 28 Oct 2018 23:59:49 GMT
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
    return format.format(d.toUtc());
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
  assert(amount != null);
  Locale myLocale = Localizations.localeOf(context);
  var val = myLocale.languageCode + '_' + myLocale.countryCode;
  //print('getFormattedAmount ----------- locale is  $val');
  final oCcy = new NumberFormat("#,##0.00", val);
  try {
    double m = double.parse(amount);
    return oCcy.format(m);
  } catch (e) {
    return amount;
  }
}

prettyPrint(Map map, String name) {
  print('\n\n$name \t{\n');
  map.forEach((key, val) {
    print('\t$key : $val ,\n');
  });
  print('\n}\n\n');
}

Future<bool> isDeviceIOS() async {
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool isRunningIOs = false;
  try {
    androidInfo = await deviceInfo.androidInfo;
    print(
        '\n\n\n################ isDeviceIOS: Running on ${androidInfo.model} ################\n\n');
    return isRunningIOs;
  } catch (e) {
    print('isDeviceIOS - error doing Android - this is NOT an Android phone!!');
  }

  try {
    iosInfo = await deviceInfo.iosInfo;
    print(
        '\n\n\n################ isDeviceIOS: Running on ${iosInfo.utsname.machine} ################\n\n');
    isRunningIOs = true;
  } catch (e) {
    print('isDeviceIOSerror doing iOS - this is NOT an iPhone!!');
  }
  return isRunningIOs;
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
//    seed = SignUp.privateKey;
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

    //    if (USE_LOCAL_BLOCKCHAIN) {
//      var res = await DataAPI.addWallet(wallet);
//      if (res != '0') {
//        print(
//            'Wallet created and ready for use: #######################))))))))');
//        return wallet.stellarPublicKey;
//      } else {
//        print('createWallet ERROR  writing wallet to BFN blockchain');
//        throw Exception('createWallet ERROR  writing wallet to BFN blockchain');
//      }
//    }
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
      wallet.govtEntity = NameSpace + 'Customer#' + participantId;
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
