import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/item.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
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
      SUPPLIER_CONTRACT = 'SupplierContract',
      WALLET = 'Wallet',
      REGISTER_PURCHASE_ORDER = 'RegisterPurchaseOrder',
      REGISTER_DELIVERY_NOTE = 'RegisterDeliveryNote',
      REGISTER_INVOICE = 'RegisterInvoice',
      ACCEPT_DELIVERY = 'AcceptDelivery',
      ACCEPT_INVOICE = 'AcceptInvoice',
      MAKE_INVOICE_OFFER = 'MakeInvoiceOffer',
      MAKE_INVOICE_BID = 'MakeInvoiceBid',
      MAKE_INVESTOR_SETTLEMENT = 'MakeInvestorInvoiceSettlement',
      MAKE_COMPANY_SETTLEMENT = 'MakeCompanyInvoiceSettlement',
      MAKE_GOVT_SETTLEMENT = 'MakeGovtInvoiceSettlement',
      INVESTOR = 'Investor';
  static const ErrorFirestore = 1, ErrorBlockchain = 2, Success = 0;

  HttpClient _httpClient = new HttpClient();
  ContentType _contentType =
      new ContentType("application", "json", charset: "utf-8");

  Future<String> addGovtEntity(GovtEntity govtEntity) async {
    govtEntity.participantId = getKey();

    print('DataAPI.addGovtEntity url: ${url + GOVT_ENTITY}');

    try {
      HttpClientRequest mRequest =
          await _httpClient.postUrl(Uri.parse(url + GOVT_ENTITY));
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
        print('DataAPI.addGovtEntity added to Firestore: ${ref.path}');

        govtEntity.documentReference = ref.documentID;
        await SharedPrefs.saveGovtEntity(govtEntity);
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

  Future<String> addUser(User user) async {
    user.userId = getKey();

    print('DataAPI.addUser url: ${url + USER}');
    prettyPrint(user.toJson(), 'DataAPI.addUser ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + USER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(user.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addUser ######## blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection('users')
            .add(user.toJson())
            .catchError((e) {
          print('DataAPI.addUser ERROR $e');
          return "0";
        });
        print('DataAPI.addUser user added to Firestore ${ref.documentID}');

        user.documentReference = ref.documentID;
        await SharedPrefs.saveUser(user);
        return user.userId;
      } else {
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addUser  $contents');
        });
        print(
            'DataAPI.addUser ----- ERROR  ${mResponse.reasonPhrase} ${mResponse.headers}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addUser ERROR $e');
      return '0';
    }
  }

  /// Stellar wallet already in firestore? YES.
  /// object should contain valid Stellar public key
  ///
  Future<String> addWallet(Wallet wallet) async {
    print('DataAPI.addWallet %%%%%%%% url: ${url + WALLET}');
    prettyPrint(wallet.toJson(), 'adding wallet to BFN blockcahain');

    wallet.encryptedSecret = null;
    wallet.debug = null;
    wallet.sourceSeed = null;
    wallet.secret = null;
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + WALLET));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(wallet.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addWallet blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        prettyPrint(
            wallet.toJson(), 'addWallet - WALLET on blockchain. Yay! ######');
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

  Future<String> addCompany(Company company) async {
    company.participantId = getKey();
    company.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addCompany ${url + COMPANY}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + COMPANY));
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

  Future<String> addSupplier(Supplier supplier) async {
    supplier.participantId = getKey();

    print('DataAPI.addSupplier url: ${url + SUPPLIER}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + SUPPLIER));
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

  Future<String> addInvestor(Investor investor) async {
    investor.participantId = getKey();
    investor.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addInvestor   ${url + INVESTOR}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + INVESTOR));
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
        await SharedPrefs.saveInvestor(investor);
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

  Future<String> addBank(Bank bank) async {
    bank.participantId = getKey();
    bank.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addBank ${url + BANK}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + BANK));
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

  Future<String> addSupplierContract(SupplierContract contract) async {
    var supplierId = contract.supplier.split("#").elementAt(1);
    var docId = await _getDocumentId('suppliers', supplierId);
    contract.supplierDocumentRef = docId;

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
    var ref = await _firestore
        .collection('suppliers')
        .document(docId)
        .collection('supplierContracts')
        .add(contract.toJson())
        .catchError((e) {
      print('DataAPI.addSupplierContract ERROR adding to Firestore $e');
      return '0';
    });

    contract.documentReference = ref.documentID;
    contract.date = new DateTime.now().toIso8601String();

    print(
        'DataAPI.addSupplierContract #########################  ${url + SUPPLIER_CONTRACT}');
    prettyPrint(contract.toJson(),
        'DataAPI.addSupplierContract: document refs anyone? .....  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + SUPPLIER_CONTRACT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(contract.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSupplierContract blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        print(
            'DataAPI.addSupplierContract added to Firestore: ${ref.documentID}');

        return contract.contractId;
      } else {
        ref.delete();
        print('DataAPI.addSupplierContract ERROR  ${mResponse.reasonPhrase}');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.addSupplierContract  $contents');
        });
        return "0";
      }
    } catch (e) {
      ref.delete();
      print('DataAPI.addSupplierContract ERROR $e');
      return '0';
    }
  }

  Future<String> addOneConnect(OneConnect oneConnect) async {
    oneConnect.participantId = getKey();
    oneConnect.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addOneConnect ${url + ONECONNECT}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ONECONNECT));
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

  Future<String> addProcurementOffice(ProcurementOffice office) async {
    office.participantId = getKey();
    office.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addProcurementOffice ${url + PROCUREMENT_OFFICE}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + PROCUREMENT_OFFICE));
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

  Future<String> addAuditor(Auditor auditor) async {
    auditor.participantId = getKey();
    auditor.dateRegistered = new DateTime.now().toIso8601String();

    print('DataAPI.addAuditor ${url + AUDITOR}');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + AUDITOR));
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
  Future<String> registerPurchaseOrder(PurchaseOrder purchaseOrder) async {
    assert(purchaseOrder.purchaserName != null);
    purchaseOrder.purchaseOrderId = getKey();
    print(
        'DataAPI.registerPurchaseOrder ... starting purchase: ${purchaseOrder.toJson()}');
    String collection, documentId, supplierDocId;
    if (purchaseOrder.govtEntity != null) {
      collection = 'govtEntities';
      var id = purchaseOrder.govtEntity.split('#').elementAt(1);
      documentId = await _getDocumentId(collection, id);
      purchaseOrder.govtDocumentRef = documentId;
    }
    if (purchaseOrder.company != null) {
      collection = 'companies';
      var id = purchaseOrder.company.split('#').elementAt(1);
      documentId = await _getDocumentId(collection, id);
      purchaseOrder.companyDocumentRef = documentId;
    }
    if (purchaseOrder.supplier != null) {
      var id = purchaseOrder.supplier.split('#').elementAt(1);
      supplierDocId = await _getDocumentId('suppliers', id);
      purchaseOrder.supplierDocumentRef = supplierDocId;
    }

    print(
        'DataAPI.registerPurchaseOrder url: ${url + REGISTER_PURCHASE_ORDER}');
    prettyPrint(purchaseOrder.toJson(), 'DataAPI.registerPurchaseOrder  ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_PURCHASE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(purchaseOrder.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerPurchaseOrder blockchain response status code:  ${mResponse
              .statusCode}');
      if (mResponse.statusCode == 200) {
        ///write govt or company po
        var ref = await _firestore
            .collection(collection)
            .document(documentId)
            .collection('purchaseOrders')
            .add(purchaseOrder.toJson())
            .catchError((e) {
          print('DataAPI.registerPurchaseOrder ERROR $e');
          return '0';
        });

        ///write po to intended supplier
        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocId)
            .collection('purchaseOrders')
            .add(purchaseOrder.toJson())
            .catchError((e) {
          print('DataAPI.registerPurchaseOrder ERROR $e');
          return '0';
        });
        print(
            'DataAPI.registerPurchaseOrder document issuer path: ${ref.path}');
        print(
            'DataAPI.registerPurchaseOrder document supplier path: ${ref2.path}');
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

  Future _deleteFromFirestore(
      DocumentReference ref, DocumentReference ref2) async {
    await ref.delete();
    await ref2.delete();
    print('DataAPI._deleteFromFirestore record deleted: ${ref.documentID}');
    print('DataAPI._deleteFromFirestore record deleted: ${ref2.documentID}');
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

  Future<String> _addItem(PurchaseOrderItem item) async {
    item.itemId = getKey();

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ITEM));
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

  Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();
    String documentId, participantId, path, supplierDocId;
    if (deliveryNote.govtEntity != null) {
      participantId = deliveryNote.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
      documentId = await _getDocumentId(path, participantId);
      deliveryNote.govtDocumentRef = documentId;
    }
    if (deliveryNote.company != null) {
      participantId = deliveryNote.company.split('#').elementAt(1);
      path = 'companies';
      documentId = await _getDocumentId(path, participantId);
      deliveryNote.companyDocumentRef = documentId;
    }

    if (deliveryNote.supplier != null) {
      var id = deliveryNote.supplier.split('#').elementAt(1);
      supplierDocId = await _getDocumentId('suppliers', id);
      deliveryNote.supplierDocumentRef = supplierDocId;
    }

    prettyPrint(deliveryNote.toJson(), 'registerDeliveryNote ');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_DELIVERY_NOTE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(deliveryNote.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerDeliveryNote blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection(path)
            .document(documentId)
            .collection('deliveryNotes')
            .add(deliveryNote.toJson())
            .catchError((e) {
          print('DataAPI.registerDeliveryNote ERROR $e');
          return '0';
        });
        print('DataAPI.registerDeliveryNote added to Firestore: ${ref.path}');
        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocId)
            .collection('deliveryNotes')
            .add(deliveryNote.toJson())
            .catchError((e) {
          print('DataAPI.registerDeliveryNote ERROR $e');
          return '0';
        });
        print('DataAPI.registerDeliveryNote added to Firestore: ${ref2.path}');
        print(
            'DataAPI.registerDeliveryNote url: ${url + REGISTER_DELIVERY_NOTE}');
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

  Future<String> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    String documentRef, participantId, supplierDocRef, collection;
    if (invoice.govtEntity != null) {
      participantId = invoice.govtEntity.split('#').elementAt(1);
      collection = 'govtEntities';
      documentRef = await _getDocumentId(collection, participantId);
      invoice.govtDocumentRef = documentRef;
    }
    if (invoice.company != null) {
      participantId = invoice.company.split('#').elementAt(1);
      collection = 'companies';
      documentRef = await _getDocumentId(collection, participantId);
      invoice.companyDocumentRef = documentRef;
    }

    if (invoice.supplier != null) {
      var id = invoice.supplier.split('#').elementAt(1);
      supplierDocRef = await _getDocumentId('suppliers', id);
      invoice.supplierDocumentRef = supplierDocRef;
    }

    print('DataAPI.registerInvoice url: ${url + REGISTER_INVOICE}');
    prettyPrint(invoice.toJson(),
        'DataAPI.registerInvoice .. calling BFN via http(s) ...');
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(invoice.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.registerInvoice blockchain response status code:  ${mResponse
              .statusCode}');
      if (mResponse.statusCode == 200) {
        var ref = await _firestore
            .collection(collection)
            .document(documentRef)
            .collection('invoices')
            .add(invoice.toJson())
            .catchError((e) {
          print('DataAPI.registerInvoice  ERROR $e');
          return '0';
        });
        print('DataAPI.registerInvoice added to Firestore: ${ref.path}');
        invoice.documentReference = ref.documentID;

        var ref2 = await _firestore
            .collection('suppliers')
            .document(supplierDocRef)
            .collection('invoices')
            .add(invoice.toJson())
            .catchError((e) {
          print('DataAPI.registerInvoice  ERROR $e');
          return '0';
        });
        print('DataAPI.registerInvoice added to Firestore: ${ref2.path}');

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
      print('DataAPI.registerInvoice Firestore invoice deleted');
      return '0';
    }
  }

  Future<String> acceptDelivery(DeliveryAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    prettyPrint(acceptance.toJson(), 'DataAPI.acceptDelivery ....... ');

    print('DataAPI.acceptDelivery url: ${url + ACCEPT_DELIVERY}');
    prettyPrint(
        acceptance.toJson(), 'DataAPI.acceptDelivery ... calling BFN ...');
    try {
      Map map = acceptance.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ACCEPT_DELIVERY));
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

  Future mirrorDeliveryAcceptance(DeliveryAcceptance acceptance) async {
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
    print(
        'DataAPI.mirrorDeliveryAcceptance OWNER added to Firestore: ${ref.path}');
    print(
        'DataAPI.mirrorDeliveryAcceptance SUPPLIER added to Firestore: ${ref2.path}');
  }

  Future<String> acceptInvoice(InvoiceAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    prettyPrint(acceptance.toJson(), 'DataAPI.acceptInvoice ....... ');

    print('DataAPI.acceptInvoice url: ${url + ACCEPT_INVOICE}');
    prettyPrint(
        acceptance.toJson(), 'DataAPI.acceptInvoice ... calling BFN ...');
    try {
      Map map = acceptance.toJson();
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

  Future _mirrorInvoiceAcceptance(InvoiceAcceptance acceptance) async {
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
    print(
        'DataAPI._mirrorInvoiceAcceptance OWNER added to Firestore: ${ref2.path}');
    print(
        'DataAPI._mirrorInvoiceAcceptance SUPPLIER added to Firestore: ${ref.path}');
  }

  Future<String> makeOffer(Offer offer) async {
    offer.offerId = getKey();
    offer.date = new DateTime.now().toIso8601String();

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

    print('DataAPI.makeOffer  ${url + 'MakeOffer'}');
    prettyPrint(offer.toJson(), 'DataAPI.makeOffer offer: ');
    try {
      Map map = offer.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + 'MakeOffer'));
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

  Future _updateInvoiceWithOffer(
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
    prettyPrint(inv.toJson(), 'updated invoice on  Firestore');
  }

  Future<String> makeInvoiceBid(
      InvoiceBid bid, Offer offer, Investor investor) async {
    assert(offer.documentReference != null);
    assert(investor.documentReference != null);

    bid.invoiceBidId = getKey();
    bid.date = new DateTime.now().toIso8601String();

    print('DataAPI.makeInvoiceBid ${url + MAKE_INVOICE_BID}');
    try {
      Map map = bid.toJson();
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
        //add bid to investor's collection
        var ref0 = await _firestore
            .collection('investors')
            .document(investor.documentReference)
            .collection('invoiceBids')
            .add(bid.toJson())
            .catchError((e) {
          print('DataAPI.makeInvoiceBid ERROR $e');
          return '0';
        });
        //add bid to offer collection
        var ref = await _firestore
            .collection('invoiceOffers')
            .document(offer.documentReference)
            .collection('invoiceBids')
            .add(bid.toJson())
            .catchError((e) {
          print('DataAPI.makeInvoiceBid ERROR $e');
          return '0';
        });
        print('DataAPI.makeInvoiceBid added to Firestore: ${ref0.path}');
        print('DataAPI.makeInvoiceBid added to Firestore: ${ref.path}');

        bid.documentReference = ref.documentID;
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

  Future<String> selectInvoiceBid(InvoiceBid bid) async {
    return null;
  }

  Future<String> makeInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = new DateTime.now().toIso8601String();

    var investorId = settlement.investor.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('investors', investorId);
    var ref = await _firestore
        .collection('investors')
        .document(investorDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
      return '0';
    });

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);
    var ref2 = await _firestore
        .collection('suppliers')
        .document(supplierDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
      return '0';
    });
    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_INVESTOR_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvestorInvoiceSettlement blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return settlement.invoiceSettlementId;
      } else {
        _deleteFromFirestore(ref, ref2);
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
      _deleteFromFirestore(ref, ref2);
      print('DataAPI.makeInvestorInvoiceSettlement ERROR $e');
      return '0';
    }
  }

  Future<String> makeCompanyInvoiceSettlement(
      CompanyInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = new DateTime.now().toIso8601String();

    var investorId = settlement.company.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('companies', investorId);
    var ref = await _firestore
        .collection('companies')
        .document(investorDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    });

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);
    var ref2 = await _firestore
        .collection('suppliers')
        .document(supplierDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    });
    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_COMPANY_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeCompanyInvoiceSettlement blockchain response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return settlement.invoiceSettlementId;
      } else {
        _deleteFromFirestore(ref, ref2);
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
      _deleteFromFirestore(ref, ref2);
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    }
  }

  Future<String> makeGovtInvoiceSettlement(
      GovtInvoiceSettlement settlement) async {
    settlement.invoiceSettlementId = getKey();
    settlement.date = new DateTime.now().toIso8601String();

    var investorId = settlement.govtEntity.split('#').elementAt(1);
    var investorDocId = await _getDocumentId('govtEntities', investorId);
    var ref = await _firestore
        .collection('govtEntities')
        .document(investorDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    });

    var supplierId = settlement.supplier.split('#').elementAt(1);
    var supplierDocId = await _getDocumentId('suppliers', supplierId);
    var ref2 = await _firestore
        .collection('suppliers')
        .document(supplierDocId)
        .collection('invoiceSettlements')
        .add(settlement.toJson())
        .catchError((e) {
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
      return '0';
    });
    //write settlement to blockchain
    try {
      Map map = settlement.toJson();
      var mjson = json.encode(map);
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_GOVT_SETTLEMENT));
      mRequest.headers.contentType = _contentType;
      mRequest.write(mjson);
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeCompanyInvoiceSettlement blockchain response status code:  ${mResponse
              .statusCode}');
      if (mResponse.statusCode == 200) {
        return settlement.invoiceSettlementId;
      } else {
        _deleteFromFirestore(ref, ref2);
        print(
            'DataAPI.makeCompanyInvoiceSettlement ERROR - doc deleted from firestore');
        mResponse.transform(utf8.decoder).listen((contents) {
          print('DataAPI.makeCompanyInvoiceSettlement ERROR  $contents');
        });
        print('DataAPI.makeCompanyInvoiceSettlement ERROR  ${mResponse
                .reasonPhrase}');
        return '0';
      }
    } catch (e) {
      _deleteFromFirestore(ref, ref2);
      print('DataAPI.makeCompanyInvoiceSettlement ERROR $e');
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
