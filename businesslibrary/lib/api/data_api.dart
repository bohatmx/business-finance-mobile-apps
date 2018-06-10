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
import 'package:businesslibrary/data/item.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DataAPI {
  final String url;

  DataAPI(this.url);
  final Firestore _firestore = Firestore.instance;
  static const GOVT_ENTITY = 'GovtEntity',
      USER = 'User',
      SUPPLIER = 'Supplier',
      ITEM = 'Item',
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
    govtEntity.participantId = getKey();
    var ref = await _firestore
        .collection('govtEntities')
        .add(govtEntity.toJson())
        .catchError((e) {
      print('DataAPI.addGovtEntity ERROR adding to Firestore $e');
      return "0";
    });
    print('DataAPI.addGovtEntity added to Firestore: ${ref.path}');

    govtEntity.documentReference = ref.documentID;
    print('DataAPI.addGovtEntity url: ${url + GOVT_ENTITY}');

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
    print('DataAPI.addUser -- ${user.toJson()}');
    user.userId = getKey();
    var ref =
        await _firestore.collection('users').add(user.toJson()).catchError((e) {
      print('DataAPI.addUser ERROR $e');
      return "0";
    });
    print('DataAPI.addUser user added to Firestore ${ref.documentID}');

    user.documentReference = ref.documentID;
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + USER));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(user.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print(
        'DataAPI.addUser ######## response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return user.userId;
    } else {
      print(
          'DataAPI.addUser ----- ERROR  ${mResponse.reasonPhrase} ${mResponse.headers}');
      return "0";
    }
  }

  /// Stellar wallet already in firestore? YES.
  /// object should contain valid Stellar public key
  ///
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

  /// this wallet record in firestore will start cloud function that creates Stellar wallet
  /// then addWallet method above puts it on the blockchain
  ///
  Future<String> addWalletToFirestoreForStellar(Wallet wallet) async {
    var ref = await _firestore
        .collection('wallets')
        .add(wallet.toJson())
        .catchError((e) {
      print(
          'DataAPI.addWalletToFirestoreForStellar ERROR adding to Firestore $e');
      return "0";
    });
    print(
        'DataAPI.addWalletToFirestoreForStellar added to Firestore: ${ref.documentID}');
    return ref.documentID;
  }

  Future<String> addCompany(Company company) async {
    company.participantId = getKey();
    var ref = await _firestore
        .collection('companies')
        .add(company.toJson())
        .catchError((e) {
      print('DataAPI.addCompany ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addCompany added to Firestore: ${ref.documentID}');
    company.documentReference = ref.documentID;
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
    supplier.participantId = getKey();
    var ref = await _firestore
        .collection('suppliers')
        .add(supplier.toJson())
        .catchError((e) {
      print('DataAPI.addSupplier ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addSupplier added to Firestore: ${ref.documentID}');
    supplier.documentReference = ref.documentID;
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
    investor.participantId = getKey();
    var ref = await _firestore
        .collection('investors')
        .add(investor.toJson())
        .catchError((e) {
      print('DataAPI.addInvestor ERROR adding to Firestore $e');
      return '0';
    });
    investor.documentReference = ref.documentID;
    print('DataAPI.addInvestor added to Firestore: ${ref.documentID}');
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
    bank.participantId = getKey();
    var ref =
        await _firestore.collection('banks').add(bank.toJson()).catchError((e) {
      print('DataAPI.addBank ERROR adding to Firestore $e');
      return '0';
    });
    bank.documentReference = ref.documentID;
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + BANK));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(bank.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addBank response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      print('DataAPI.addBank added to Firestore: ${ref.documentID}');

      return bank.participantId;
    } else {
      print('DataAPI.addBank ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = getKey();
    var ref = await _firestore
        .collection('oneConnect')
        .add(oneConnect.toJson())
        .catchError((e) {
      print('DataAPI.addOneConnect ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addOneConnect added to Firestore: ${ref.documentID}');
    oneConnect.documentReference = ref.documentID;
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
    office.participantId = getKey();
    var ref = await _firestore
        .collection('procurementOffices')
        .add(office.toJson())
        .catchError((e) {
      print('DataAPI.addProcurementOffice ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addProcurementOffice added to Firestore: ${ref.documentID}');
    office.documentReference = ref.documentID;

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
    auditor.participantId = getKey();
    var ref = await _firestore
        .collection('auditors')
        .add(auditor.toJson())
        .catchError((e) {
      print('DataAPI.addAuditor ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addAuditor added to Firestore: ${ref.documentID}');
    auditor.documentReference = ref.documentID;

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

  /// transactions
  ///
  Future<String> registerPurchaseOrder(PurchaseOrder purchaseOrder) async {
    purchaseOrder.purchaseOrderId = getKey();
    String participantId, collection, documentId, supplierDoocumentId;
    if (purchaseOrder.govtEntity != null) {
      var strings = purchaseOrder.govtEntity.split("#");
      participantId = strings.elementAt(1);
      collection = 'govtEntities';
      documentId = await _getDocumentId(collection, participantId);
    }
    if (purchaseOrder.company != null) {
      var strings = purchaseOrder.company.split("#");
      participantId = strings.elementAt(1);
      collection = 'companies';
      documentId = await _getDocumentId(collection, participantId);
    }
    if (purchaseOrder.supplier != null) {
      var strings = purchaseOrder.supplier.split("#");
      participantId = strings.elementAt(1);
      supplierDoocumentId = await _getDocumentId('suppliers', participantId);
    }

    var ref = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('purchaseOrders')
        .add(purchaseOrder.toJson())
        .catchError((e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return '0';
    });
    var ref2 = await _firestore
        .collection('suppliers')
        .document(supplierDoocumentId)
        .collection('purchaseOrders')
        .add(purchaseOrder.toJson())
        .catchError((e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return '0';
    });
    print('DataAPI.registerPurchaseOrder document issuer path: ${ref.path}');
    print('DataAPI.registerPurchaseOrder document supplier path: ${ref2.path}');
    purchaseOrder.documentReference = ref.documentID;
    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + REGISTER_PURCHASE_ORDER));
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

  Future<String> _getDocumentId(String collection, String participantId) async {
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

  Future<String> addPurchaseOrderItem(
      Item item, PurchaseOrder purchaseOrder) async {
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

  Future<String> _addItem(Item item) async {
    item.itemId = getKey();

    var httpClient = new HttpClient();
    HttpClientRequest mRequest =
        await httpClient.postUrl(Uri.parse(url + ITEM));
    mRequest.headers.contentType = _contentType;
    mRequest.write(json.encode(item.toJson()));
    HttpClientResponse mResponse = await mRequest.close();
    print('DataAPI.addItem response status code:  ${mResponse.statusCode}');
    if (mResponse.statusCode == 200) {
      return item.itemId;
    } else {
      print('DataAPI.addItem ERROR  ${mResponse.reasonPhrase}');
      return "0";
    }
  }

  Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();
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
    invoice.invoiceId = getKey();
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

  static String getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('DataAPI.getKey key generated: $key');
    return key;
  }
}
