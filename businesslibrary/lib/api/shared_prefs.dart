import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future saveUser(User user) async {
    print('SharedPrefs.saveUser  saving user data ........');
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
    print(jx);
    User account = new User.fromJson(jx);
    return account;
  }

  static Future saveGovtEntity(GovtEntity govtEntity) async {
    print('SharedPrefs.saveGovtEntity  saving GovtEntity data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = govtEntity.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('govtEntity', jx);
    //prefs.commit();
    print("SharedPrefs.saveGovtEntity =========  data SAVED.........");
  }

  static Future<GovtEntity> getGovEntity() async {
    print("SharedPrefs.getGovEntity =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('govtEntity');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    print(jx);
    GovtEntity govtEntity = new GovtEntity.fromJson(jx);
    return govtEntity;
  }

  static Future saveCompany(Company company) async {
    print('SharedPrefs.saveCompany  saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = company.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('company', jx);
    //prefs.commit();
    print("SharedPrefs.saveCompany =========  data SAVED.........");
  }

  static Future<Company> getCompany() async {
    print("SharedPrefs.getCompany =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('company');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    print(jx);
    Company company = new Company.fromJson(jx);
    return company;
  }

  static Future saveSupplier(Supplier company) async {
    print('SharedPrefs.saveSupplier saving data ........');
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
    print(jx);
    Supplier supplier = new Supplier.fromJson(jx);
    return supplier;
  }

  static Future saveBank(Bank company) async {
    print('SharedPrefs.saveBank saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = company.toJson();
    var jx = json.encode(jsonx);
    print(jx);
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
    print(jx);
    Bank bank = new Bank.fromJson(jx);
    return bank;
  }

  static Future saveAuditor(Auditor auditor) async {
    print('SharedPrefs.saveAuditor saving data ........');
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
    print(jx);
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
    print(
        "SharedPrefs.getProcurementOffice  =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('office');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    print(jx);
    ProcurementOffice office = new ProcurementOffice.fromJson(jx);
    return office;
  }

  static Future saveInvestor(Investor investor) async {
    print('SharedPrefsInvestor  saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = investor.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('investor', jx);
    print("SharedPrefs.saveInvestor =========  data SAVED.........");
  }

  static Future<Investor> getInvestor() async {
    print("SharedPrefs.getInvestor  =========  getting cached data.........");
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('investor');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    print(jx);
    Investor investor = new Investor.fromJson(jx);
    return investor;
  }

  static Future saveOneConnect(OneConnect investor) async {
    print('SharedPrefs  OneConnect  saving data ........');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = investor.toJson();
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
    print(jx);
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
    print(w.toJson());
    return w;
  }

  static Future saveWallet(Wallet wallet) async {
    if (wallet == null) {
      print('SharedPrefs.saveWallet - wallet is null - QUIT');
      return null;
    }
    print("SharedPrefs - saving wallet data .........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map map = wallet.toJson();
    var jx = json.encode(map);

    prefs.setString("wallet", jx);
    //prefs.commit();
    print("SharedPrefs - wallet saved in local prefs....... ");
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
}
