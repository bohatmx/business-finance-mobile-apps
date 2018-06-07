import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:uuid/uuid.dart';

class NetworkAPI {
  static const DEBUG_URL_HOME = 'http://192.168.86.238:3003/api/'; //FIBRE
  static const DEBUG_URL_ROUTER = 'http://192.168.8.237:3003/api/'; //ROUTER
  static const RELEASE_URL = 'http://192.168.86.238:3003/api/'; //CLOUD

  static const GOVT_ENTITY = 'GovtEntity',
      USER = 'User',
      SUPPLIER = 'Supplier',
      AUDITOR = 'Auditor',
      COMPANY = 'Company',
      PROCUREMENT_OFFICE = 'ProcurementOffice',
      BANK = 'Bank',
      ONECONNECT = 'OneConnect',
      WALLET = 'Wallet',
      REGISTER_PURCHASE_ORDER = 'RegisterPurchaseOrder',
      REGISTER_DELIVERY_NOTE = 'RegisterDeliveryNote',
      INVESTOR = 'Investor';

  static String getURL() {
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_HOME; //switch  to DEBUG_URL_ROUTER before demo
    } else {
      url = RELEASE_URL;
    }
    return url;
  }

  static Future<String> addGovtEntity(GovtEntity govtEntity) async {
    govtEntity.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + GOVT_ENTITY));
    mRequest.write(govtEntity.toJson());
    HttpClientResponse mResponse = await mRequest.close();

    print(
        'NetworkAPI.addGovtEntity response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return govtEntity.participantId;
    } else {
      print('NetworkAPI.addGovtEntity ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addUser(User user) async {
    user.userId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + USER));
    mRequest.write(user.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print('NetworkAPI.addUser response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return user.userId;
    } else {
      print('NetworkAPI.addUser ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addWallet(Wallet wallet) async {
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + WALLET));
    mRequest.write(wallet.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print('NetworkAPI.addUser response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return wallet.stellarPublicKey;
    } else {
      print('NetworkAPI.addUser ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addCompany(Company company) async {
    company.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + COMPANY));
    mRequest.write(company.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addCompany response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return company.participantId;
    } else {
      print('NetworkAPI.addCompany ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addSupplier(Supplier supplier) async {
    supplier.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + SUPPLIER));
    mRequest.write(supplier.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addSupplier response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return supplier.participantId;
    } else {
      print('NetworkAPI.addSupplier ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addInvestor(Investor investor) async {
    investor.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + INVESTOR));
    mRequest.write(investor.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addInvestor response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return investor.participantId;
    } else {
      print('NetworkAPI.addInvestor ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addBank(Bank bank) async {
    bank.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + BANK));
    mRequest.write(bank.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print('NetworkAPI.addBank response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return bank.participantId;
    } else {
      print('NetworkAPI.addBank ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + ONECONNECT));
    mRequest.write(oneConnect.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addOneConnect response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return oneConnect.participantId;
    } else {
      print('NetworkAPI.addOneConnect ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addProcurementOffice(ProcurementOffice office) async {
    office.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + PROCUREMENT_OFFICE));
    mRequest.write(office.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addProcurementOffice response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return office.participantId;
    } else {
      print('NetworkAPI.addProcurementOffice ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> addAuditor(Auditor auditor) async {
    auditor.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(getURL() + AUDITOR));
    mRequest.write(auditor.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.addAuditor response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return auditor.participantId;
    } else {
      print('NetworkAPI.addAuditor ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> registerPurchaseOrder(
      PurchaseOrder purchaseOrder) async {
    purchaseOrder.purchaseOrderId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(getURL()));
    mRequest.write(purchaseOrder.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.registerPurchaseOrder response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return purchaseOrder.purchaseOrderId;
    } else {
      print(
          'NetworkAPI.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(getURL()));
    mRequest.write(deliveryNote.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.registerDeliveryNote response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return deliveryNote.deliveryNoteId;
    } else {
      print('NetworkAPI.registerDeliveryNote ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<String> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(getURL()));
    mRequest.write(invoice.toJson());
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.registerInvoice response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return invoice.invoiceId;
    } else {
      print('NetworkAPI.registerInvoice ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  static Future<int> acceptDelivery(String deliveryNote, String user) async {
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(getURL()));
    mRequest.write({
      'deliveryNote': deliveryNote,
      'user': user,
    });
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'NetworkAPI.acceptDelivery response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return 0;
    } else {
      print('NetworkAPI.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
      return 1;
    }
  }

  static Future<List<PurchaseOrder>> getPurchaseOrders(
      String participantId) async {
    assert(participantId != null);
    String url = getURL() + participantId;
    print("getPurchaseOrders url: " + url);
    var httpClient = new HttpClient();

    List<PurchaseOrder> pos = List();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var statusCode = response.statusCode;
    print("REST server HTTP status code: $statusCode");
    if (response.statusCode == HttpStatus.OK) {
      var jx = await response.transform(utf8.decoder).join();
      Map data = json.decode(jx);
      data.forEach((key, value) {
        var po = new PurchaseOrder.fromJSON(value);
        pos.add(po);
      });
    } else {
      var code = response.statusCode;
      var msg = 'Bad REST server HTTP status code: $code';
      print(msg);
      throw (msg);
    }

    return pos;
  }

  static String _getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('NetworkAPI.getKey key generated: $key');
    return key;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
