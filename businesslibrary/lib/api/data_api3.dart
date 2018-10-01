import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/api_bag.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
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
import 'package:uuid/uuid.dart';

class DataAPI3 {
  HttpClient _httpClient = new HttpClient();
  ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");
  String url = 'https://us-central1-business-finance-dev.cloudfunctions.net/';
  static const ADD_DATA = 'addData',
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
  Future<int> registerPurchaseOrder(PurchaseOrder purchaseOrder) async {
    purchaseOrder.purchaseOrderId = getKey();
    var bag = APIBag(
      debug: isInDebugMode,
      data: purchaseOrder.toJson(),
    );

    print(
        'DataAPI.registerPurchaseOrder url: ${url + REGISTER_PURCHASE_ORDER}');
    prettyPrint(bag.toJson(), 'DataAPI.registerPurchaseOrder  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_PURCHASE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerPurchaseOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print('DataAPI.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerPurchaseOrder  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return UnknownError;
    }
  }

  Future<int> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();
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
          'DataAPI.registerDeliveryNote blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print('DataAPI.registerDeliveryNote ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerDeliveryNote  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.registerDeliveryNote ERROR $e');
      return UnknownError;
    }
  }

  Future<int> acceptDelivery(DeliveryAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );

    print('\n\nDataAPI.acceptDelivery url: ${url + ACCEPT_DELIVERY_NOTE}');
    prettyPrint(bag.toJson(), 'DataAPI.acceptDelivery ... calling BFN ...');
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
          'DataAPI.acceptDelivery blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.acceptDelivery ERROR  $contents');
        });
        print('DataAPI.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.acceptDelivery ERROR $e');
      return UnknownError;
    }
  }

  Future<int> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    invoice.isOnOffer = false;
    invoice.isSettled = false;

    var bag = APIBag(
      debug: isInDebugMode,
      data: invoice.toJson(),
    );

    print('DataAPI.registerInvoice url: ${url + REGISTER_INVOICE}');
    prettyPrint(invoice.toJson(),
        'DataAPI.registerInvoice .. calling BFN via http(s) ...');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        print('DataAPI.registerInvoice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.registerInvoice  $contents');
        });
        print('DataAPI.registerInvoice Firestore invoice deleted');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.registerInvoice ERROR $e');
      return UnknownError;
    }
  }

  Future<int> acceptInvoice(InvoiceAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();

    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );
    print('DataAPI.acceptInvoice url: ${url + ACCEPT_INVOICE}');
    prettyPrint(bag.toJson(), 'DataAPI.acceptInvoice ... calling BFN ...');
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
          'DataAPI.acceptInvoice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.acceptInvoice ERROR  $contents');
        });
        print('DataAPI.acceptInvoice ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.acceptInvoice ERROR $e');
      return UnknownError;
    }
  }

  Future<int> makeOffer(Offer offer) async {
    offer.offerId = getKey();
    offer.date = getUTCDate();
    offer.isOpen = true;
    offer.isCancelled = false;
    var bag = APIBag(
      debug: isInDebugMode,
      data: offer.toJson(),
    );
    print('DataAPI.makeOffer  ${url + MAKE_OFFER}');
    prettyPrint(bag.toJson(), 'DataAPI.makeOffer offer....................: ');
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
          'DataAPI.makeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeOffer ERROR  $contents');
        });
        print('DataAPI.MakeOffer ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.MakeOffer ERROR $e');
      return UnknownError;
    }
  }

  Future<int> closeOffer(String offerId) async {
    var map = Map<String, dynamic>();
    map['debug'] = isInDebugMode;
    map['offerId'] = offerId;

    print('DataAPI.closeOffer ${url + CLOSE_OFFER}');
    try {
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + CLOSE_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.closeOffer blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.closeOffer  $contents');
        });
        print('DataAPI.closeOffer ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.closeOffer ERROR $e');
      return UnknownError;
    }
  }

  Future<int> makeInvoiceBid(InvoiceBid bid) async {
    bid..invoiceBidId = getKey();
    bid.date = getUTCDate();
    bid.isSettled = false;
    var bag = APIBag(
      debug: isInDebugMode,
      data: bid.toJson(),
    );
    print('DataAPI.makeInvoiceBid ${url + MAKE_INVOICE_BID}');
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
          'DataAPI.makeInvoiceBid blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        if (bid.autoTradeOrder != null) {
          await closeOffer(bid.offer.split('#').elementAt(1));
        }
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeInvoiceBid  $contents');
        });
        print('DataAPI.makeInvoiceBid ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.makeInvoiceBid ERROR $e');
      return UnknownError;
    }
  }

  //////////// ###################################### //////////
  Future<int> addGovtEntity(GovtEntity govtEntity) async {
    print(
        'DataAPI3.addGovtEntity ==============>>>> ........... ${govtEntity.toJson()}');
    print('DataAPI3.addGovtEntity ))))))) URL: $url$ADD_DATA');
    govtEntity.participantId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: govtEntity.toJson(),
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
        });

        await SharedPrefs.saveGovtEntity(govtEntity);
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

  Future<int> addUser(User user) async {
    user.userId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: user.toJson(),
        apiSuffix: 'User',
        collectionName: 'users');
    print('DataAPI.addUser url: ${url + ADD_DATA}');
    prettyPrint(bag.toJson(), 'DataAPI.addUser, bag: ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addUser ######## blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          user.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addUser ****************** contents: $contents');
        });
        await SharedPrefs.saveUser(user);
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addUser  $contents');
        });
        print(
            'DataAPI.addUser ----- ERROR  ${mResponse.reasonPhrase} ${mResponse.headers}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addUser ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addSectors() async {
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
  }

  Future<int> addSector(Sector sector) async {
    sector.sectorId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: sector.toJson(),
        apiSuffix: 'Sector',
        collectionName: 'sectors');
    print('DataAPI.addSector %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(bag.toJson(), 'adding sector to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSector blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSector  $contents');
        });
        print('DataAPI.addSector ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addSector ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addAutoTradeOrder(AutoTradeOrder order) async {
    order.autoTradeOrderId = getKey();
    order.date = getUTCDate();
    order.isCancelled = false;
    var bag = APIBag(
        debug: isInDebugMode,
        data: order.toJson(),
        apiSuffix: 'AutoTradeOrder',
        collectionName: 'autoTradeOrders');
    print('DataAPI.addAutoTradeOrder %%%%%%%% url: ${url + ADD_DATA}');
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
          'DataAPI.addAutoTradeOrder blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await SharedPrefs.saveAutoTradeOrder(order);
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addAutoTradeOrder  $contents');
        });
        print('DataAPI.addAutoTradeOrder ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addAutoTradeOrder ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addInvestorProfile(InvestorProfile profile) async {
    profile.profileId = getKey();
    profile.date = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: profile.toJson(),
        apiSuffix: 'InvestorProfile',
        collectionName: 'investorProfiles');
    print('DataAPI.addInvestorProfile %%%%%%%% url: ${url + ADD_DATA}');
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
          'DataAPI.addInvestorProfile blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        await SharedPrefs.saveInvestorProfile(profile);
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addInvestorProfile  $contents');
        });
        print('DataAPI.addInvestorProfile ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addInvestorProfile ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addWallet(Wallet wallet) async {
    print('DataAPI.addWallet %%%%%%%% url: ${url + ADD_DATA}');
    prettyPrint(wallet.toJson(), 'adding wallet to BFN blockcahain');

//    wallet.encryptedSecret = null;
    wallet.debug = null;
    wallet.sourceSeed = null;
    wallet.secret = null;
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
          'DataAPI.addWallet blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return Success;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addWallet  $contents');
        });
        print('DataAPI.addWallet ERROR  ${mResponse.reasonPhrase}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addWallet ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addSupplier(Supplier supplier) async {
    supplier.participantId = getKey();
    var bag = APIBag(
        debug: isInDebugMode,
        data: supplier.toJson(),
        apiSuffix: 'Supplier',
        collectionName: 'suppliers');
    print('DataAPI.addSupplier url: ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSupplier blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          supplier.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addSupplier ****************** contents: $contents');
        });
        await SharedPrefs.saveSupplier(supplier);
        return Success;
      } else {
        print('DataAPI.addSupplier ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSupplier  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addSupplier ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addInvestor(Investor investor) async {
    investor.participantId = getKey();
    investor.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: investor.toJson(),
        apiSuffix: 'Investor',
        collectionName: 'investors');
    print('DataAPI.addInvestor   ${url + ADD_DATA}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addInvestor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          investor.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addInvestor ****************** contents: $contents');
        });
        await SharedPrefs.saveInvestor(investor);
        return Success;
      } else {
        print('DataAPI.addInvestor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addInvestor  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addInvestor ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = getKey();
    oneConnect.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: oneConnect.toJson(),
        apiSuffix: 'OneConnect',
        collectionName: 'oneConnect');
    print('DataAPI.addOneConnect ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addOneConnect blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          oneConnect.documentReference = contents.split('/').elementAt(1);
          print(
              'DataAPI3.addOneConnect ****************** contents: $contents');
        });
        await SharedPrefs.saveOneConnect(oneConnect);
        return Success;
      } else {
        print('DataAPI.addOneConnect ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addOneConnect  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addOneConnect ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addProcurementOffice(ProcurementOffice office) async {
    office.participantId = getKey();
    office.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: office.toJson(),
        apiSuffix: 'ProcurementOffice',
        collectionName: 'procurementOffices');
    print('DataAPI.addProcurementOffice ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addProcurementOffice blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          office.documentReference = contents.split('/').elementAt(1);
          print(
              'DataAPI3.addProcurementOffice ****************** contents: $contents');
        });
        await SharedPrefs.saveProcurementOffice(office);
        return Success;
      } else {
        print('DataAPI.addProcurementOffice ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addProcurementOffice  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addProcurementOffice ERROR $e');
      return UnknownError;
    }
  }

  Future<int> addAuditor(Auditor auditor) async {
    auditor.participantId = getKey();
    auditor.dateRegistered = getUTCDate();
    var bag = APIBag(
        debug: isInDebugMode,
        data: auditor.toJson(),
        apiSuffix: 'Auditor',
        collectionName: 'auditors');
    print('DataAPI.addAuditor ${url + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ADD_DATA));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addAuditor blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        mResponse.transform(utf8.decoder).listen((contents) {
          auditor.documentReference = contents.split('/').elementAt(1);
          print('DataAPI3.addAuditor ****************** contents: $contents');
        });
        await SharedPrefs.saveAuditor(auditor);
        return Success;
      } else {
        print('DataAPI.addAuditor ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addAuditor  $contents');
        });
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI.addAuditor ERROR $e');
      return UnknownError;
    }
  }

  static String getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('DataAPI.getKey !!!!!!!!!!! - key generated: $key');
    return key;
  }
}
