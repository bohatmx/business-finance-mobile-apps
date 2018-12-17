import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/api_bag.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_bid_keys.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
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
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DataAPI3 {
  static ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");

  static const ADD_DATA = 'addData',
      ADD_PARTICIPANT = 'addParticipant',
      EXECUTE_AUTO_TRADES = 'executeAutoTrade',
      REGISTER_PURCHASE_ORDER = 'registerPurchaseOrder',
      REGISTER_INVOICE = 'registerInvoice',
      REGISTER_DELIVERY_NOTE = 'registerDeliveryNote',
      ACCEPT_DELIVERY_NOTE = 'acceptDeliveryNote',
      MAKE_OFFER = 'makeOffer',
      UPDATE_OFFER = 'updateOffer',
      CLOSE_OFFER = 'closeOffer',
      ADD_CHAT_RESPONSE = 'addChatResponse',
      ADD_CHAT_MESSAGE = 'addChatMessage',
      MAKE_INVOICE_BID = 'makeInvoiceBid',
      MAKE_INVESTOR_INVOICE_SETTLEMENT = 'makeInvestorInvoiceSettlement',
      ACCEPT_INVOICE = 'acceptInvoice';
  static const Success = 0,
      InvoiceRegistered = 6,
      InvoiceRegisteredAccepted = 7,
      BlockchainError = 2,
      FirestoreError = 3,
      UnknownError = 4;
  static Firestore fs = Firestore.instance;

  static Future<String> writeMultiKeys(List<InvoiceBid> bids) async {
    InvoiceBidKeys bidKeys = InvoiceBidKeys(
        date: DateTime.now().toIso8601String(),
        investorDocRef: bids.first.investorDocRef,
        keys: List(),
        investorName: bids.first.investorName);

    bids.forEach((b) {
     bidKeys.addKey(b.documentReference);
    });
    prettyPrint(bidKeys.toJson(), '\n########## InvoiceBidKeys to write');

    try {
      var ref = await fs.collection('invoiceBidSettlementBatches').add(bidKeys.toJson());
      return ref.path.split('/').elementAt(1);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<PurchaseOrder> registerPurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    purchaseOrder.purchaseOrderId = getKey();
    purchaseOrder.date = getUTCDate();
    var bag = APIBag(
      debug: isInDebugMode,
      data: purchaseOrder.toJson(),
    );

    print(
        'DataAPI3.registerPurchaseOrder getFunctionsURL(): ${getFunctionsURL() + REGISTER_PURCHASE_ORDER}\n\n');
    try {
      var mResponse =
          await _callCloudFunction(getFunctionsURL() + REGISTER_PURCHASE_ORDER, bag);
      if (mResponse.statusCode == 200) {
        var map = json.decode(mResponse.body);
        var po = PurchaseOrder.fromJson(map);
        return po;
      } else {
        print(
            '\n\nDataAPI3.registerPurchaseOrder .... we have a problem\n\n\n');
        throw Exception('registerPurchaseOrder failed!: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.registerPurchaseOrder ERROR $e');
      throw e;
    }
  }

  static Future<ChatMessage> addChatMessage(
      ChatMessage chatMessage) async {
    var bag = APIBag(
      debug: isInDebugMode,
      data: chatMessage.toJson(),
    );

    print(
        'DataAPI3.addChatMessage getFunctionsURL(): ${getFunctionsURL() + ADD_CHAT_MESSAGE}\n\n');
    try {
      var mResponse =
      await _callCloudFunction(getFunctionsURL() + ADD_CHAT_MESSAGE, bag);
      if (mResponse.statusCode == 200) {
        var map = json.decode(mResponse.body);
        var po = ChatMessage.fromJson(map);
        return po;
      } else {
        print(
            '\n\nDataAPI3.addChatMessage .... we have a problem\n\n\n');
        throw Exception('addChatMessage failed!: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.addChatMessage ERROR $e');
      throw e;
    }
  }
  static Future<ChatResponse> addChatResponse(
      ChatResponse chatResponse) async {
    var bag = APIBag(
      debug: isInDebugMode,
      data: chatResponse.toJson(),
    );

    print(
        'DataAPI3.addChatMessage getFunctionsURL(): ${getFunctionsURL() + ADD_CHAT_RESPONSE}\n\n');
    try {
      var mResponse =
      await _callCloudFunction(getFunctionsURL() + ADD_CHAT_RESPONSE, bag);
      if (mResponse.statusCode == 200) {
        var map = json.decode(mResponse.body);
        var po = ChatResponse.fromJson(map);
        return po;
      } else {
        print(
            '\n\nDataAPI3.addChatResponse .... we have a problem\n\n\n');
        throw Exception('addChatResponse failed!: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.addChatResponse ERROR $e');
      throw e;
    }
  }
  static const Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

  static Future _callCloudFunction(String mUrl, APIBag bag) async {
    var start = DateTime.now();
    var client = new http.Client();
    var resp = await client
        .post(
      mUrl,
      body: json.encode(bag.toJson()),
      headers: headers,
    )
        .whenComplete(() {
      client.close();
    });
    print(
        '\n\nDataAPI3.doHTTP .... ################ BFN via Cloud Functions: status: ${resp.statusCode}');
    var end = DateTime.now();
    print(
        'ListAPI._doHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
    return resp;
  }

  static Future<DeliveryNote> registerDeliveryNote(
      DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();
    deliveryNote.date = getUTCDate();
    var bag = APIBag(
      debug: isInDebugMode,
      data: deliveryNote.toJson(),
    );
    print(
        'DataAPI3.registerDeliveryNote url: ${getFunctionsURL() + REGISTER_DELIVERY_NOTE}\n\n');

    try {
      var mResponse =
          await _callCloudFunction(getFunctionsURL() + REGISTER_DELIVERY_NOTE, bag);
      if (mResponse.statusCode == 200) {
        var note = DeliveryNote.fromJson(json.decode(mResponse.body));
        return note;
      } else {
        print('DataAPI3.registerDeliveryNote ERROR  ${mResponse.body}');
        throw Exception('registerDeliveryNote failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.registerDeliveryNote ERROR $e');
      throw e;
    }
  }

  static Future<DeliveryAcceptance> acceptDelivery(
      DeliveryAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );

    print(
        'DataAPI3.acceptDelivery url: ${getFunctionsURL() + ACCEPT_DELIVERY_NOTE}');
    try {
      var mResponse =
          await _callCloudFunction(getFunctionsURL() + ACCEPT_DELIVERY_NOTE, bag);
      if (mResponse.statusCode == 200) {
        return DeliveryAcceptance.fromJson(json.decode(mResponse.body));
      } else {
        throw Exception('DeliveryAcceptance failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.acceptDelivery ERROR $e');
      throw e;
    }
  }

  static Future<int> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    invoice.isOnOffer = false;
    invoice.isSettled = false;
    invoice.date = getUTCDate();

    var bag = APIBag(
      debug: isInDebugMode,
      data: invoice.toJson(),
    );

    print(
        'DataAPI3.registerInvoice url: ${getFunctionsURL() + REGISTER_INVOICE}');

    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + REGISTER_INVOICE, bag);
      switch (mResponse.statusCode) {
        case 200:
          print('DataAPI3.registerInvoice: invoice registered');
          return DataAPI3.InvoiceRegistered;
          break;
        case 201: //invoice auto accepted
          print(
              '\n\nDataAPI3.registerInvoice: invoice auto accepted #########################################\n');
          return DataAPI3.InvoiceRegisteredAccepted;
          break;
        default:
          var e = Exception('Register Invoice failed: ${mResponse.body}');
          throw e;
          break;
      }
    } catch (e) {
      print('DataAPI3.registerInvoice ERROR $e');
      throw e;
    }
  }

  static Future<Invoice> saveInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    invoice.isOnOffer = false;
    invoice.isSettled = false;
    invoice.date = getUTCDate();

    var bag = APIBag(
      debug: isInDebugMode,
      data: invoice.toJson(),
    );

    print('DataAPI3.saveInvoice url: ${getFunctionsURL() + REGISTER_INVOICE}');

    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + REGISTER_INVOICE, bag);
      print(mResponse.body);
      switch (mResponse.statusCode) {
        case 200:
          print('DataAPI3.saveInvoice: invoice registered');
          return Invoice.fromJson(json.decode(mResponse.body));
          break;
        case 201: //invoice auto accepted
          print(
              '\n\nDataAPI3.saveInvoice: invoice auto accepted #########################################\n');
          return Invoice.fromJson(json.decode(mResponse.body));
          break;
        default:
          var e = Exception('Register Invoice failed: ${mResponse.body}');
          throw e;
          break;
      }
    } catch (e) {
      print('DataAPI3.saveInvoice ERROR $e');
      throw e;
    }
  }

  static Future<InvoiceAcceptance> acceptInvoice(
      InvoiceAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
//    if (USE_LOCAL_BLOCKCHAIN) {
//      var res = await DataAPI.acceptInvoice(acceptance);
//      return res == '0' ? DataAPI3.BlockchainError : DataAPI3.Success;
//    }
    var bag = APIBag(
      debug: isInDebugMode,
      data: acceptance.toJson(),
    );
    print('DataAPI3.acceptInvoice url: ${getFunctionsURL() + ACCEPT_INVOICE}');
    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + ACCEPT_INVOICE, bag);
      if (mResponse.statusCode == 200) {
        return InvoiceAcceptance.fromJson(json.decode(mResponse.body));
      } else {
        print('DataAPI3.acceptInvoice ERROR  ${mResponse.body}');
        throw Exception('acceptInvoice failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.acceptInvoice ERROR $e');
      throw e;
    }
  }

  static Future<Offer> makeOffer(Offer offer) async {
    offer.offerId = getKey();
    offer.date = getUTCDate();
    offer.isOpen = true;
    offer.isCancelled = false;

    var bag = APIBag(
      debug: isInDebugMode,
      data: offer.toJson(),
    );
    print('DataAPI3.makeOffer  ${getFunctionsURL() + MAKE_OFFER}');
    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + MAKE_OFFER, bag);
      if (mResponse.statusCode == 200) {
        return Offer.fromJson(json.decode(mResponse.body));
      } else {
        print('DataAPI3.MakeOffer ERROR  ${mResponse.reasonPhrase}');
        throw Exception('makeOffer failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.MakeOffer ERROR $e');
      throw e;
    }
  }
  static Future<Offer> updateOffer(Offer offer) async {

    var bag = APIBag(
      debug: isInDebugMode,
      data: offer.toJson(),
    );
    print('DataAPI3.updateOffer  ${getFunctionsURL() + UPDATE_OFFER}');
    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + UPDATE_OFFER, bag);
      if (mResponse.statusCode == 200) {
        return Offer.fromJson(json.decode(mResponse.body));
      } else {
        print('DataAPI3.updateOffer ERROR  ${mResponse.reasonPhrase}');
        throw Exception('updateOffer failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.updateOffer ERROR $e');
      throw e;
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

    print('DataAPI3.closeOffer ${getFunctionsURL() + CLOSE_OFFER}');
    try {
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + CLOSE_OFFER));
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

  static Future makeInvoiceBid(InvoiceBid bid) async {
    bid..invoiceBidId = getKey();
    bid.date = getUTCDate();
    bid.isSettled = false;
    var bag = APIBag(
      debug: isInDebugMode,
      data: bid.toJson(),
    );
    print('DataAPI3.makeInvoiceBid ${getFunctionsURL() + MAKE_INVOICE_BID}');
    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + MAKE_INVOICE_BID, bag);
      if (mResponse.statusCode == 200) {
        return 0;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI3.makeInvoiceBid  $contents');
        });
        print('DataAPI3.makeInvoiceBid ERROR  ${mResponse.reasonPhrase}');
        throw Exception('makeInvoiceBid failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.makeInvoiceBid ERROR $e');
      throw e;
    }
  }

  static Future makeInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = getUTCDate();
    var bag = APIBag(
      debug: isInDebugMode,
      data: settlement.toJson(),
    );
    print(
        'DataAPI3.makeInvestorInvoiceSettlement ${getFunctionsURL() + MAKE_INVESTOR_INVOICE_SETTLEMENT}');
    try {
      var mResponse = await _callCloudFunction(
          getFunctionsURL() + MAKE_INVESTOR_INVOICE_SETTLEMENT, bag);
      if (mResponse.statusCode == 200) {
        return 0;
      } else {
        print(mResponse.body);
        print(
            'DataAPI3.makeInvestorInvoiceSettlement ERROR  ${mResponse.statusCode}');
        throw Exception(
            'makeInvestorInvoiceSettlement failed: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.makeInvestorInvoiceSettlement ERROR $e');
      throw e;
    }
  }

  //////////// ###################################### //////////
  static Future<int> addGovtEntity(GovtEntity govtEntity, User admin) async {
    assert(govtEntity != null);
    assert(admin != null);

    print(
        'DataAPI3.addGovtEntity ==============>>>> ........... ${govtEntity.toJson()}');
    print(
        'DataAPI3.addGovtEntity ))))))) URL: ${getFunctionsURL()}$ADD_PARTICIPANT');
    govtEntity.participantId = getKey();
    govtEntity.dateRegistered = getUTCDate();
    admin.userId = getKey();
    admin.dateRegistered = getUTCDate();
    admin.govtEntity =
        'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: govtEntity.toJson(),
        user: admin.toJson(),
        sourceSeed: seed,
        apiSuffix: 'GovtEntity',
        collectionName: 'govtEntities');
    /*
        const result = {
      participantPath: null,
      userPath: null,
      walletPath: null,
      date: new Date().toISOString(),
      elapsedSeconds: 0
    };
     */
    try {
      var resp = await _callCloudFunction(getFunctionsURL() + ADD_PARTICIPANT, bag);
      print(resp.body);
      if (resp.statusCode == 200) {
        Map map = json.decode(resp.body);
        govtEntity.documentReference =
            map['participantPath'].split('/').elementAt(1);
        await SharedPrefs.saveGovtEntity(govtEntity);
        await SharedPrefs.saveUser(admin);
        var qs = await fs
            .collection('wallets')
            .document(map['walletPath'].split('/').elementAt(1))
            .get();
        if (qs.exists) {
          var wallet = Wallet.fromJson(qs.data);
          wallet.documentReference = qs.documentID;
          await SharedPrefs.saveWallet(wallet);
        }
        return Success;
      } else {
        print('DataAPI3.addGovtEntity ${resp.body}');
        return BlockchainError;
      }
    } catch (e) {
      print('DataAPI3.addGovtEntity ERROR $e');
      return UnknownError;
    }
  }

  static Future<AutoTradeStart> executeAutoTrades() async {
    print(
        '\n\n\nDataAPI3.executeAutoTrades url: ${getFunctionsURL() + EXECUTE_AUTO_TRADES}');

    APIBag bag = APIBag(
      debug: isInDebugMode,
    );
    try {
      var mResponse =
          await _callCloudFunction(getFunctionsURL() + EXECUTE_AUTO_TRADES, bag);
      if (mResponse.statusCode == 200) {
        var mjson = json.decode(mResponse.body);
        var start = AutoTradeStart.fromJson(mjson);
        prettyPrint(start.toJson(),
            '\n\n\n######## AUTO TRADE EXECUTION COMPLETE!!!\n\n');
        return start;
      } else {
        print(mResponse.body);
        throw Exception('Auto Trade failed = ${mResponse.body}');
      }
    } catch (e) {
      print(e);
      throw e;
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
    print('DataAPI3.addSector %%%%%%%% url: ${getFunctionsURL() + ADD_DATA}');
    prettyPrint(bag.toJson(), 'adding sector to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
    order.autoTradeOrderId = getKey();
    order.date = getUTCDate();
    order.isCancelled = false;
    var bag = APIBag(
        debug: isInDebugMode,
        data: order.toJson(),
        apiSuffix: 'AutoTradeOrder',
        collectionName: 'autoTradeOrders');
    print(
        'DataAPI3.addAutoTradeOrder %%%%%%%% url: ${getFunctionsURL() + ADD_DATA}');
    prettyPrint(bag.toJson(),
        '########################## adding addAutoTradeOrder to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
    print(
        'DataAPI3.addInvestorProfile %%%%%%%% url: ${getFunctionsURL() + ADD_DATA}');
    prettyPrint(profile.toJson(),
        '########################## adding addInvestorProfile to BFN blockchain');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
    print('DataAPI3.addWallet %%%%%%%% url: ${getFunctionsURL() + ADD_DATA}');
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
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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

  static Future<int> addSupplier(Supplier supplier, User admin) async {
    assert(supplier != null);
    assert(admin != null);

    supplier.dateRegistered = getUTCDate();
    supplier.participantId = getKey();
    admin.userId = getKey();
    admin.dateRegistered = getUTCDate();
    admin.supplier =
        'resource:com.oneconnect.biz.Supplier#${supplier.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: supplier.toJson(),
        user: admin.toJson(),
        sourceSeed: seed,
        apiSuffix: 'Supplier',
        collectionName: 'suppliers');
    print('DataAPI3.addSupplier url: ${getFunctionsURL() + ADD_PARTICIPANT}');
    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + ADD_PARTICIPANT, bag);
      if (mResponse.statusCode == 200) {
        Map map = json.decode(mResponse.body);
        supplier.documentReference =
            map['participantPath'].split('/').elementAt(1);
        await SharedPrefs.saveSupplier(supplier);
        await SharedPrefs.saveUser(admin);
        var qs = await fs
            .collection('wallets')
            .document(map['walletPath'].split('/').elementAt(1))
            .get();
        if (qs.exists) {
          var wallet = Wallet.fromJson(qs.data);
          wallet.documentReference = qs.documentID;
          await SharedPrefs.saveWallet(wallet);
        }

        return Success;
      } else {
        print('DataAPI3.addSupplier ${mResponse.body}');
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
    print('DataAPI3.addBank   ${getFunctionsURL() + ADD_DATA}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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

  static Future<int> addInvestor(Investor investor, User admin) async {
    assert(investor != null);
    assert(admin != null);

    investor.dateRegistered = getUTCDate();
    investor.participantId = getKey();
    admin.userId = getKey();
    admin.dateRegistered = getUTCDate();
    admin.investor =
        'resource:com.oneconnect.biz.Investor#${investor.participantId}';
    var seed;
    if (!isInDebugMode) {
      seed = SignUp.privateKey;
    }
    var bag = APIBag(
        debug: isInDebugMode,
        data: investor.toJson(),
        user: admin.toJson(),
        sourceSeed: seed,
        apiSuffix: 'Investor',
        collectionName: 'investors');
    print('DataAPI3.addInvestor   ${getFunctionsURL() + ADD_PARTICIPANT}');
    prettyPrint(bag.toJson(), 'DataAPI3.addInvestor : ');

    try {
      var mResponse = await _callCloudFunction(getFunctionsURL() + ADD_PARTICIPANT, bag);
      if (mResponse.statusCode == 200) {
        Map map = json.decode(mResponse.body);
        investor.documentReference =
            map['participantPath'].split('/').elementAt(1);
        await SharedPrefs.saveInvestor(investor);
        await SharedPrefs.saveUser(admin);
        var qs = await fs
            .collection('wallets')
            .document(map['walletPath'].split('/').elementAt(1))
            .get();
        if (qs.exists) {
          var wallet = Wallet.fromJson(qs.data);
          wallet.documentReference = qs.documentID;
          await SharedPrefs.saveWallet(wallet);
        }
        return Success;
      } else {
        print('DataAPI3.addInvestor ${mResponse.body}');
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
    print('DataAPI3.addOneConnect ${getFunctionsURL() + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
    print('DataAPI3.addProcurementOffice ${getFunctionsURL() + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
    print('DataAPI3.addAuditor ${getFunctionsURL() + ADD_DATA}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getFunctionsURL() + ADD_DATA));
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
