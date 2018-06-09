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

class DataAPI {
  final String url;

  DataAPI(this.url);

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

  HttpClient _httpClient = new HttpClient();
  ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");

  Future<String> addGovtEntity(GovtEntity govtEntity) async {
    govtEntity.participantId = _getKey();
    print('DataAPI.addGovtEntity url: $url');

    HttpClientRequest mRequest =
        await _httpClient.postUrl(Uri.parse(url + GOVT_ENTITY));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(govtEntity.toJson()));

    HttpClientResponse resp = await mRequest.close();
    print(
        'DataAPI.addGovtEntity resp.statusCode: ${resp.statusCode} \n ${resp.headers}');
    if (resp.statusCode == 200) {
      return govtEntity.participantId;
    } else {
      print('DataAPI.addGovtEntity ERROR  ${resp.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addUser(User user) async {
    user.userId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + USER));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(user.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addUser response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return user.userId;
    } else {
      print('DataAPI.addUser ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addWallet(Wallet wallet) async {
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + WALLET));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(wallet.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addUser response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return wallet.stellarPublicKey;
    } else {
      print('DataAPI.addUser ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addCompany(Company company) async {
    company.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + COMPANY));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(company.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addCompany response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return company.participantId;
    } else {
      print('DataAPI.addCompany ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addSupplier(Supplier supplier) async {
    supplier.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + SUPPLIER));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(supplier.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addSupplier response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return supplier.participantId;
    } else {
      print('DataAPI.addSupplier ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addInvestor(Investor investor) async {
    investor.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + INVESTOR));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(investor.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addInvestor response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return investor.participantId;
    } else {
      print('DataAPI.addInvestor ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addBank(Bank bank) async {
    bank.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + BANK));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(bank.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addBank response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return bank.participantId;
    } else {
      print('DataAPI.addBank ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + ONECONNECT));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(oneConnect.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.addOneConnect response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return oneConnect.participantId;
    } else {
      print('DataAPI.addOneConnect ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addProcurementOffice(ProcurementOffice office) async {
    office.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + PROCUREMENT_OFFICE));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(office.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.addProcurementOffice response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return office.participantId;
    } else {
      print('DataAPI.addProcurementOffice ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addAuditor(Auditor auditor) async {
    auditor.participantId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + AUDITOR));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(auditor.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addAuditor response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return auditor.participantId;
    } else {
      print('DataAPI.addAuditor ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> registerPurchaseOrder(PurchaseOrder purchaseOrder) async {
    purchaseOrder.purchaseOrderId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(url));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(purchaseOrder.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.registerPurchaseOrder response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return purchaseOrder.purchaseOrderId;
    } else {
      print('DataAPI.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(url));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(deliveryNote.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.registerDeliveryNote response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return deliveryNote.deliveryNoteId;
    } else {
      print('DataAPI.registerDeliveryNote ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = _getKey();
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(url));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(invoice.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.registerInvoice response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return invoice.invoiceId;
    } else {
      print('DataAPI.registerInvoice ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<int> acceptDelivery(String deliveryNote, String user) async {
    var httpClient = new HttpClient();
    HttpClientRequest mRequest = await httpClient.postUrl(Uri.parse(url));
    mRequest.headers.contentType = _contentType;
    mRequest.write({
      'deliveryNote': deliveryNote,
      'user': user,
    });
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.acceptDelivery response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return 0;
    } else {
      print('DataAPI.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
      return 1;
    }
  }

  String _getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('DataAPI.getKey key generated: $key');
    return key;
  }
}
