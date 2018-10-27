import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/stellar/Account.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future saveAccount(Account account) async {
    print('SharedPrefs.saveAccount  saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = account.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('account', jx);
    //prefs.commit();
    print("SharedPrefs.saveAccount =========  data SAVED.........");
  }

  static Future<Account> getAccount() async {
    print("SharedPrefs.getAccount =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('account');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'Account from cache: ');
    var account = new Account.fromJson(jx);
    return account;
  }

  static Future saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = user.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('user', jx);
    //prefs.commit();
    print("SharedPrefs.saveUser =========  user data SAVED.........");
  }

  static Future<User> getUser() async {
    print("SharedPrefs.getUser =========  getting cached user data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('user');
    if (string == null) {
      return null;
    }

    var jx = json.decode(string);
//    prettyPrint(jx, 'User from cache: ');
    User account = new User.fromJson(jx);
    return account;
  }

  static Future saveGovtEntity(GovtEntity govtEntity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = govtEntity.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('govtEntity', jx);
    //prefs.commit();
    print("SharedPrefs.saveGovtEntity =========  data SAVED.........");
  }

  static Future<GovtEntity> getGovEntity() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('govtEntity');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
//    prettyPrint(jx, 'GovtEntity from cache: ');
    GovtEntity govtEntity = new GovtEntity.fromJson(jx);
    return govtEntity;
  }

  static Future saveInvestorProfile(InvestorProfile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = profile.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('profile', jx);
    print("SharedPrefs.saveInvestorProfile =========  data SAVED.........");
  }

  static Future<InvestorProfile> getInvestorProfile() async {
    print(
        "SharedPrefs.getInvestorProfile =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('profile');
    if (string == null) {
      print('SharedPrefs.getInvestorProfile is NULL');
      return null;
    }
    try {
      var jx = json.decode(string);
      prettyPrint(jx, 'InvestorProfile ********** from cache: ');
      var investorProfile = InvestorProfile.fromJson(jx);
      return investorProfile;
    } catch (e) {
      print('SharedPrefs.getInvestorProfile ERROR $e');
      return null;
    }
  }

  static Future saveAutoTradeStart(AutoTradeStart start) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = start.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('start', jx);
    print("SharedPrefs.saveAutoTradeStart =========  data SAVED.........");
  }

  static Future<AutoTradeStart> getAutoTradeStart() async {
    print(
        "SharedPrefs.getAutoTradeStart =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('start');
    if (string == null) {
      print('SharedPrefs.getAutoTradeStart is NULL');
      return null;
    }
    try {
      var jx = json.decode(string);
      var start = AutoTradeStart.fromJson(jx);
      return start;
    } catch (e) {
      print('SharedPrefs.getAutoTradeStart ERROR $e');
      return null;
    }
  }

  static Future saveAutoTradeOrder(AutoTradeOrder order) async {
    print('SharedPrefs.saveAutoTradeOrder  saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = order.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('autoTradeOrder', jx);
    print("SharedPrefs.AutoTradeOrder =========  data SAVED.........");
  }

  static Future removeAutoTradeOrder() async {
    print('SharedPrefs.removeAutoTradeOrder  removing data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('autoTradeOrder', null);
    print("SharedPrefs.AutoTradeOrder =========  data REMOOOVED.........");
  }

  static Future<AutoTradeOrder> getAutoTradeOrder() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('autoTradeOrder');
    if (string == null) {
      print('SharedPrefs.getAutoTradeOrder is NULL');
      return null;
    }
    try {
      var jx = json.decode(string);
      prettyPrint(jx, 'AutoTradeOrder ********** from cache: ');
      var order = AutoTradeOrder.fromJson(jx);
      return order;
    } catch (e) {
      print('SharedPrefs.getAutoTradeOrder ERROR $e');
      return null;
    }
  }

  static Future saveCompany(Company company) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = company.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('company', jx);
    //prefs.commit();
    print("SharedPrefs.saveCompany =========  data SAVED.........");
  }

  static Future<Company> getCompany() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('company');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'Company from cache: ');
    Company company = new Company.fromJson(jx);
    return company;
  }

  static Future saveSupplier(Supplier company) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = company.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('supplier', jx);
    print("SharedPrefs.saveSupplier =========  data SAVED.........");
  }

  static Future<Supplier> getSupplier() async {
    print("SharedPrefs.getSupplier=========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('supplier');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
//    prettyPrint(jx, 'Supplier from cache: ');
    Supplier supplier = new Supplier.fromJson(jx);
    return supplier;
  }

  static Future saveBank(Bank bank) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = bank.toJson();
    var jx = json.encode(jsonx);

    prefs.setString('bank', jx);
    print("SharedPrefs.saveBank =========  data SAVED.........");
  }

  static Future<Bank> getBank() async {
    print("SharedPrefs.getBank =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('bank');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'Bank from cache: ');
    Bank bank = new Bank.fromJson(jx);
    return bank;
  }

  static Future saveAuditor(Auditor auditor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = auditor.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('auditor', jx);
    print("SharedPrefs.saveAuditor =========  data SAVED.........");
  }

  static Future<Auditor> getAuditor() async {
    print("SharedPrefs.getAuditor=========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('auditor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'Bank from cache: ');
    Auditor auditor = new Auditor.fromJson(jx);
    return auditor;
  }

  static Future saveProcurementOffice(ProcurementOffice office) async {
    print('SharedPrefs.saveProcurementOfficesaving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = office.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('office', jx);
    print("SharedPrefs.saveProcurementOffice =========  data SAVED.........");
  }

  static Future<ProcurementOffice> getProcurementOffice() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('office');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'ProcurementOffice from cache: ');
    ProcurementOffice office = new ProcurementOffice.fromJson(jx);
    return office;
  }

  static Future saveInvestor(Investor investor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = investor.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('investor', jx);
    print("SharedPrefs.saveInvestor =========  data SAVED.........");
  }

  static Future<Investor> getInvestor() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('investor');
    if (string == null) {
      print('SharedPrefs.getInvestor  --------------- NO Investor here!');
      return null;
    }

    var jx = json.decode(string);
    prettyPrint(jx, 'Investor from cache: ');
    Investor investor = new Investor.fromJson(jx);
    return investor;
  }

  static Future saveOneConnect(OneConnect oneConnect) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = oneConnect.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('oneconnect', jx);
    print("SharedPrefs.saveOneConnect=========  data SAVED.........");
  }

  static Future<OneConnect> getOneConnect() async {
    print("SharedPrefs.getOneConnect =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('oneconnect');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    prettyPrint(jx, 'OneConnect from cache: ');
    OneConnect one = new OneConnect.fromJson(jx);
    return one;
  }

  static Future saveFCMToken(String token) async {
    print("SharedPrefs saving token ..........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("fcm", token);
    //prefs.commit();

    print("FCM token saved in cache prefs: $token");
  }

  static Future<String> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("fcm");
    print("SharedPrefs - FCM token from prefs: $token");
    return token;
  }

  static Future saveMinutes(int minutes) async {
    print("SharedPrefs saving minutes ..........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("minutes", minutes);

    print("FCM minutes saved in cache prefs: $minutes");
  }

  static Future<int> getMinutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var minutes = prefs.getInt("minutes");
    print("SharedPrefs - FCM minutes from prefs: $minutes");
    return minutes;
  }

  static Future<Wallet> getWallet() async {
    print("SharedPrefs - getting wallet data ..........");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jx = prefs.getString('wallet');
    if (jx == null) {
      return null;
    }
    var map = json.decode(jx);
    Wallet w = new Wallet.fromJson(map);
    print("SharedPrefs - Check the details of the wallet retrieved");
    prettyPrint(map, 'Wallet from cache: ');
    return w;
  }

  static Future saveWallet(Wallet wallet) async {
    if (wallet == null) {
      print('SharedPrefs.saveWallet - wallet is null - QUIT');
      return null;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map jsonx = wallet.toJson();
    var jx = json.encode(jsonx);
    prefs.setString('wallet', jx);
    print("SharedPrefs.saveWallet=========  data SAVED.........");

    return null;
  }

  static Future removeWallet() async {
    print("SharedPrefs - removing wallet data .........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("wallet", null);
    print("SharedPrefs - wallet removed from local prefs....... ");
    return null;
  }

  static void saveThemeIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("themeIndex", index);
    //prefs.commit();
  }

  static Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt("themeIndex");
    print("=================== SharedPrefs theme index: $index");
    return index;
  }

  static void savePictureUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", url);
    //prefs.commit();
    print('picture url saved to shared prefs');
  }

  static Future<String> getPictureUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString("url");
    print("=================== SharedPrefs url index: $path");
    return path;
  }

  static void savePicturePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("path", path);
    //prefs.commit();
    print('picture path saved to shared prefs');
  }

  static Future<String> getPicturePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString("path");
    print("=================== SharedPrefs path index: $path");
    return path;
  }

  static void savePageLimit(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("pageLimit", index);
  }

  static Future<int> getPageLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pageLimit = prefs.getInt("pageLimit");
    if (pageLimit == null) {
      pageLimit = 10;
    }
    print("=================== SharedPrefs pageLimit: $pageLimit");
    return pageLimit;
  }
}
