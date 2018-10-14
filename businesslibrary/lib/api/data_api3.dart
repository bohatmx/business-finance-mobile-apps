import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/api_bag.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DataAPI3 {
  static HttpClient _httpClient = new HttpClient();
  static ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");
  static String url =
      'https://us-central1-business-finance-dev.cloudfunctions.net/';
  static const ADD_DATA = 'addData',
      EXECUTE_AUTO_TRADES = 'executeAutoTrade',
      REGISTER_PURCHASE_ORDER = 'registerPurchaseOrder',
      REGISTER_INVOICE = 'registerInvoice',
      REGISTER_DELIVERY_NOTE = 'registerDeliveryNote',
      ACCEPT_DELIVERY_NOTE = 'acceptDeliveryNote',
      MAKE_OFFER = 'makeOffer',
      CLOSE_OFFER = 'closeOffer',
      MAKE_INVOICE_BID = 'makeInvoiceBid',
      ACCEPT_INVOICE = 'acceptInvoice';
  static const Success = 0,
      BlockchainError = 2,
      FirestoreError = 3,
      UnknownError = 4;
  static Firestore fs = Firestore.instance;
  static Future<int> registerPurchaseOrder(PurchaseOrder purchaseOrder) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.registerPurchaseOrder(purchaseOrder);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    purchaseOrder.purchaseOrderId = getKey();
    purchaseOrder.date = getUTCDate();
    var bag = APIBag(
      debug: isInDebugMode,
      data: purchaseOrder.toJson(),
    );

    print(
        'DataAPI3.registerPurchaseOrder url: ${url + REGISTER_PURCHASE_ORDER}');
    prettyPrint(bag.toJson(), 'DataAPI3.registerPurchaseOrder  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_PURCHASE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.registerPurchaseOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print(
            'DataAPI3.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.registerPurchaseOrder  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.registerPurchaseOrder ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> registerDeliveryNote(DeliveryNote deliveryNote) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.registerDeliveryNote(deliveryNote);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    deliveryNote.deliveryNoteId = getKey();
    deliveryNote.date = getUTCDate();
    var bag = APIBag(
      debug: isInDebugMode,
      data: deliveryNote.toJson(),
    );

    prettyPrint(deliveryNote.toJson(), 'registerDeliveryNote ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_DELIVERY_NOTE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.registerDeliveryNote blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print('DataAPI3.registerDeliveryNote ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.registerDeliveryNote  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.registerDeliveryNote ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> acceptDelivery(DeliveryAcceptance acceptance) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.acceptDelivery(acceptance);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    acceptance.acceptanceId = getKey();
    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );

    print('\n\nDataAPI3.acceptDelivery url: ${url + ACCEPT_DELIVERY_NOTE}');
    prettyPrint(bag.toJson(), 'DataAPI3.acceptDelivery ... calling BFN ...');
    try {
      Map map = bag.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ACCEPT_DELIVERY_NOTE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.acceptDelivery blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.acceptDelivery ERROR  $contents');
        });
        print('DataAPI3.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.acceptDelivery ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    invoice.isOnOffer = false;
    invoice.isSettled = false;
    invoice.date = getUTCDate();
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.registerInvoice(invoice);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }

    var bag = APIBag(
      debug: isInDebugMode,
      data: invoice.toJson(),
    );

    print('DataAPI3.registerInvoice url: ${url + REGISTER_INVOICE}');
    prettyPrint(invoice.toJson(),
        'DataAPI3.registerInvoice .. calling BFN via http(s) ...');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.registerInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print('DataAPI3.registerInvoice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.registerInvoice  $contents');
        });
        print('DataAPI3.registerInvoice Firestore invoice deleted');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.registerInvoice ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> acceptInvoice(InvoiceAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.acceptInvoice(acceptance);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );
    print('DataAPI3.acceptInvoice url: ${url + ACCEPT_INVOICE}');
    prettyPrint(bag.toJson(), 'DataAPI3.acceptInvoice ... calling BFN ...');
    try {
      Map map = bag.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ACCEPT_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.acceptInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.acceptInvoice ERROR  $contents');
        });
        print('DataAPI3.acceptInvoice ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.acceptInvoice ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> makeOffer(Offer offer) async {
    offer.offerId = getKey();
    offer.date = getUTCDate();
    offer.isOpen = true;
    offer.isCancelled = false;
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.makeOffer(offer);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    var bag = APIBag(
      debug: isInDebugMode,
      data: offer.toJson(),
    );
    print('DataAPI3.makeOffer  ${url + MAKE_OFFER}');
    prettyPrint(bag.toJson(), 'DataAPI3.makeOffer offer....................: ');
    try {
      Map map = bag.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.makeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.makeOffer ERROR  $contents');
        });
        print('DataAPI3.MakeOffer ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.MakeOffer ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> closeOffer(String offerId) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.closeOffer(offerId);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    var map = Map<String, dynamic>();
    map['debug'] = isInDebugMode;
    map['offerId'] = offerId;

    print('DataAPI3.closeOffer ${url + CLOSE_OFFER}');
    try {
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + CLOSE_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.closeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.closeOffer  $contents');
        });
        print('DataAPI3.closeOffer ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.closeOffer ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> makeInvoiceBid(InvoiceBid bid) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.makeInvoiceBid(bid);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    bid..invoiceBidId = getKey();
    bid.date = getUTCDate();
    bid.isSettled = false;
    var bag = APIBag(
      debug: isInDebugMode,
      data: bid.toJson(),
    );
    print('DataAPI3.makeInvoiceBid ${url + MAKE_INVOICE_BID}');
    try {
      Map map = bag.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_INVOICE_BID));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.makeInvoiceBid blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        if (bid.autoTradeOrder != null) {
          await closeOffer(bid.offer.split('#').elementAt(1));
        }
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.makeInvoiceBid  $contents');
        });
        print('DataAPI3.makeInvoiceBid ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.makeInvoiceBid ERROR $e');
      return UnknownError;
    }
  }

  //////////// ###################################### //////////
  static Future<int> addGovtEntity(GovtEntity govtEntity, User user) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addGovtEntity(govtEntity, user);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    print(
        'DataAPI3.addGovtEntity ==============>>>> ........... ${govtEntity.toJson()}');
    print('DataAPI3.addGovtEntity ))))))) URL: $url$ADD_DATA');
    govtEntity.participantId = getKey();
    govtEntity.dateRegistered = getUTCDate();
    user.govtEntity =
        'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: govtEntity.toJson(),
        user: user.toJson(),
        sourceSeed: seed,
        apiSuffix: 'GovtEntity',
        collectionName: 'govtEntities');
    try {
      HttpClientRequest mRequest =
          await _httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));

      HttpClientResponse resp = await mRequest.close();
      print('\n\n\nDataAPI3.addGovtEntity ########## -----------------------> '
          'resp.statusCode: ${resp.statusCode} }\n\n');

      if (resp.statusCode == 200) {
        resp.transform(utf8.decoder).listen((contents) {
          govtEntity.documentReference = contents.split('/').elementAt(1);
          print(
              'DataAPI3.addGovtEntity ****************** contents: $contents');

          SharedPrefs.saveGovtEntity(govtEntity);
        });
        var qs = await fs
            .collection('wallets')
            .where('govtEntity',
                isEqualTo:
                    'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}')
            .getDocuments();
        if (qs.documents.isNotEmpty) {
          var wallet = Wallet.fromJson(qs.documents.first.data);
          wallet.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveWallet(wallet);
        }
        var qs2 = await fs
            .collection('users')
            .where('govtEntity',
                isEqualTo:
                    'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}')
            .getDocuments();
        if (qs2.documents.isNotEmpty) {
          var user = User.fromJson(qs.documents.first.data);
          user.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveUser(user);
        }
        return Success;
      } else {
        print('DataAPI3.addGovtEntity ERROR  ${resp.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addGovtEntity ERROR $e');
      return UnknownError;
    }
  }

  static Future<String> executeAutoTrades() async {
    print('DataAPI3.executeAutoTrades url: ${url + EXECUTE_AUTO_TRADES}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + EXECUTE_AUTO_TRADES));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode({'debug': isInDebugMode}));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.executeAutoTrades ######## blockchain response status code:  ${mResponse.statusCode}');
      mResponse.transform(utf8.decoder).listen((contents) {
        print('DataAPI3.executeAutoTrades;  $contents');
      });
      if (mResponse.statusCode == 200) {
        return 'Auto Trade Session complete';
      } else {
        return '0';
      }
    } catch (e) {
      print('DataAPI3.executeAutoTrades ERROR $e');
      return '0';
    }
  }

  static Future<int> addSectors() async {
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
    return DataAPI3.Success;
  }

  static Future<int> addSector(Sector sector) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addSector(sector);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    sector.sectorId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: sector.toJson(),
        apiSuffix: 'Sector',
        collectionName: 'sectors');
    print('DataAPI3.addSector %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(bag.toJson(), 'adding sector to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addSector blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addSector  $contents');
        });
        print('DataAPI3.addSector ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addSector ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addAutoTradeOrder(AutoTradeOrder order) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addAutoTradeOrder(order);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    order.autoTradeOrderId = getKey();
    order.date = getUTCDate();
    order.isCancelled = false;
    var bag = APIBag(
        debug: isInDebugMode,
        data: order.toJson(),
        apiSuffix: 'AutoTradeOrder',
        collectionName: 'autoTradeOrders');
    print('DataAPI3.addAutoTradeOrder %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(bag.toJson(),
        '########################## adding addAutoTradeOrder to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addAutoTradeOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await SharedPrefs.saveAutoTradeOrder(order);
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addAutoTradeOrder  $contents');
        });
        print('DataAPI3.addAutoTradeOrder ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addAutoTradeOrder ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addInvestorProfile(InvestorProfile profile) async {
    profile.profileId = getKey();
    profile.date = getUTCDate();
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addInvestorProfile(profile);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: profile.toJson(),
        apiSuffix: 'InvestorProfile',
        collectionName: 'investorProfiles');
    print('DataAPI3.addInvestorProfile %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(profile.toJson(),
        '########################## adding addInvestorProfile to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addInvestorProfile blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await SharedPrefs.saveInvestorProfile(profile);
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addInvestorProfile  $contents');
        });
        print('DataAPI3.addInvestorProfile ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addInvestorProfile ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addWallet(Wallet wallet) async {
    print('DataAPI3.addWallet %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(wallet.toJson(), 'adding wallet to BFN blockcahain');
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addWallet(wallet);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }

//    wallet.encryptedSecret = null;
    wallet.debug = null;
    wallet.sourceSeed = null;
    wallet.secret = null;
    wallet.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: wallet.toJson(),
        apiSuffix: 'Wallet',
        collectionName: 'wallets');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addWallet blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addWallet  $contents');
        });
        print('DataAPI3.addWallet ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addWallet ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addSupplier(Supplier supplier, User user) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addSupplier(supplier, user);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    supplier.dateRegistered = getUTCDate();
    supplier.participantId = getKey();
    user.supplier =
        'resource:com.oneconnect.biz.Supplier#${supplier.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: supplier.toJson(),
        user: user.toJson(),
        sourceSeed: seed,
        apiSuffix: 'Supplier',
        collectionName: 'suppliers');
    print('DataAPI3.addSupplier url: ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addSupplier blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          supplier.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addSupplier ****************** contents: $contents');
          SharedPrefs.saveSupplier(supplier);
        });
        var qs = await fs
            .collection('wallets')
            .where('supplier',
                isEqualTo:
                    'resource:com.oneconnect.biz.Supplier#${supplier.participantId}')
            .getDocuments();
        if (qs.documents.isNotEmpty) {
          var wallet = Wallet.fromJson(qs.documents.first.data);
          wallet.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveWallet(wallet);
        }
        var qs2 = await fs
            .collection('users')
            .where('supplier',
                isEqualTo:
                    'resource:com.oneconnect.biz.Supplier#${supplier.participantId}')
            .getDocuments();
        if (qs2.documents.isNotEmpty) {
          var user = User.fromJson(qs.documents.first.data);
          user.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveUser(user);
        }
        return Success;
      } else {
        print('DataAPI3.addSupplier ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addSupplier  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addSupplier ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addBank(Bank bank) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addBank(bank);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    bank.dateRegistered = getUTCDate();
    bank.participantId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: bank.toJson(),
        apiSuffix: 'Bank',
        collectionName: 'banks');
    print('DataAPI3.addBank   ${url + ADD_DATA}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addBank blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          bank.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addBank ****************** contents: $contents');
        });
        await SharedPrefs.saveBank(bank);
        return Success;
      } else {
        print('DataAPI3.addBank ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addBank  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addBank ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addInvestor(Investor investor, User user) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addInvestor(investor, user);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    investor.dateRegistered = getUTCDate();
    investor.participantId = getKey();
    user.investor =
        'resource:com.oneconnect.biz.Investor#${investor.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: investor.toJson(),
        user: user.toJson(),
        sourceSeed: seed,
        apiSuffix: 'Investor',
        collectionName: 'investors');
    print('DataAPI3.addInvestor   ${url + ADD_DATA}');
    prettyPrint(bag.toJson(), 'DataAPI3.addInvestor : ');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addInvestor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          investor.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addInvestor ****************** contents: $contents');
          SharedPrefs.saveInvestor(investor);
        });
        var qs = await fs
            .collection('wallets')
            .where('investor',
                isEqualTo:
                    'resource:com.oneconnect.biz.Investor#${investor.participantId}')
            .getDocuments();
        if (qs.documents.isNotEmpty) {
          var wallet = Wallet.fromJson(qs.documents.first.data);
          wallet.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveWallet(wallet);
        }
        var qs2 = await fs
            .collection('users')
            .where('investor',
                isEqualTo:
                    'resource:com.oneconnect.biz.Investor#${investor.participantId}')
            .getDocuments();
        if (qs2.documents.isNotEmpty) {
          var user = User.fromJson(qs.documents.first.data);
          user.documentReference = qs.documents.first.documentID;
          await SharedPrefs.saveUser(user);
        }
        return Success;
      } else {
        print('DataAPI3.addInvestor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addInvestor  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addInvestor ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addOneConnect(OneConnect oneConnect) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addOneConnect(oneConnect);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    oneConnect.participantId = getKey();
    oneConnect.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: oneConnect.toJson(),
        apiSuffix: 'OneConnect',
        collectionName: 'oneConnect');
    print('DataAPI3.addOneConnect ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addOneConnect blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          oneConnect.documentReference = contents.split('/').elementAt(1);
          print(
              'DataAPI3.addOneConnect ****************** contents: $contents');
        });
        await SharedPrefs.saveOneConnect(oneConnect);
        return Success;
      } else {
        print('DataAPI3.addOneConnect ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addOneConnect  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addOneConnect ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addProcurementOffice(ProcurementOffice office) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addProcurementOffice(office);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    office.participantId = getKey();
    office.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: office.toJson(),
        apiSuffix: 'ProcurementOffice',
        collectionName: 'procurementOffices');
    print('DataAPI3.addProcurementOffice ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addProcurementOffice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          office.documentReference = contents.split('/').elementAt(1);
          print(
              'DataAPI3.addProcurementOffice ****************** contents: $contents');
        });
        await SharedPrefs.saveProcurementOffice(office);
        return Success;
      } else {
        print('DataAPI3.addProcurementOffice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addProcurementOffice  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addProcurementOffice ERROR $e');
      return UnknownError;
    }
  }

  static Future<int> addAuditor(Auditor auditor) async {
    if (USE_LOCAL_BLOCKCHAIN) {
      var res = await DataAPI.addAuditor(auditor);
      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
    }
    auditor.participantId = getKey();
    auditor.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: auditor.toJson(),
        apiSuffix: 'Auditor',
        collectionName: 'auditors');
    print('DataAPI3.addAuditor ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI3.addAuditor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          auditor.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addAuditor ****************** contents: $contents');
        });
        await SharedPrefs.saveAuditor(auditor);
        return Success;
      } else {
        print('DataAPI3.addAuditor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.addAuditor  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addAuditor ERROR $e');
      return UnknownError;
    }
  }

  static String getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    return key;
  }
}
