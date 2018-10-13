import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/helper.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/item.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/offerCancellation.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DataAPI {
  static Firestore _firestore = Firestore.instance;

  static const GOVT_ENTITY = 'GovtEntity',
      USER = 'User',
      SUPPLIER = 'Supplier',
      ITEM = 'Item',
      AUDITOR = 'Auditor',
      COMPANY = 'Company',
      PROCUREMENT_OFFICE = 'ProcurementOffice',
      BANK = 'Bank',
      ONECONNECT = 'OneConnect',
      SUPPLIER_CONTRACT = 'SupplierContract',
      WALLET = 'Wallet',
      REGISTER_PURCHASE_ORDER = 'RegisterPurchaseOrder',
      REGISTER_DELIVERY_NOTE = 'RegisterDeliveryNote',
      REGISTER_INVOICE = 'RegisterInvoice',
      ACCEPT_DELIVERY = 'AcceptDelivery',
      ACCEPT_INVOICE = 'AcceptInvoice',
      MAKE_INVOICE_OFFER = 'MakeInvoiceOffer',
      MAKE_INVOICE_BID = 'MakeInvoiceBid',
      CANCEL_OFFER = 'CancelOffer',
      CLOSE_OFFER = 'CloseOffer',
      UPDATE_PURCHASE_ORDER_CONTRACT = 'UpdatePurchaseOrderContract',
      MAKE_INVESTOR_SETTLEMENT = 'MakeInvestorInvoiceSettlement',
      MAKE_COMPANY_SETTLEMENT = 'MakeCompanyInvoiceSettlement',
      MAKE_GOVT_SETTLEMENT = 'MakeGovtInvoiceSettlement',
      INVESTOR__PROFILE = 'InvestorProfile',
      UPDATE_INVESTOR__PROFILE = 'UpdateInvestorProfile',
      AUTO_TRADE_ORDER = 'AutoTradeOrder',
      EXECUTE_INVESTOR_AUTO_TRADE_ORDERS = 'ExecuteInvestorAutoTrades',
      EXECUTE_ALL_AUTO_TRADE_ORDERS = 'ExecuteAllAutoTrades',
      CANCEL_AUTO_TRADE_ORDER = 'CancelAutoTradeOrder',
      SECTOR = 'Sector',
      INVESTOR = 'Investor';
  static const ErrorFirestore = 1, ErrorBlockchain = 2, Success = 0;

  static HttpClient _httpClient = new HttpClient();
  static ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");

  static Future<String> addGovtEntity(GovtEntity govtEntity, User admin) async {
    govtEntity.participantId = getKey();
    admin.userId = getKey();
    govtEntity.dateRegistered = getUTCDate();
    admin.govtEntity =
        'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}';
    print('DataAPI.addGovtEntity url: ${getURL() + GOVT_ENTITY}');

    try {
      HttpClientRequest mRequest =
          await _httpClient.postUrl(Uri.parse(getURL() + GOVT_ENTITY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(govtEntity.toJson()));

      HttpClientResponse resp = await mRequest.close();
      print('DataAPI.addGovtEntity resp.statusCode: ${resp.statusCode} }');
      if (resp.statusCode == 200) {
        var ref = await _firestore
            .collection('govtEntities')
            .add(govtEntity.toJson())
            .catchError((e) {
          print('DataAPI.addGovtEntity ERROR adding to Firestore $e');
          return ErrorFirestore;
        });
        print('DataAPI.addGovtEntity and user added to Firestore: ${ref.path}');
        var mRef = await _firestore
            .collection('users')
            .add(admin.toJson())
            .catchError((e) {
          print(e);
        });
        print('DataAPI.addGovtEntity USER added to Firestore: ${mRef.path}');
        govtEntity.documentReference = ref.documentID;
        await SharedPrefs.saveGovtEntity(govtEntity);
        //get wallet
        await createWallet(
            name: govtEntity.name,
            participantId: govtEntity.participantId,
            type: GovtEntityType);
        return govtEntity.participantId;
      } else {
        resp.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addGovtEntity  $contents');
        });
        print('DataAPI.addGovtEntity ERROR  ${resp.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addGovtEntity ERROR $e');
      return '0';
    }
  }

//  static Future<String> addUser(User user) async {
//    user.userId = getKey();
//    user.dateRegistered = getUTCDate();
//    print('DataAPI.addUser url: ${getURL() + USER}');
//    prettyPrint(user.toJson(), 'DataAPI.addUser ');
//    try {
//      var httpClient = new HttpClient();
//      HttpClientRequest mRequest =
//          await httpClient.postUrl(Uri.parse(getURL() + USER));
//      mRequest.headers.contentType = _contentType;
//      mRequest.write(json.encode(user.toJson()));
//      HttpClientResponse mResponse = await mRequest.close();
//      print(
//          'DataAPI.addUser ######## blockchain response status code:  ${mResponse.statusCode}');
//      if (mResponse.statusCode == 200) {
//        var ref = await _firestore
//            .collection('users')
//            .add(user.toJson())
//            .catchError((e) {
//          print('DataAPI.addUser ERROR $e');
//          return "0";
//        });
//        print('DataAPI.addUser user added to Firestore ${ref.documentID}');
//
//        user.documentReference = ref.documentID;
//        await SharedPrefs.saveUser(user);
//        return user.userId;
//      } else {
//        mResponse.transform(utf8.decoder).listen((contents) {
//          print('DataAPI.addUser  $contents');
//        });
//        print(
//            'DataAPI.addUser ----- ERROR  ${mResponse.reasonPhrase} ${mResponse.headers}');
//        return "0";
//      }
//    } catch (e) {
//      print('DataAPI.addUser ERROR $e');
//      return '0';
//    }
//  }

  static Future<String> addSectors() async {
    await addSector(Sector(sectorId: getKey(), sectorName: 'Public Sector'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Automotive'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Construction'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Engineering'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Retail'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Home Services'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Transport'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Logistics'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Services'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Agricultural'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Real Estate'));
    await addSector(Sector(sectorId: getKey(), sectorName: 'Technology'));

    return 'OK';
  }

  static Future<String> addSector(Sector sector) async {
    sector.sectorId = getKey();
    print('DataAPI.addSector %%%%%%%% url: ${getURL() + SECTOR}');
    prettyPrint(sector.toJson(), 'adding sector to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + SECTOR));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(sector.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSector blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = _firestore
            .collection('sectors')
            .add(sector.toJson())
            .catchError((e) {
          print('DataAPI.addSector ERROR $e');
        });
        print('DataAPI.addSector sector added ${sector.toJson()} $ref');
        return sector.sectorId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSector  $contents');
        });
        print('DataAPI.addSector ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addSector ERROR $e');
      return '0';
    }
  }

  static Future<String> addAutoTradeOrder(AutoTradeOrder order) async {
    order.autoTradeOrderId = getKey();
    order.date = getUTCDate();
    order.isCancelled = false;
    print(
        'DataAPI.addAutoTradeOrder %%%%%%%% url: ${getURL() + AUTO_TRADE_ORDER}');
    prettyPrint(order.toJson(),
        '########################## adding addAutoTradeOrder to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + AUTO_TRADE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(order.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addAutoTradeOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('autoTradeOrders')
            .add(order.toJson())
            .catchError((e) {
          print('DataAPI.addAutoTradeOrder ERROR $e');
        });
        print('DataAPI.addAutoTradeOrder order added ${ref.path}');
        SharedPrefs.saveAutoTradeOrder(order);
        return order.autoTradeOrderId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addAutoTradeOrder  $contents');
        });
        print('DataAPI.addAutoTradeOrder ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addAutoTradeOrder ERROR $e');
      return '0';
    }
  }

  static Future<String> updateAutoTradeOrder(AutoTradeOrder order) async {
    order.date = getUTCDate();

    print(
        'DataAPI.updateAutoTradeOrder %%%%%%%% url: ${getURL() + AUTO_TRADE_ORDER + '/' + order.autoTradeOrderId}');
    prettyPrint(order.toJson(),
        '########################## adding updateAutoTradeOrder to BFN blockchain');

    //'https://bfnrestv3.eu-gb.mybluemix.net/api/AutoTradeOrder/e9d26c20-9620-11e8-81e2-e16bada8b621'
    try {
      var mURL = getURL() + AUTO_TRADE_ORDER + '/' + order.autoTradeOrderId;
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient.putUrl(Uri.parse(mURL));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(order.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.updateAutoTradeOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var qs = await _firestore
            .collection('autoTradeOrders')
            .where('autoTradeOrderId', isEqualTo: order.autoTradeOrderId)
            .getDocuments()
            .catchError((e) {
          print('DataAPI.updateAutoTradeOrder $e');
        });
        await _firestore
            .collection('autoTradeOrders')
            .document(qs.documents.first.documentID)
            .setData(order.toJson())
            .catchError((e) {
          print('DataAPI.updateAutoTradeOrder ERROR $e');
        });
        SharedPrefs.saveAutoTradeOrder(order);
        return order.autoTradeOrderId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.updateAutoTradeOrder  $contents');
        });
        print('DataAPI.updateAutoTradeOrder ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.updateAutoTradeOrder ERROR $e');
      return '0';
    }
  }

  static Future<String> cancelAutoTradeOrder(
      String autoTradeOrderId, String investorId) async {
    var map = Map<String, String>();
    map['autoTradeOrderId'] = autoTradeOrderId;
    map['investorId'] = investorId;

    print(
        'DataAPI.cancelAutoTradeOrder %%%%%%%% url: ${getURL() + CANCEL_AUTO_TRADE_ORDER}');
    prettyPrint(map,
        '########################## adding cancelAutoTradeOrder to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + CANCEL_AUTO_TRADE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(map));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.cancelAutoTradeOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        map['date'] = getUTCDate();
        await _firestore
            .collection('cancelledAutoTradeOrders')
            .add(map)
            .catchError((e) {
          print('DataAPI.cancelAutoTradeOrder ERROR $e');
        });
        var qs = await _firestore
            .collection('autoTradeOrders')
            .where('autoTradeOrderId', isEqualTo: autoTradeOrderId)
            .getDocuments()
            .catchError((e) {
          print('DataAPI.cancelAutoTradeOrder ERROR $e');
        });

        if (qs.documents.isNotEmpty) {
          var data = qs.documents.first.data;
          var order = AutoTradeOrder.fromJson(data);
          order.dateCancelled = getUTCDate();
          await _firestore
              .collection('autoTradeOrders')
              .document(qs.documents.first.documentID)
              .setData(order.toJson())
              .catchError((e) {
            print('DataAPI.cancelAutoTradeOrder ERROR $e');
          });
          print(
              'DataAPI.cancelAutoTradeOrder autoTradeOrder pdated with cancel');
        }

        SharedPrefs.removeAutoTradeOrder();
        return autoTradeOrderId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.cancelAutoTradeOrder  $contents');
        });
        print('DataAPI.cancelAutoTradeOrder ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.cancelAutoTradeOrder ERROR $e');
      return '0';
    }
  }

  static Future<String> addInvestorProfile(InvestorProfile profile) async {
    profile.profileId = getKey();
    profile.date = getUTCDate();
    print(
        'DataAPI.addInvestorProfile %%%%%%%% url: ${getURL() + INVESTOR__PROFILE}');
    prettyPrint(profile.toJson(),
        '########################## adding addInvestorProfile to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + INVESTOR__PROFILE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(profile.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addInvestorProfile blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('investorProfiles')
            .add(profile.toJson())
            .catchError((e) {
          print('DataAPI.addInvestorProfile ERROR $e');
        });
        print('DataAPI.addInvestorProfile sector added ${ref.path}');
        SharedPrefs.saveInvestorProfile(profile);
        return profile.profileId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addInvestorProfile  $contents');
        });
        print('DataAPI.addInvestorProfile ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addInvestorProfile ERROR $e');
      return '0';
    }
  }

  static Future<String> updateInvestorProfile(InvestorProfile profile) async {
    profile.date = getUTCDate();
    print(
        'DataAPI.updateInvestorProfile %%%%%%%% url: ${getURL() + UPDATE_INVESTOR__PROFILE}');
    prettyPrint(profile.toJson(),
        '########################## updating InvestorProfile on BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + UPDATE_INVESTOR__PROFILE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(profile.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.updateInvestorProfile blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var qs = await _firestore
            .collection('investorProfiles')
            .where('profileId', isEqualTo: profile.profileId)
            .getDocuments()
            .catchError((e) {
          print('DataAPI.updateInvestorProfile ERROR $e');
        });
        if (qs.documents.isNotEmpty) {
          var id = qs.documents.first.documentID;
          await _firestore
              .collection('investorProfiles')
              .document(id)
              .setData(profile.toJson())
              .catchError((e) {
            print('DataAPI.updateInvestorProfile ERROR $e');
          });
          print('DataAPI.updateInvestorProfile profile updated');
          SharedPrefs.saveInvestorProfile(profile);
        }
        return profile.profileId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.updateInvestorProfile  $contents');
        });
        print('DataAPI.updateInvestorProfile ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.updateInvestorProfile ERROR $e');
      return '0';
    }
  }

  static Future<String> addWallet(Wallet wallet) async {
    print('DataAPI.addWallet %%%%%%%% url: ${getURL() + WALLET}');
    prettyPrint(wallet.toJson(), 'adding wallet to BFN blockcahain');

    wallet.encryptedSecret = null;
    wallet.debug = null;
    wallet.sourceSeed = null;
    wallet.secret = null;
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + WALLET));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(wallet.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addWallet blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return wallet.stellarPublicKey;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addWallet  $contents');
        });
        print('DataAPI.addWallet ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addWallet ERROR $e');
      return '0';
    }
  }

  static Future<String> addCompany(Company company) async {
    company.participantId = getKey();
    company.dateRegistered = getUTCDate();

    print('DataAPI.addCompany ${getURL() + COMPANY}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + COMPANY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(company.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addCompany blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('companies')
            .add(company.toJson())
            .catchError((e) {
          print('DataAPI.addCompany ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addCompany added to Firestore: ${ref.path}');
        company.documentReference = ref.documentID;
        await SharedPrefs.saveCompany(company);
        return company.participantId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addCompany  $contents');
        });

        print('DataAPI.addCompany ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addCompany ERROR $e');
      return '0';
    }
  }

  static Future<String> addSupplier(Supplier supplier, User admin) async {
    supplier.participantId = getKey();
    supplier.dateRegistered = getUTCDate();
    admin.supplier =
        'resource:com.oneconnect.biz.Supplier#${supplier.participantId}';
    admin.userId = getKey();
    print('DataAPI.addSupplier url: ${getURL() + SUPPLIER}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + SUPPLIER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(supplier.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSupplier blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('suppliers')
            .add(supplier.toJson())
            .catchError((e) {
          print('DataAPI.addSupplier ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addSupplier added to Firestore: ${ref.documentID}');
        supplier.documentReference = ref.documentID;
        await SharedPrefs.saveSupplier(supplier);
        var mRef = await _firestore
            .collection('users')
            .add(admin.toJson())
            .catchError((e) {
          print('DataAPI.addInvestor ERROR adding user to Firestore $e');
          return '0';
        });
        print('DataAPI.addSupplier USER added to Firestore: ${mRef.path}');
        //get wallet
        await createWallet(
            name: supplier.name,
            participantId: supplier.participantId,
            type: SupplierType);
        return supplier.participantId;
      } else {
        print('DataAPI.addSupplier ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSupplier  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addSupplier ERROR $e');
      return '0';
    }
  }

  static Future<String> addInvestor(Investor investor, User admin) async {
    investor.participantId = getKey();
    investor.dateRegistered = getUTCDate();
    admin.investor =
        'resource:com.oneconnect.biz.Investor#${investor.participantId}';
    admin.userId = getKey();
    print('DataAPI.addInvestor   ${getURL() + INVESTOR}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + INVESTOR));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(investor.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addInvestor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('investors')
            .add(investor.toJson())
            .catchError((e) {
          print('DataAPI.addInvestor ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addInvestor added to Firestore: ${ref.path}');
        investor.documentReference = ref.documentID;
        var mRef = await _firestore
            .collection('users')
            .add(admin.toJson())
            .catchError((e) {
          print('DataAPI.addInvestor ERROR adding user to Firestore $e');
          return '0';
        });
        print('DataAPI.addInvestor USER added to Firestore: ${mRef.path}');
        await SharedPrefs.saveInvestor(investor);
        //get wallet
        await createWallet(
            name: investor.name,
            participantId: investor.participantId,
            type: InvestorType);
        return investor.participantId;
      } else {
        print('DataAPI.addInvestor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addInvestor  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addInvestor ERROR $e');
      return '0';
    }
  }

  static Future<String> addBank(Bank bank) async {
    bank.participantId = getKey();
    bank.dateRegistered = getUTCDate();

    print('DataAPI.addBank ${getURL() + BANK}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + BANK));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bank.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addBank blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('banks')
            .add(bank.toJson())
            .catchError((e) {
          print('DataAPI.addBank ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addBank added to Firestore: ${ref.path}');
        bank.documentReference = ref.documentID;
        await SharedPrefs.saveBank(bank);
        return bank.participantId;
      } else {
        print('DataAPI.addBank ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addBank  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addBank ERROR $e');
      return '0';
    }
  }

  static Future<String> addSupplierContract(SupplierContract contract) async {
    var supplierId = contract.supplier.split("#").elementAt(1);
    var docId = await _getDocumentId('suppliers', supplierId);
    contract.supplierDocumentRef = docId;
    contract.date = getUTCDate();
    if (contract.govtEntity != null) {
      var id = contract.govtEntity.split("#").elementAt(1);
      var docId = await _getDocumentId('govtEntities', id);
      contract.govtDocumentRef = docId;
    }
    if (contract.company != null) {
      var id = contract.company.split("#").elementAt(1);
      var docId = await _getDocumentId('companies', id);
      contract.companyDocumentRef = docId;
    }

    contract.contractId = getKey();
    contract.date = getUTCDate();

    print(
        'DataAPI.addSupplierContract #########################  ${getURL() + SUPPLIER_CONTRACT}');
    prettyPrint(contract.toJson(),
        'DataAPI.addSupplierContract: document refs anyone? .....  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + SUPPLIER_CONTRACT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(contract.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSupplierContract blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('suppliers')
            .document(docId)
            .collection('supplierContracts')
            .add(contract.toJson())
            .catchError((e) {
          print('DataAPI.addSupplierContract ERROR adding to Firestore $e');
          return '0';
        });
        print(
            'DataAPI.addSupplierContract added to Firestore: ${ref.documentID}');

        return contract.contractId;
      } else {
        print('DataAPI.addSupplierContract ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSupplierContract  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addSupplierContract ERROR $e');
      return '0';
    }
  }

  static Future<String> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = getKey();
    oneConnect.dateRegistered = getUTCDate();

    print('DataAPI.addOneConnect ${getURL() + ONECONNECT}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + ONECONNECT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(oneConnect.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addOneConnect blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('oneConnect')
            .add(oneConnect.toJson())
            .catchError((e) {
          print('DataAPI.addOneConnect ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addOneConnect added to Firestore: ${ref.documentID}');
        oneConnect.documentReference = ref.documentID;
        await SharedPrefs.saveOneConnect(oneConnect);
        return oneConnect.participantId;
      } else {
        print('DataAPI.addOneConnect ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addOneConnect  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addOneConnect ERROR $e');
      return '0';
    }
  }

  static Future<String> addProcurementOffice(ProcurementOffice office) async {
    office.participantId = getKey();
    office.dateRegistered = getUTCDate();

    print('DataAPI.addProcurementOffice ${getURL() + PROCUREMENT_OFFICE}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + PROCUREMENT_OFFICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(office.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addProcurementOffice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('procurementOffices')
            .add(office.toJson())
            .catchError((e) {
          print('DataAPI.addProcurementOffice ERROR adding to Firestore $e');
          return '0';
        });
        print(
            'DataAPI.addProcurementOffice added to Firestore: ${ref.documentID}');
        office.documentReference = ref.documentID;
        await SharedPrefs.saveProcurementOffice(office);
        return office.participantId;
      } else {
        print('DataAPI.addProcurementOffice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addProcurementOffice  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addProcurementOffice ERROR $e');
      return '0';
    }
  }

  static Future<String> addAuditor(Auditor auditor) async {
    auditor.participantId = getKey();
    auditor.dateRegistered = getUTCDate();

    print('DataAPI.addAuditor ${getURL() + AUDITOR}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + AUDITOR));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(auditor.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addAuditor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('auditors')
            .add(auditor.toJson())
            .catchError((e) {
          print('DataAPI.addAuditor ERROR adding to Firestore $e');
          return '0';
        });
        print('DataAPI.addAuditor added to Firestore: ${ref.documentID}');
        auditor.documentReference = ref.documentID;
        await SharedPrefs.saveAuditor(auditor);
        return auditor.participantId;
      } else {
        print('DataAPI.addAuditor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addAuditor  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.addAuditor ERROR $e');
      return '0';
    }
  }

  /// transactions
  ///
  static Future<String> registerPurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    assert(purchaseOrder.purchaserName != null);

    purchaseOrder.purchaseOrderId = getKey();
    print(
        'DataAPI.registerPurchaseOrder ... starting purchase: ${purchaseOrder.toJson()}');

    print(
        'DataAPI.registerPurchaseOrder url: ${getURL() + REGISTER_PURCHASE_ORDER}');
    prettyPrint(purchaseOrder.toJson(), 'DataAPI.registerPurchaseOrder  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + REGISTER_PURCHASE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(purchaseOrder.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerPurchaseOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var result = await addPurchaseOrderToFirestore(purchaseOrder);
        if (result != DataAPI3.Success) {
          return '0';
        }
        return purchaseOrder.purchaseOrderId;
      } else {
        print('DataAPI.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerPurchaseOrder  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return '0';
    }
  }

  static Future<String> _getDocumentId(
      String collection, String participantId) async {
    var documentId;
    var querySnapshot = await _firestore
        .collection(collection)
        .where('participantId', isEqualTo: participantId)
        .getDocuments();

    querySnapshot.documents.forEach((docSnapshot) {
      documentId = docSnapshot.documentID;
    });

    return documentId;
  }

  static Future<String> addPurchaseOrderItem(
      PurchaseOrderItem item, PurchaseOrder purchaseOrder) async {
    String path, documentId, participantId;
    if (purchaseOrder.govtEntity != null) {
      path = 'govtEntities';
      participantId = purchaseOrder.govtEntity.split('#').elementAt(1);
      documentId = await _getDocumentId(path, participantId);
    }
    if (purchaseOrder.company != null) {
      path = 'companies';
      participantId = purchaseOrder.company.split('#').elementAt(1);
      documentId = await _getDocumentId(path, participantId);
    }

    await _firestore
        .collection(path)
        .document(documentId)
        .collection('purchaseOrders')
        .document(purchaseOrder.documentReference)
        .collection('items')
        .add(item.toJson())
        .catchError((e) {
      print('DataAPI.addPurchaseOrderItem ERROR $e');
      return '0';
    });
    return await _addItem(item);
  }

  static Future<String> _addItem(PurchaseOrderItem item) async {
    item.itemId = getKey();

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + ITEM));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(item.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addItem blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return item.itemId;
      } else {
        print('DataAPI.addItem ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addItem ERROR $e');
      return '0';
    }
  }

  static Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();

    prettyPrint(deliveryNote.toJson(), 'registerDeliveryNote ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + REGISTER_DELIVERY_NOTE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(deliveryNote.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerDeliveryNote blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var result = await addDeliveryNoteToFirestore(deliveryNote);
        if (result != DataAPI3.Success) {
          return '0';
        }
        return deliveryNote.deliveryNoteId;
      } else {
        print('DataAPI.registerDeliveryNote ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerDeliveryNote  $contents');
        });
        return "0";
      }
    } catch (e) {
      print('DataAPI.registerDeliveryNote ERROR $e');
      return '0';
    }
  }

  static Future<String> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    invoice.isOnOffer = false;
    invoice.isSettled = false;

    print('DataAPI.registerInvoice url: ${getURL() + REGISTER_INVOICE}');
    prettyPrint(invoice.toJson(),
        'DataAPI.registerInvoice .. calling BFN via http(s) ...');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + REGISTER_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(invoice.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var result = await addInvoiceToFirestore(invoice);
        if (result != DataAPI3.Success) {
          return '0';
        }

        return invoice.invoiceId;
      } else {
        print('DataAPI.registerInvoice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerInvoice  $contents');
        });
        print('DataAPI.registerInvoice Firestore invoice deleted');
        return "0";
      }
    } catch (e) {
      print('DataAPI.registerInvoice ERROR $e');
      return '0';
    }
  }

  static Future<String> acceptDelivery(DeliveryAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();

    print('\n\nDataAPI.acceptDelivery url: ${getURL() + ACCEPT_DELIVERY}');
    prettyPrint(
        acceptance.toJson(), 'DataAPI.acceptDelivery ... calling BFN ...');
    try {
      Map map = acceptance.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + ACCEPT_DELIVERY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.acceptDelivery blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await mirrorDeliveryAcceptance(acceptance);
        return acceptance.acceptanceId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.acceptDelivery ERROR  $contents');
        });
        print('DataAPI.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.acceptDelivery ERROR $e');
      return '0';
    }
  }

  static Future mirrorDeliveryAcceptance(DeliveryAcceptance acceptance) async {
    String participantId, path;
    if (acceptance.govtEntity != null) {
      participantId = acceptance.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
    }
    if (acceptance.company != null) {
      participantId = acceptance.company.split('#').elementAt(1);
      path = 'companies';
    }
    String documentId = await _getDocumentId(path, participantId);
    var ref = await _firestore
        .collection(path)
        .document(documentId)
        .collection('deliveryAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI.mirrorDeliveryAcceptance  ERROR $e');
      return '0';
    });
    var ref2 = await _firestore
        .collection('suppliers')
        .document(acceptance.supplierDocumentRef)
        .collection('deliveryAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI.mirrorDeliveryAcceptance  ERROR $e');
      return '0';
    });
    var qs = await _firestore
        .collection('suppliers')
        .document(acceptance.supplierDocumentRef)
        .collection('invoices')
        .where('invoice', isEqualTo: acceptance.invoice)
        .getDocuments()
        .catchError((e) {
      print('DataAPI.mirrorDeliveryAcceptance  ERROR $e');
      return '0';
    });
    if (qs.documents.isNotEmpty) {
      var inv = Invoice.fromJson(qs.documents.first.data);
      inv.documentReference = qs.documents.first.documentID;
      inv.deliveryAcceptance =
          'resource:com.oneconnect.biz.DeliveryAcceptance#${acceptance.acceptanceId}';
      await _firestore
          .collection('suppliers')
          .document(acceptance.supplierDocumentRef)
          .collection('invoices')
          .document(qs.documents.first.documentID)
          .setData(inv.toJson())
          .catchError((e) {
        print('DataAPI.mirrorDeliveryAcceptance  ERROR $e');
        return '0';
      });
      print(
          'DataAPI.mirrorDeliveryAcceptance invoice updated with deliveryAcceptance ');
    }
    print(
        'DataAPI.mirrorDeliveryAcceptance OWNER added to Firestore: ${ref.path}');
    print(
        'DataAPI.mirrorDeliveryAcceptance SUPPLIER added to Firestore: ${ref2.path}');
  }

  static Future<String> acceptInvoice(InvoiceAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();

    print('DataAPI.acceptInvoice url: ${getURL() + ACCEPT_INVOICE}');
    prettyPrint(
        acceptance.toJson(), 'DataAPI.acceptInvoice ... calling BFN ...');
    try {
      Map map = acceptance.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + ACCEPT_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.acceptInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await _mirrorInvoiceAcceptance(acceptance);
        return acceptance.acceptanceId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.acceptInvoice ERROR  $contents');
        });
        print('DataAPI.acceptInvoice ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.acceptInvoice ERROR $e');
      return '0';
    }
  }

  static Future _mirrorInvoiceAcceptance(InvoiceAcceptance acceptance) async {
    //todo - update invoice with acceptance?

    String documentId, participantId, path;
    if (acceptance.govtEntity != null) {
      participantId = acceptance.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
    }
    if (acceptance.company != null) {
      participantId = acceptance.company.split('#').elementAt(1);
      path = 'companies';
    }
    documentId = await _getDocumentId(path, participantId);

    var ref = await _firestore
        .collection('suppliers')
        .document(acceptance.supplierDocumentRef)
        .collection('invoiceAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI._mirrorInvoiceAcceptance  ERROR $e');
      return '0';
    });
    var ref2 = await _firestore
        .collection(path)
        .document(documentId)
        .collection('invoiceAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI._mirrorInvoiceAcceptance  ERROR $e');
      return '0';
    });
    assert(acceptance.supplierDocumentRef != null);
    var inv = await ListAPI.getSupplierInvoiceByNumber(
        acceptance.invoiceNumber, acceptance.supplierDocumentRef);
    inv.invoiceAcceptance =
        'resource:com.oneconnect.biz.InvoiceAcceptance#${acceptance.acceptanceId}';
    await _firestore
        .collection('suppliers')
        .document(acceptance.supplierDocumentRef)
        .collection('invoices')
        .document(inv.documentReference)
        .updateData(inv.toJson());
    print(
        'DataAPI._mirrorInvoiceAcceptance ******* supplier invoice updated with  acceptance *****');
    if (inv.govtEntity != null) {
      assert(inv.govtDocumentRef != null);
      var govtInv = await ListAPI.getGovtInvoiceByNumber(
          inv.invoiceNumber, inv.govtDocumentRef);
      assert(govtInv.govtDocumentRef != null);
      govtInv.invoiceAcceptance = inv.invoiceAcceptance;
      await _firestore
          .collection('govtEntities')
          .document(inv.govtDocumentRef)
          .collection('invoices')
          .document(govtInv.documentReference)
          .updateData(govtInv.toJson());
      print(
          'DataAPI._mirrorInvoiceAcceptance ******* govt invoice updated with  acceptance *****');
    }

    print(
        'DataAPI._mirrorInvoiceAcceptance OWNER added to Firestore: ${ref2.path}');
    print(
        'DataAPI._mirrorInvoiceAcceptance SUPPLIER added to Firestore: ${ref.path}');
  }

  static Future<String> makeOffer(Offer offer) async {
    offer.offerId = getKey();
    offer.date = getUTCDate();
    offer.isOpen = true;
    offer.isCancelled = false;

    var supplierId = offer.supplier.split('#').elementAt(1);
    var invoiceId = offer.invoice.split('#').elementAt(1);

    offer.supplierDocumentRef = await _getDocumentId('suppliers', supplierId);

    var qs = await _firestore
        .collection('suppliers')
        .document(offer.supplierDocumentRef)
        .collection('invoices')
        .where('invoiceId', isEqualTo: invoiceId)
        .getDocuments();

    var invoiceDocId = qs.documents.first.documentID;
    offer.invoiceDocumentRef = invoiceDocId;

    print('DataAPI.makeOffer  ${getURL() + 'MakeOffer'}');
    prettyPrint(offer.toJson(), 'DataAPI.makeOffer offer: ');
    try {
      Map map = offer.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + 'MakeOffer'));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('invoiceOffers')
            .add(offer.toJson())
            .catchError((e) {
          print('DataAPI.makeOffer ERROR $e');
          return '0';
        });
        print('DataAPI.makeOffer added to Firestore: ${ref.path}');
        offer.documentReference = ref.documentID;

        await _updateInvoiceWithOffer(qs, offer, invoiceDocId);
        return offer.offerId;
      } else {
        print('DataAPI.makeOffer ERROR - doc deleted from firestore');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeOffer ERROR  $contents');
        });
        print('DataAPI.MakeOffer ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.MakeOffer ERROR $e');
      return '0';
    }
  }

  static Future<String> closeOffer(String offerId) async {
    var map = Map<String, dynamic>();
    map['offerId'] = offerId;

    print('DataAPI.closeOffer ${getURL() + CLOSE_OFFER}');
    try {
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + CLOSE_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.closeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await _closeOfferOnFirestore(offerId);
        return 'we cool';
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.closeOffer  $contents');
        });
        print('DataAPI.closeOffer ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.closeOffer ERROR $e');
      return '0';
    }
  }

  static Future<String> _closeOfferOnFirestore(String offerId) async {
    print('DataAPI.closeOfferOnFirestore - update offer');
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('offerId', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('DataAPI.closeOfferOnFirestore ERROR $e');
      return '0';
    });
    if (qs.documents.isNotEmpty) {
      var m = Offer.fromJson(qs.documents.first.data);
      m.isOpen = false;
      await _firestore
          .collection('invoiceOffers')
          .document(qs.documents.first.documentID)
          .setData(m.toJson())
          .catchError((e) {
        print('DataAPI.closeOfferOnFirestore $e');
        return '0';
      });
      print('DataAPI.closeOfferOnFirestore ########## offers closed');
      return 'cool';
    } else {
      return '0';
    }
  }

  static Future _updateInvoiceWithOffer(
      QuerySnapshot qs, Offer offer, String invoiceDocId) async {
    Invoice inv = new Invoice.fromJson(qs.documents.first.data);
    inv.isOnOffer = true;
    inv.offer = 'resource:com.oneconnect.biz.Offer#' + offer.offerId;
    //update invoice with offer
    await _firestore
        .collection('suppliers')
        .document(offer.supplierDocumentRef)
        .collection('invoices')
        .document(invoiceDocId)
        .updateData(inv.toJson());
    print('DataAPI.makeOffer ******* invoice updated with  offer *****');
    prettyPrint(inv.toJson(), 'updated invoice with  offer on  Firestore');
  }

  static Future<String> makeInvoiceBid(InvoiceBid bid) async {
    bid..invoiceBidId = getKey();
    bid.date = getUTCDate();
    bid.isSettled = false;

    print('DataAPI.makeInvoiceBid ${getURL() + MAKE_INVOICE_BID}');
    try {
      Map map = bid.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + MAKE_INVOICE_BID));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvoiceBid blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        //add bid to investor's collection
        var qs = await _firestore
            .collection('investors')
            .where('participantId',
                isEqualTo: bid.investor.split('#').elementAt(1))
            .getDocuments();

        var ref0 = await _firestore
            .collection('investors')
            .document(qs.documents.first.documentID)
            .collection('invoiceBids')
            .add(bid.toJson())
            .catchError((e) {
          print('DataAPI.makeInvoiceBid ERROR $e');
          return '0';
        });
        print('DataAPI.makeInvoiceBid added to Firestore: ${ref0.path}');
        //add bid to offer collection
        var qs2 = await _firestore
            .collection('invoiceOffers')
            .where('offerId', isEqualTo: bid.offer.split("#").elementAt(1))
            .getDocuments();
        var offer = Offer.fromJson(qs2.documents.first.data);
        offer.documentReference = qs2.documents.first.documentID;
        var ref = await _firestore
            .collection('invoiceOffers')
            .document(qs2.documents.first.documentID)
            .collection('invoiceBids')
            .add(bid.toJson())
            .catchError((e) {
          print('DataAPI.makeInvoiceBid ERROR $e');
          return '0';
        });

        print('DataAPI.makeInvoiceBid added to Firestore: ${ref.path}');

        bid.documentReference = ref.documentID;
        //todo - check all bids for this offer - if partial bids add up to 100% then close the offer
        var list = await ListAPI.getInvoiceBidsByOffer(offer);
        var tot = 0.00;
        list.forEach((m) {
          tot += m.reservePercent;
        });
        if (tot >= 100.0) {
          await closeOffer(offer.offerId);
        }

        return bid.invoiceBidId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeInvoiceBid  $contents');
        });
        print('DataAPI.makeInvoiceBid ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeInvoiceBid ERROR $e');
      return '0';
    }
  }

  static Future<String> makeInvoiceAutoBid(
      {InvoiceBid bid, Offer offer, AutoTradeOrder order}) async {
    assert(offer.documentReference != null);
    assert(order.investor != null);

    bid.invoiceBidId = getKey();
    bid.date = getUTCDate();
    bid.isSettled = false;
    prettyPrint(bid.toJson(), 'makeInvoiceAutoBid, bid, check autoTradeOrder');

    print('DataAPI.makeInvoiceAutoBid ${getURL() + MAKE_INVOICE_BID}');
    try {
      Map map = bid.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + MAKE_INVOICE_BID));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvoiceAutoBid blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await closeOffer(offer.offerId);
        offer.isOpen = false;
        return _mirrorInvoiceAutoBid(offer, bid, order);
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeInvoiceAutoBid  $contents');
        });
        print('DataAPI.makeInvoiceAutoBid ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeInvoiceAutoBid ERROR $e');
      return '0';
    }
  }

  static Future<String> _mirrorInvoiceAutoBid(
      Offer offer, InvoiceBid bid, AutoTradeOrder order) async {
    //get investor
    var qs = await _firestore
        .collection('investors')
        .where('participantId',
            isEqualTo: order.investor.split('#').elementAt(1))
        .getDocuments()
        .catchError((e) {
      print('DataAPI._mirrorInvoiceBid ERROR $e');
      return '0';
    });
    if (qs.documents.isNotEmpty) {
      //add bid to investor's collection
      var ref0 = await _firestore
          .collection('investors')
          .document(qs.documents.first.documentID)
          .collection('invoiceBids')
          .add(bid.toJson())
          .catchError((e) {
        print('DataAPI._mirrorInvoiceBid ERROR $e');
        return '0';
      });
      print('DataAPI._mirrorInvoiceBid added to Firestore: ${ref0.path}');
      //add bid to offer collection
      var ref = await _firestore
          .collection('invoiceOffers')
          .document(offer.documentReference)
          .collection('invoiceBids')
          .add(bid.toJson())
          .catchError((e) {
        print('DataAPI._mirrorInvoiceBid ERROR $e');
        return '0';
      });
      print('DataAPI._mirrorInvoiceBid added to Firestore: ${ref.path}');
      bid.documentReference = ref.documentID;
    }
    return 'allOK';
  }

  static Future<String> selectInvoiceBid(InvoiceBid bid) async {
    //TODO - supplier selects the bid
    return null;
  }

  static Future<String> makeInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = getUTCDate();

    var investorId = settlement.investor.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('investors', investorId);

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);

    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + MAKE_INVESTOR_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvestorInvoiceSettlement blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('investors')
            .document(investorDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeInvestorInvoiceSettlement added to Firestore: ${ref.path}');
        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeInvestorInvoiceSettlement added to Firestore: ${ref2.path}');
        return settlement.invoiceSettlementId;
      } else {
        print(
            'DataAPI.makeInvestorInvoiceSettlement ERROR - doc deleted from firestore');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeInvestorInvoiceSettlement ERROR  $contents');
        });
        print(
            'DataAPI.makeInvestorInvoiceSettlement ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
      return '0';
    }
  }

  static Future<String> makeCompanyInvoiceSettlement(
      CompanyInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = getUTCDate();

    var investorId = settlement.company.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('companies', investorId);

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);

    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + MAKE_COMPANY_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeCompanyInvoiceSettlement blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('companies')
            .document(investorDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeCompanyInvoiceSettlement added to Firestore: ${ref.path}');
        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeCompanyInvoiceSettlement added to Firestore: ${ref2.path}');
        return settlement.invoiceSettlementId;
      } else {
        print(
            'DataAPI.makeCompanyInvoiceSettlement ERROR - doc deleted from firestore');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeCompanyInvoiceSettlement ERROR  $contents');
        });
        print(
            'DataAPI.makeCompanyInvoiceSettlement ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    }
  }

  static Future<String> makeGovtInvoiceSettlement(
      GovtInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = getUTCDate();

    var investorId = settlement.govtEntity.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('govtEntities', investorId);

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);

    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + MAKE_GOVT_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeGovtInvoiceSettlement blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('govtEntities')
            .document(investorDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeGovtInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeGovtInvoiceSettlement added to Firestore: ${ref.path}');
        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocId)
            .collection('invoiceSettlements')
            .add(settlement.toJson())
            .catchError((e) {
          print('DataAPI.makeGovtInvoiceSettlement ERROR $e');
          return '0';
        });
        print(
            'DataAPI.makeGovtInvoiceSettlement added to Firestore: ${ref2.path}');
        return settlement.invoiceSettlementId;
      } else {
        print(
            'DataAPI.makeGovtInvoiceSettlement ERROR - doc deleted from firestore');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeGovtInvoiceSettlement ERROR  $contents');
        });
        print(
            'DataAPI.makeGovtInvoiceSettlement ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeGovtInvoiceSettlement ERROR $e');
      return '0';
    }
  }

  static Future<String> updatePurchaseOrderContract(
      PurchaseOrder po, String contractURL) async {
    print(
        'DataAPI.updatePurchaseOrderContract ${getURL() + UPDATE_PURCHASE_ORDER_CONTRACT}');
    try {
      Map<String, String> map = Map<String, String>();
      map['contractURL'] = contractURL;
      map['purchaseOrder'] =
          'resource:com.oneconnect.biz.PurchaseOrder#${po.purchaseOrderId}';
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest = await httpClient
          .postUrl(Uri.parse(getURL() + UPDATE_PURCHASE_ORDER_CONTRACT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvoiceBid blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return await updatePO(po, contractURL);
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeInvoiceBid  $contents');
        });
        print('DataAPI.makeInvoiceBid ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeInvoiceBid ERROR $e');
      return '0';
    }
  }

  static Future updatePO(PurchaseOrder po, String contractURL) async {
    var qs = await _firestore
        .collection('investors')
        .document(po.supplierDocumentRef)
        .collection('purchaseOrders')
        .where('purchaseOrderId', isEqualTo: po.purchaseOrderId)
        .getDocuments();
    if (qs.documents.isNotEmpty) {
      var docID = qs.documents.first.documentID;
      var doc = qs.documents.first.data;
      var xx = PurchaseOrder.fromJson(doc);
      xx.contractURL = contractURL;
      await _firestore
          .collection('investors')
          .document(po.supplierDocumentRef)
          .collection('purchaseOrders')
          .document(docID)
          .setData(xx.toJson())
          .catchError((e) {
        print('DataAPI.updatePurchaseOrderContract: $e ');
        return '0';
      });
    }
    return 'poUpdated';
  }

  static Future<String> cancelOffer(OfferCancellation cancellation) async {
    cancellation.cancellationId = getKey();
    cancellation.date = getUTCDate();
    print('DataAPI.cancelOffer ${getURL() + CANCEL_OFFER}');
    try {
      Map map = cancellation.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getURL() + CANCEL_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.cancelOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref0 = await _firestore
            .collection('offersCancelled')
            .add(cancellation.toJson())
            .catchError((e) {
          print('DataAPI.cancelOffer ERROR $e');
          return '0';
        });
        print('DataAPI.cancelOffer added to Firestore: ${ref0.path}');
        var qs = await _firestore
            .collection('invoiceOffers')
            .where('offerId',
                isEqualTo: cancellation.offer.split('#').elementAt(1))
            .getDocuments();
        if (qs.documents.isNotEmpty) {
          var offer = Offer.fromJson(qs.documents.first.data);
          offer.isCancelled = true;
          offer.isOpen = false;
          offer.offerCancellation =
              'resource:com.oneconnect.biz.OfferCancellation#${cancellation.cancellationId}';
          await _firestore
              .collection('invoiceOffers')
              .document(qs.documents.first.documentID)
              .setData(offer.toJson())
              .catchError((e) {
            print('DataAPI.cancelOffer invoiceOffers ERROR $e');
          });
          print('DataAPI.cancelOffer - invoiceOffers updated on Firestore');
          assert(offer.supplierDocumentRef != null);
          assert(offer.invoice != null);
          var qs2 = await _firestore
              .collection('suppliers')
              .document(offer.supplierDocumentRef)
              .collection('invoices')
              .where('invoiceId',
                  isEqualTo: offer.invoice.split('#').elementAt(1))
              .getDocuments()
              .catchError((e) {
            print('DataAPI.cancelOffer get suppliers/invoices ERROR $e');
          });
          if (qs2.documents.isNotEmpty) {
            var inv = Invoice.fromJson(qs2.documents.first.data);
            inv.isOnOffer = false;
            inv.offer = null;
            var id = qs2.documents.first.documentID;
            await _firestore
                .collection('suppliers')
                .document(offer.supplierDocumentRef)
                .collection('invoices')
                .document(id)
                .setData(inv.toJson())
                .catchError((e) {
              print('DataAPI.cancelOffer suppliers setData ERROR $e');
            });
            print(
                'DataAPI.cancelOffer ---- invoice updated, no longer on offer');
          }
        }
        return cancellation.cancellationId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.cancelOffer ===  $contents');
        });
        print('DataAPI.cancelOffer ERROR ==== ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.cancelOffer wtf ERROR $e');
      return '0';
    }
  }

  static String getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('DataAPI.getKey !!!!!!!!!!! - key generated: $key');
    return key;
  }
}
