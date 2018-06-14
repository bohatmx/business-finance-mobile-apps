import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_offer.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
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
      REGISTER_INVOICE = 'RegisterInvoice',
      ACCEPT_DELIVERY = 'AcceptDelivery',
      MAKE_INVOICE_OFFER = 'MakeInvoiceOffer',
      MAKE_INVOICE_BID = 'MakeInvoiceBid',
      INVESTOR = 'Investor';
  static const ErrorFirestore = 1, ErrorBlockchain = 2, Success = 0;

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
      return ErrorFirestore;
    });
    print('DataAPI.addGovtEntity added to Firestore: ${ref.path}');

    govtEntity.documentReference = ref.documentID;
    print('DataAPI.addGovtEntity url: ${url + GOVT_ENTITY}');

    try {
      HttpClientRequest mRequest =
          await _httpClient.postUrl(Uri.parse(url + GOVT_ENTITY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(govtEntity.toJson()));

      HttpClientResponse resp = await mRequest.close();
      print('DataAPI.addGovtEntity resp.statusCode: ${resp.statusCode} \n ${resp
              .headers}');
      if (resp.statusCode == 200) {
        return govtEntity.participantId;
      } else {
        print('DataAPI.addGovtEntity ERROR  ${resp.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addGovtEntity ERROR $e');
      return '0';
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
    try {
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
    } catch (e) {
      print('DataAPI.addUser ERROR $e');
      return '0';
    }
  }

  /// Stellar wallet already in firestore? YES.
  /// object should contain valid Stellar public key
  ///
  Future<String> addWallet(Wallet wallet) async {
    try {
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
    } catch (e) {
      print('DataAPI.addGovtEntity ERROR $e');
      return '0';
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
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + COMPANY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(company.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addCompany response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return company.participantId;
      } else {
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
    var ref = await _firestore
        .collection('suppliers')
        .add(supplier.toJson())
        .catchError((e) {
      print('DataAPI.addSupplier ERROR adding to Firestore $e');
      return '0';
    });
    print('DataAPI.addSupplier added to Firestore: ${ref.documentID}');
    supplier.documentReference = ref.documentID;

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + SUPPLIER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(supplier.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addSupplier response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return supplier.participantId;
      } else {
        print('DataAPI.addSupplier ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addSupplier ERROR $e');
      return '0';
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
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + INVESTOR));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(investor.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addInvestor response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return investor.participantId;
      } else {
        print('DataAPI.addInvestor ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.addInvestor ERROR $e');
      return '0';
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
    try {
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
    } catch (e) {
      print('DataAPI.addBank ERROR $e');
      return '0';
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
    try {
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
    } catch (e) {
      print('DataAPI.addOneConnect ERROR $e');
      return '0';
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

    try {
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
    } catch (e) {
      print('DataAPI.addProcurementOffice ERROR $e');
      return '0';
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

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + AUDITOR));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(auditor.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.addAuditor response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return auditor.participantId;
      } else {
        print('DataAPI.addAuditor ERROR  ${mResponse.reasonPhrase}');
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
    purchaseOrder.purchaseOrderId = getKey();
    String participantId,
        collection,
        documentId,
        supplierDocumentId,
        userDocumentId;
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
      supplierDocumentId = purchaseOrder.supplierDocumentRef;
    }
    if (purchaseOrder.user != null) {
      var strings = purchaseOrder.user.split("#");
      participantId = strings.elementAt(1);
      userDocumentId = await _getDocumentId('users', participantId);
    }

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
        .document(supplierDocumentId)
        .collection('purchaseOrders')
        .add(purchaseOrder.toJson())
        .catchError((e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return '0';
    });
    print('DataAPI.registerPurchaseOrder document issuer path: ${ref.path}');
    print('DataAPI.registerPurchaseOrder document supplier path: ${ref2.path}');
    purchaseOrder.documentReference = ref.documentID;
    purchaseOrder.supplierDocumentRef = ref2.documentID;

    ///write to blockchain
    ///
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_PURCHASE_ORDER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(purchaseOrder.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print('DataAPI.registerPurchaseOrder response status code:  ${mResponse
              .statusCode}');
      if (mResponse.statusCode == 200) {
        return purchaseOrder.purchaseOrderId;
      } else {
        print('DataAPI.registerPurchaseOrder ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.registerPurchaseOrder ERROR $e');
      return '0';
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

    try {
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
    } catch (e) {
      print('DataAPI.addItem ERROR $e');
      return '0';
    }
  }

  Future<String> registerDeliveryNote(DeliveryNote deliveryNote) async {
    deliveryNote.deliveryNoteId = getKey();
    String documentId, participantId, path;
    if (deliveryNote.govtEntity != null) {
      participantId = deliveryNote.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
    }
    if (deliveryNote.company != null) {
      participantId = deliveryNote.company.split('#').elementAt(1);
      path = 'companies';
    }
    documentId = await _getDocumentId(path, participantId);
    String orderId = deliveryNote.purchaseOrder.split("#").elementAt(1);
    String poDocumentId;
    var querySnap = await _firestore
        .collection(path)
        .document(documentId)
        .collection('purchaseOrders')
        .where('purchaseOrderId', isEqualTo: orderId)
        .getDocuments();
    querySnap.documents.forEach((snap) {
      poDocumentId = snap.documentID;
    });

    if (poDocumentId == null) {
      return '0';
    }
    var ref = await _firestore
        .collection(path)
        .document(documentId)
        .collection('purchaseOrders')
        .document(poDocumentId)
        .collection('deliveryNotes')
        .add(deliveryNote.toJson())
        .catchError((e) {
      print('DataAPI.registerDeliveryNote ERROR $e');
      return '0';
    });
    print('DataAPI.registerDeliveryNote added to Firestore: ${ref.path}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_DELIVERY_NOTE));
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
    } catch (e) {
      print('DataAPI.registerDeliveryNote ERROR $e');
      return '0';
    }
  }

  Future<String> registerInvoice(Invoice invoice) async {
    invoice.invoiceId = getKey();
    String documentId, participantId, supplierDocRef, supplierId, path;
    if (invoice.govtEntity != null) {
      participantId = invoice.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
    }
    if (invoice.company != null) {
      participantId = invoice.company.split('#').elementAt(1);
      path = 'companies';
    }
    if (invoice.supplier != null) {
      supplierId = invoice.supplier.split('#').elementAt(1);
      var path = 'suppliers';
      var qs = await _firestore
          .collection(path)
          .where('participantId', isEqualTo: supplierId)
          .getDocuments()
          .catchError((e) {
        print('DataAPI.registerInvoice ERROR $e');
        return '0';
      });
      qs.documents.forEach((doc) {
        supplierDocRef = doc.documentID;
      });
    }
    documentId = await _getDocumentId(path, participantId);
    var ref = await _firestore
        .collection(path)
        .document(documentId)
        .collection('invoices')
        .add(invoice.toJson())
        .catchError((e) {
      print('DataAPI.registerInvoice  ERROR $e');
      return '0';
    });
    print('DataAPI.registerInvoice added to Firestore: ${ref.path}');
    invoice.documentReference = ref.documentID;
    invoice.supplierDocumentRef = supplierDocRef;

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + REGISTER_INVOICE));
      mRequest.headers.contentType = _contentType;
      mRequest.write(json.encode(invoice.toJson()));
      HttpClientResponse mResponse = await mRequest.close();
      print('DataAPI.registerInvoice response status code:  ${mResponse
              .statusCode}');
      if (mResponse.statusCode == 200) {
        return invoice.invoiceId;
      } else {
        print('DataAPI.registerInvoice ERROR  ${mResponse.reasonPhrase}');
        return "0";
      }
    } catch (e) {
      print('DataAPI.registerInvoice ERROR $e');
      return '0';
    }
  }

  Future<String> acceptDelivery(DeliveryAcceptance acceptance) async {
    acceptance.acceptanceId = getKey();
    String documentId, participantId, path, supplierDocRef, supplierId;
    if (acceptance.govtEntity != null) {
      participantId = acceptance.govtEntity.split('#').elementAt(1);
      path = 'govtEntities';
    }
    if (acceptance.company != null) {
      participantId = acceptance.company.split('#').elementAt(1);
      path = 'companies';
    }
    if (acceptance.supplier != null) {
      supplierId = acceptance.supplier.split('#').elementAt(1);
      var path = 'suppliers';
      var qs = await _firestore
          .collection(path)
          .where('participantId', isEqualTo: supplierId)
          .getDocuments()
          .catchError((e) {
        print('DataAPI.acceptDelivery ERROR $e');
        return '0';
      });
      qs.documents.forEach((doc) {
        supplierDocRef = doc.documentID;
      });
    }
    documentId = await _getDocumentId(path, participantId);
    var ref = await _firestore
        .collection(path)
        .document(documentId)
        .collection('deliveryAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI.acceptDelivery  ERROR $e');
      return '0';
    });
    var ref2 = await _firestore
        .collection('suppliers')
        .document(supplierDocRef)
        .collection('deliveryAcceptances')
        .add(acceptance.toJson())
        .catchError((e) {
      print('DataAPI.acceptDelivery  ERROR $e');
      return '0';
    });
    print('DataAPI.acceptDelivery OWNER added to Firestore: ${ref.path}');
    print('DataAPI.acceptDelivery SUPPLIER added to Firestore: ${ref2.path}');

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + ACCEPT_DELIVERY));
      mRequest.headers.contentType = _contentType;
      mRequest.write(acceptance.toJson());
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.acceptDelivery response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return acceptance.acceptanceId;
      } else {
        print('DataAPI.acceptDelivery ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.acceptDelivery ERROR $e');
      return '0';
    }
  }

  Future<String> makeInvoiceOffer(InvoiceOffer offer) async {
    var ref = await _firestore
        .collection('invoiceOffers')
        .add(offer.toJson())
        .catchError((e) {
      print('DataAPI.makeInvoiceOffer ERROR $e');
      return '0';
    });
    print('DataAPI.makeInvoiceOffer added to Firestore: ${ref.path}');

    offer.invoiceOfferId = getKey();
    offer.documentReference = ref.documentID;

    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_INVOICE_OFFER));
      mRequest.headers.contentType = _contentType;
      mRequest.write(offer.toJson());
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvoiceOffer response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return offer.invoiceOfferId;
      } else {
        print('DataAPI.makeInvoiceOffer ERROR  ${mResponse.reasonPhrase}');
        return '0';
      }
    } catch (e) {
      print('DataAPI.makeInvoiceOffer ERROR $e');
      return '0';
    }
  }

  Future<String> makeInvoiceBid(InvoiceBid bid, InvoiceOffer offer) async {
    var ref = await _firestore
        .collection('invoiceOffers')
        .document(offer.documentReference)
        .collection('invoiceBids')
        .add(bid.toJson())
        .catchError((e) {
      print('DataAPI.makeInvoiceBid ERROR $e');
      return '0';
    });
    print('DataAPI.makeInvoiceBid added to Firestore: ${ref.path}');

    bid.invoiceBidId = getKey();
    bid.documentReference = ref.documentID;
    try {
      var httpClient = new HttpClient();
      HttpClientRequest mRequest =
          await httpClient.postUrl(Uri.parse(url + MAKE_INVOICE_BID));
      mRequest.headers.contentType = _contentType;
      mRequest.write(bid.toJson());
      HttpClientResponse mResponse = await mRequest.close();
      print(
          'DataAPI.makeInvoiceBid response status code:  ${mResponse.statusCode}');
      if (mResponse.statusCode == 200) {
        return bid.invoiceBidId;
      } else {
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
    return null;
  }

  Future<String> makeCustomerInvoiceSettlement(
      CompanyInvoiceSettlement settlement) async {
    return null;
  }

  static String getKey() {
    var uuid = new Uuid();
    String key = uuid.v1();
    print('DataAPI.getKey key generated: $key');
    return key;
  }
}
