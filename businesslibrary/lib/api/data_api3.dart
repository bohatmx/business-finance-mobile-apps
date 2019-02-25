import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/data/api_bag.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/country.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_bid_keys.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
      var ref = await fs
          .collection('invoiceBidSettlementBatches')
          .add(bidKeys.toJson());
      return ref.path.split('/').elementAt(1);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<PurchaseOrder> registerPurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    var bag = APIBag(
        jsonString: purchaseOrder.toJson().toString(),
        functionName: 'addPurchaseOrder',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    PurchaseOrder order = PurchaseOrder.fromJson(result);
    return order;
  }

  static Future<ChatMessage> addChatMessage(ChatMessage chatMessage) async {
    var bag = APIBag(
      debug: isInDebugMode,
//      data: chatMessage.toJson(),
    );

    print(
        'DataAPI3.addChatMessage getFunctionsURL(): ${getWebAPIUrl() + ADD_CHAT_MESSAGE}\n\n');
    try {
      var mResponse =
          await _callCloudFunction(getWebAPIUrl() + ADD_CHAT_MESSAGE, bag);
      if (mResponse.statusCode == 200) {
        var map = json.decode(mResponse.body);
        var po = ChatMessage.fromJson(map);
        return po;
      } else {
        print('\n\nDataAPI3.addChatMessage .... we have a problem\n\n\n');
        throw Exception('addChatMessage failed!: ${mResponse.body}');
      }
    } catch (e) {
      print('DataAPI3.addChatMessage ERROR $e');
      throw e;
    }
  }

  static Future<ChatResponse> addChatResponse(ChatResponse chatResponse) async {
    var bag = APIBag(
      debug: isInDebugMode,
//      data: chatResponse.toJson(),
    );

    print(
        'DataAPI3.addChatMessage getFunctionsURL(): ${getWebAPIUrl() + ADD_CHAT_RESPONSE}\n\n');
    try {
      var mResponse =
          await _callCloudFunction(getWebAPIUrl() + ADD_CHAT_RESPONSE, bag);
      if (mResponse.statusCode == 200) {
        var map = json.decode(mResponse.body);
        var po = ChatResponse.fromJson(map);
        return po;
      } else {
        print('\n\nDataAPI3.addChatResponse .... we have a problem\n\n\n');
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
    var bag = APIBag(
        jsonString: deliveryNote.toJson().toString(),
        functionName: 'addDeliveryNote',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    return DeliveryNote.fromJson(result);
  }

  static Future<DeliveryAcceptance> acceptDelivery(
      DeliveryAcceptance acceptance) async {
    var bag = APIBag(
        jsonString: acceptance.toJson().toString(),
        functionName: 'addDeliveryAcceptance',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    return DeliveryAcceptance.fromJson(result);
  }

  static Future<Invoice> registerInvoice(Invoice invoice) async {
    invoice.isOnOffer = false;
    invoice.isSettled = false;

    var bag = APIBag(
        jsonString: invoice.toJson().toString(),
        functionName: 'addInvoice',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    return Invoice.fromJson(result);
  }

  static Future<InvoiceAcceptance> acceptInvoice(
      InvoiceAcceptance acceptance) async {
    var bag = APIBag(
        jsonString: acceptance.toJson().toString(),
        functionName: 'addInvoiceAcceptance',
        userName: TemporaryUserName);
    var result = await _connectToWebAPI(bag);
    return InvoiceAcceptance.fromJson(result);
  }

  static Future<Offer> makeOffer(Offer offer) async {
    offer.isOpen = true;
    offer.isCancelled = false;

    var bag = APIBag(
        jsonString: offer.toJson().toString(),
        functionName: 'addOffer',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    return Offer.fromJson(result);
  }

  static Future<int> closeOffer(String offerId) async {}

  static Future makeInvoiceBid(InvoiceBid bid) async {
    bid.isSettled = false;
    var bag = APIBag(
        jsonString: bid.toJson().toString(),
        functionName: 'addInvoiceBid',
        userName: TemporaryUserName);
    var result = await _connectToWebAPI(bag);
    return InvoiceBid.fromJson(result);
  }

  static Future makeInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    settlement.date = getUTCDate();
  }

  //////////// ###################################### //////////
  static Future<Customer> addCustomer(Customer customer, User admin) async {
    assert(customer != null);
    assert(admin != null);

    var bag = APIBag(
        jsonString: customer.toJson().toString(),
        functionName: 'addCustomer',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    var cust = Customer.fromJson(result);
    //
    admin.customer = cust.participantId;
    bag = APIBag(
        jsonString: admin.toJson().toString(),
        functionName: 'addUser',
        userName: TemporaryUserName);
    await _connectToWebAPI(bag);

    return cust;
  }

  static Future testChainCode(String functionName) async {
    var bag = APIBag(functionName: functionName, userName: TemporaryUserName);
    print(
        '\n😡 😡 😡 😡  😡 😡 😡 😡  -- Testing chaincode call: $functionName');
    var replyFromWeb = await _connectToWebAPI(bag);
    print('💦  💦  💦 💦  💦  💦 BACK FROM WEB API CALL ... $functionName');
    var result = json.decode(replyFromWeb['result']);
    var msg = replyFromWeb['message'];
    print(msg);
//    if (replyFromWeb is Map) {
//      print('I am a map ....');
//      var result = json.decode(replyFromWeb['result']);
//      if (result is List) {
//        print('I am a list ....');
//        result.forEach((r) {
//          prettyPrint(r, '💦  💦  💦 💦  💦  💦 OBJECT: ${r}');
//        });
//      }
//    }
    List<Customer> customers = List();
    List<Supplier> suppliers = List();
    List<Investor> investors = List();
    switch (functionName) {
      case 'getAllCustomers':
        result.forEach((m) {
          var mx = Customer.fromJson(m);
          customers.add(mx);
        });
        print(
            '\n\nMessage from Chaincode: $msg \n🙄  Customers: ${customers.length}');
        break;
      case 'getAllSuppliers':
        result.forEach((m) {
          var mx = Supplier.fromJson(m);
          suppliers.add(mx);
        });
        print(
            '\n\nMessage from Chaincode: $msg \n🙄  Suppliers: ${suppliers.length}');
        break;
      case 'getAllInvestors':
        result.forEach((m) {
          var mx = Investor.fromJson(m);
          investors.add(mx);
        });
        print(
            '\n\nMessage from Chaincode: $msg \n🙄  Investors: ${investors.length}');
        break;
    }
    customers.forEach((c) {
      prettyPrint(c.toJson(), '\n🙄 🙄 🙄 🙄 🙄   CUSTOMER');
    });
    suppliers.forEach((c) {
      prettyPrint(c.toJson(), '\n🙄 🙄 🙄 🙄 🙄   SUPPLIER');
    });
    investors.forEach((c) {
      prettyPrint(c.toJson(), '\n🙄 🙄 🙄 🙄 🙄   INVESTOR');
    });
    return result;
  }

  static Future executeAutoTrades() async {
    print(
        '\n\n\nDataAPI3.executeAutoTrades url: ${getWebAPIUrl() + EXECUTE_AUTO_TRADES}');

    var bag = APIBag(
        jsonString: '',
        functionName: 'executeAutoTrades',
        userName: TemporaryUserName);

    return await _connectToWebAPI(bag);
  }

  static Future<int> addCountries() async {
    await addCountry(Country(name: 'South Africa', code: 'ZA', vat: 15.0));
    await addCountry(Country(name: 'Zimbabwe', code: 'ZW', vat: 15.0));
    await addCountry(Country(name: 'Botswana', code: 'BW', vat: 15.0));
    await addCountry(Country(name: 'Namibia', code: 'NA', vat: 15.0));
    await addCountry(Country(name: 'Zambia', code: 'ZB', vat: 15.0));
    await addCountry(Country(name: 'Kenya', code: 'KE', vat: 15.0));
    await addCountry(Country(name: 'Tanzania', code: 'TZ', vat: 15.0));
    await addCountry(Country(name: 'Mozambique', code: 'MZ', vat: 15.0));
    await addCountry(Country(name: 'Ghana', code: 'GH', vat: 15.0));
    await addCountry(Country(name: 'Lesotho', code: 'LS', vat: 15.0));
    await addCountry(Country(name: 'Malawi', code: 'MW', vat: 15.0));
    await addCountry(Country(name: 'Nigeria', code: 'NG', vat: 15.0));

    return 0;
  }

  static Future<int> addSectors() async {
    await addSector(Sector(sectorName: 'Public Sector'));
    await addSector(Sector(sectorName: 'Automotive'));
    await addSector(Sector(sectorName: 'Construction'));
    await addSector(Sector(sectorName: 'Engineering'));
    await addSector(Sector(sectorName: 'Retail'));
    await addSector(Sector(sectorName: 'Home Services'));
    await addSector(Sector(sectorName: 'Transport'));
    await addSector(Sector(sectorName: 'Logistics'));
    await addSector(Sector(sectorName: 'Services'));
    await addSector(Sector(sectorName: 'Agricultural'));
    await addSector(Sector(sectorName: 'Real Estate'));
    await addSector(Sector(sectorName: 'Technology'));
    await addSector(Sector(sectorName: 'Manufacturing'));
    await addSector(Sector(sectorName: 'Education'));
    await addSector(Sector(sectorName: 'Health Services'));
    await addSector(Sector(sectorName: 'Pharmaceutical'));
    return DataAPI3.Success;
  }

  // ignore: non_constant_identifier_names
  static final String TemporaryUserName = 'admin';

  static Future<Sector> addSector(Sector sector) async {
    var bag = APIBag(
        jsonString: sector.toJson().toString(),
        functionName: 'addSector',
        userName: TemporaryUserName);

    prettyPrint(bag.toJson(), '\n🔵 🔵 adding sector to BFN blockchain');
    var result = await _connectToWebAPI(bag);
    return Sector.fromJson(result);
  }

  static Future<Country> addCountry(Country country) async {
    var bag = APIBag(
        jsonString: country.toJson().toString(),
        functionName: 'addCountry',
        userName: TemporaryUserName);

    prettyPrint(bag.toJson(), '\n🔵 🔵 adding country to BFN blockchain');
    var result = await _connectToWebAPI(bag);
    return Country.fromJson(result);
  }

  // ignore: missing_return
  static Future _connectToWebAPI(APIBag bag) async {
    print(
        '\n\n🔵 🔵 🔵 🔵 🔵 🔵   DataAPI3._connectToWebAPI sending:  \n🔵 🔵  ${bag.toJson().toString()}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(getWebAPIUrl()));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(bag.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          '\n\n🔵 🔵 🔵 🔵 🔵 🔵   DataAPI3._connectToWebAPI blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        // transforms and prints the response
        String reply = await mResponse.transform(utf8.decoder).join();
        print('\n\n🔵 🔵 🔵  reply here ..............');
        print(reply);
        print('\n\n🔵 🔵 🔵  🔵 🔵 🔵  🔵 🔵 🔵  🔵 🔵 🔵 \n');

//        await for (var contents in mResponse.transform(utf8.decoder)) {
//          print(
//              '\n\n😡 😡 😡 😡 DataAPI3._connectToWebAPI response data:\n\n $contents');
//          mString = contents;
//        }
        return json.decode(reply);
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('\n\n😡 😡 😡 😡 DataAPI3._connectToWebAPI  $contents');
        });
        print(
            '\n\n😡 😡 😡 😡  DataAPI3._connectToWebAPI ERROR  ${mResponse.reasonPhrase}');
        throw Exception(mResponse.reasonPhrase);
      }
    } catch (e) {
      print(
          '\n\n👿 👿 👿  👿 👿 👿   DataAPI3._connectToWebAPI ERROR : \n$e \n\n👿 👿 👿 👿 👿 👿 ');
      throw e;
    }
    //return result;
  }

  static Future<AutoTradeOrder> addAutoTradeOrder(AutoTradeOrder order) async {
    order.isCancelled = false;
    var bag = APIBag(
        jsonString: order.toJson().toString(),
        functionName: 'addAutoTradeOrder',
        userName: TemporaryUserName);
    print('DataAPI3.addAutoTradeOrder %%%%%%%% url: ${getWebAPIUrl()}');
    prettyPrint(bag.toJson(),
        '########################## adding addAutoTradeOrder to BFN blockchain');
    var result = await _connectToWebAPI(bag);
    return AutoTradeOrder.fromJson(result);
  }

  static Future<InvestorProfile> addInvestorProfile(
      InvestorProfile profile) async {
    var bag = APIBag(
        jsonString: profile.toJson().toString(),
        functionName: 'addInvestorProfile',
        userName: TemporaryUserName);
    print(
        'DataAPI3.addInvestorProfile %%%%%%%% url: ${getWebAPIUrl() + ADD_DATA}');
    prettyPrint(profile.toJson(),
        '########################## adding addInvestorProfile to BFN blockchain');

    var result = await _connectToWebAPI(bag);
    return InvestorProfile.fromJson(result);
  }

  static Future<Wallet> addWallet(Wallet wallet) async {
    var bag = APIBag(
        jsonString: wallet.toJson().toString(),
        functionName: 'addWallet',
        userName: TemporaryUserName);

    var result = await _connectToWebAPI(bag);
    return Wallet.fromJson(result);
  }

  static Future<Supplier> addSupplier(Supplier supplier, User admin) async {
    assert(supplier != null);
    assert(admin != null);

    var bag = APIBag(
        jsonString: supplier.toJson().toString(),
        functionName: 'addSupplier',
        userName: TemporaryUserName);
    var res = await _connectToWebAPI(bag);
    var supp = Supplier.fromJson(res);
    //
    admin.supplier = supp.participantId;
    bag = APIBag(
        jsonString: admin.toJson().toString(),
        functionName: 'addUser',
        userName: TemporaryUserName);
    await _connectToWebAPI(bag);

    return supp;
  }

  static Future<Investor> addInvestor(Investor investor, User admin) async {
    assert(investor != null);
    assert(admin != null);

    var bag = APIBag(
        jsonString: investor.toJson().toString(),
        functionName: 'addInvestor',
        userName: TemporaryUserName);
    var res1 = await _connectToWebAPI(bag);
    var inv = Investor.fromJson(res1);
    //
    admin.investor = inv.participantId;
    bag = APIBag(
        jsonString: admin.toJson().toString(),
        functionName: 'addUser',
        userName: TemporaryUserName);
    await _connectToWebAPI(bag);
    return inv;
  }
}
