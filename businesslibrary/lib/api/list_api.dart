import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListAPI {
  static final Firestore _firestore = Firestore.instance;

  static Future<Wallet> getWallet(String ownerType, String name) async {
    print('ListAPI.getWallet ownerType: $ownerType name: $name');
    var qs = await _firestore
        .collection('wallets')
        .where(ownerType, isEqualTo: name)
        .getDocuments();
    Wallet wallet = Wallet.fromJson(qs.documents.first.data);
    if (wallet.secret == null) {
      var decrypted =
          await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
      wallet.secret = decrypted;
    }
    await SharedPrefs.saveWallet(wallet);
    return wallet;
  }

  static Future<List<User>> getGovtUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.govtEntity != null) {
        list.add(user);
      }
    });
    print('ListAPI.getGovtUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getInvestorUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.investor != null) {
        list.add(user);
      }
    });
    print('ListAPI.getInvestorUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getSupplierUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.supplier != null) {
        list.add(user);
      }
    });
    print('ListAPI.getSupplierUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getUsers() async {
    List<User> list = List();
    var qs =
        await _firestore.collection('users').getDocuments().catchError((e) {
      print('ListAPI.getUsers $e');
      return list;
    });
    print(
        'ListAPI.getUsers ########## found in QuerySnapshot: ${qs.documents.length} ');
    qs.documents.forEach((doc) {
      list.add(new User.fromJson(doc.data));
    });

    print('ListAPI.getUsers ########## found in list: ${list.length} ');
    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByOffer(Offer offer) async {
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .document(offer.documentReference)
        .collection('invoiceBids')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return list;
    });

    print('ListAPI.getOfferInvoiceBids found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvoiceBid.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByInvestor(
      String documentReference) async {
    print(
        'ListAPI.getInvoiceBidsByInvestor ========= documentReference: $documentReference');
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('investors')
        .document(documentReference)
        .collection('invoiceBids')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorInvoiceBids $e');
      return list;
    });

    print('ListAPI.getInvestorInvoiceBids found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvoiceBid.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidByInvestorOffer(
      Offer offer, Investor investor) async {
    //resource:com.oneconnect.biz.Investor#4cdc2c70-9620-11e8-c714-174858cf9948
    //resource:com.oneconnect.biz.Offer#6a4819c0-9620-11e8-fac2-c919ce809955

    print(
        'ListAPI.getInvoiceBidByInvestorOffer =======> offer.documentReference: ${offer.documentReference} offer.offerId: ${offer.offerId} participantId: ${investor.participantId}');
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .document(offer.documentReference)
        .collection('invoiceBids')
        .where('offer',
            isEqualTo: 'resource:com.oneconnect.biz.Offer#${offer.offerId}')
        .where('investor',
            isEqualTo:
                'resource:com.oneconnect.biz.Investor#${investor.participantId}')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceBidByInvestorOffer $e');
      return list;
    });

    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer: qs.documents iisEmpty ----------');
    } else {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer - we have a docuumentt here!!!!!!!');
    }
    qs.documents.forEach((doc) {
      print('########## EACH doc.data:  ${doc.data}');
      var invoiceBid = InvoiceBid.fromJson(doc.data);
      invoiceBid.documentReference = doc.documentID;
      list.add(invoiceBid);
      prettyPrint(invoiceBid.toJson(),
          '%%%%% invoice  bid after json, bids in list: ${list.length}');
    });
    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found objects: ${list.length} ');
    return list;
  }

  static Future<OfferBag> getOfferById(String id) async {
    Offer offer;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('offerId', isEqualTo: id)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });
    print('ListAPI.getOfferById found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    offer = Offer.fromJson(qs.documents.first.data);

    var qs1 = await _firestore
        .collection('invoiceOffers')
        .document(qs.documents.first.documentID)
        .collection('invoiceBids')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });

    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print('ListAPI.getOfferById found invoice bids: ${qs1.documents.length} ');
    var bag = OfferBag(offer: offer, invoiceBids: bids);
    return bag;
  }

  static Future<OfferBag> getOfferByInvoice(String invoiceId) async {
    Offer offer;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('invoice',
            isEqualTo: 'resource:com.oneconnect.biz.Invoice#$invoiceId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });
    print(
        'ListAPI.getOfferByInvoice ++++++++++++++++ found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    offer = Offer.fromJson(qs.documents.first.data);

    var qs1 = await _firestore
        .collection('invoiceOffers')
        .document(qs.documents.first.documentID)
        .collection('invoiceBids')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });

    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print(
        'ListAPI.getOfferByInvoice @@@@@@@@@@@@@ found invoice bids: ${qs1.documents.length} ');

    var bag = OfferBag(offer: offer, invoiceBids: bids);
    bag.doPrint();
    return bag;
  }

  static Future<List<Offer>> getOffersByPeriod(
      DateTime startTime, DateTime endTime) async {
    print(
        'ListAPI.getOffersByPeriod startTime: ${startTime.toIso8601String()}  endTime: ${endTime.toIso8601String()}');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('startTime', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('startTime', isLessThanOrEqualTo: endTime.toIso8601String())
        .orderBy('startTime', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersByPeriod $e');
      return list;
    });
    print('ListAPI.getOffersByPeriod found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return list;
    }
    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySector(
      String privateSectorType, DateTime startTime, DateTime endTime) async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('date', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('date', isLessThanOrEqualTo: endTime.toIso8601String())
        .where('privateSectorType', isEqualTo: privateSectorType)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierOffers $e');
      return list;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySupplier(String supplierId) async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('participantId', isEqualTo: supplierId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierOffers $e');
      return list;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOpenOffers() async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('isOpen', isEqualTo: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOpenOffers $e');
      return list;
    });

    print(
        'ListAPI.getOpenOffers +++++++ offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<PurchaseOrder>> getPurchaseOrders(
      String documentId, String collection) async {
    print(
        'ListAPI.getPurchaseOrders  ..........documentId: $documentId...........');
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('purchaseOrders')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print('ListAPI.getPurchaseOrders &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<List<Invoice>> getInvoices(
      String documentId, String collection) async {
    print('ListAPI.getInvoices ............. documentId: $documentId');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoices $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoices - no docs found');
      return list;
    }
    qs.documents.forEach((doc) {
      list.add(new Invoice.fromJson(doc.data));
    });

    print('ListAPI.getInvoices ################## found: ${list.length}');
    list.forEach((inv) {
      prettyPrint(
          inv.toJson(), 'getInvoices, INVOICE NUMBER: ${inv.invoiceNumber}');
    });
    return list;
  }

  static Future<List<Invoice>> getInvoicesOpenForOffers(
      String documentId, String collection) async {
    print(
        'ListAPI.getInvoicesOpenForOffers ............. documentId: $documentId in $collection');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('offer', isNull: true)
        .orderBy('date', descending: true)
        .limit(100)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOpenForOffers $e');
      return list;
    });

    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOpenForOffers - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOpenForOffers ################## found: ${list.length}');
    list.forEach((inv) {
      prettyPrint(inv.toJson(),
          'getInvoicesOpenForOffers INVOICE NUMBER: ${inv.invoiceNumber}');
    });
    return list;
  }

  static Future<List<Invoice>> getInvoicesOnOffer(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesOnOffer ............. documentId: $documentId');
    //type '(dynamic) => List<Invoice>' is not a subtype of type '(Object) => FutureOr<QuerySnapshot>'
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('offer', isGreaterThan: '')
//        .orderBy('date', descending: true)
        .limit(100)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOnOffer $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOnOffer - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getInvoicesSettled(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesSettled ............. documentId: $documentId');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('isSettled', isEqualTo: 'true')
        .orderBy('date', descending: true)
        .limit(1000)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesSettled $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesSettled - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    list.forEach((inv) {
      prettyPrint(inv.toJson(),
          'getInvoicesSettled INVOICE NUMBER: ${inv.invoiceNumber}');
    });
    return list;
  }

  static Future<Invoice> getInvoice(
      String poNumber, String invoiceNumber, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoice ............. poNumber: $poNumber invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('purchaseOrderNumber', isEqualTo: poNumber)
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoice $e');
      return null;
    });
    print('ListAPI.getInvoice ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<List<Invoice>> getInvoicesByPurchaseOrder(
      String purchaseOrderId, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoicesByPurchaseOrder ............. deliveryNoteId: $purchaseOrderId  ');
    List<Invoice> invoices = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('purchaseOrder',
            isEqualTo:
                'resource:com.oneconnect.biz.PurchaseOrder#$purchaseOrderId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesByPurchaseOrder $e');
      return invoices;
    });
    print(
        'ListAPI.getInvoicesByPurchaseOrder ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        var invoice = Invoice.fromJson(doc.data);
        invoice.documentReference = qs.documents.first.documentID;
        invoices.add(invoice);
      });
    }

    return invoices;
  }

  static Future<Invoice> getInvoiceByDeliveryNote(
      String deliveryNoteId, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoiceByDeliveryNote ............. deliveryNoteId: $deliveryNoteId  ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('deliveryNote',
            isEqualTo:
                'resource:com.oneconnect.biz.DeliveryNote#$deliveryNoteId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceByDeliveryNote $e');
      return null;
    });
    print(
        'ListAPI.getInvoiceByDeliveryNote ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Invoice> getSupplierInvoiceByNumber(
      String invoiceNumber, String supplierDocumentRef) async {
    print(
        'ListAPI.getSupplierInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getSupplierInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Invoice> getGovtInvoiceByNumber(
      String invoiceNumber, String govtDocumentRef) async {
    print(
        'ListAPI.getGovtInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('govtEntities')
        .document(govtDocumentRef)
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getGovtInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Offer> findOfferByInvoice(String invoice) async {
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('invoice',
            isEqualTo: 'resource:com.oneconnect.biz.Invoice#$invoice')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    if (qs.documents.isNotEmpty) {
      var offer = Offer.fromJson(qs.documents.first.data);
      return offer;
    } else {
      return null;
    }
  }

  static Future<List<DeliveryNote>> getDeliveryNotes(
      String documentId, String collection) async {
    print('ListAPI.getDeliveryNotes .......  documentId: $documentId');
    List<DeliveryNote> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryNotes')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNotes $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryNote.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryNote> getDeliveryNoteById(
      String deliveryNoteId, String documentId, String collection) async {
    print(
        'ListAPI.getDeliveryNoteById .......  documentId: $documentId deliveryNoteId: $deliveryNoteId');
    DeliveryNote dn;
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryNotes')
        .where('deliveryNoteId', isEqualTo: deliveryNoteId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNoteById $e');
      return dn;
    });

    if (qs.documents.isNotEmpty) {
      dn = DeliveryNote.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryNoteById ############ found: ${qs.documents.length}');
    return dn;
  }

  static Future<List<SupplierContract>> getSupplierContracts(
      String supplierDocumentRef) async {
    print(
        'ListAPI.getSupplierContracts .......  documentId: $supplierDocumentRef');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print('ListAPI.getSupplierContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<SupplierContract>> getSupplierGovtContracts(
      String supplierDocumentRef, String govtEntity) async {
    print(
        'ListAPI.getSupplierGovtContracts .......  supplierDocumentRef: $supplierDocumentRef govtEntity: $govtEntity');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .where('govtEntity', isEqualTo: govtEntity)
//        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierGovtContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print(
        'ListAPI.getSupplierGovtContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<SupplierContract>> getSupplierCompanyContracts(
      String supplierDocumentRef, String participantId) async {
    print(
        'ListAPI.getSupplierCompanyContracts .......  documentId: $supplierDocumentRef');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .where('company',
            isEqualTo: 'resource:com.oneconnect.biz.Company#$participantId}')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierCompanyContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print(
        'ListAPI.getSupplierCompanyContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<GovtEntity>> getGovtEntitiesByCountry(
      String country) async {
    print('ListAPI.getGovtEntities .......  country: $country');
    List<GovtEntity> list = List();
    var qs = await _firestore
        .collection('govtEntities')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtEntities $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new GovtEntity.fromJson(doc.data));
    });

    print('ListAPI.getGovtEntities ############ found: ${list.length}');
    return list;
  }

  static Future<List<Supplier>> getSuppliersByCountry(String country) async {
    print('ListAPI.getSuppliersByCountry .......  country: $country');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSuppliersByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Supplier.fromJson(doc.data));
    });

    print('ListAPI.getSuppliersByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<Company>> getCompaniesByCountry(String country) async {
    print('ListAPI.getCompaniesByCountry .......  country: $country');
    List<Company> list = List();
    var qs = await _firestore
        .collection('companies')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCompaniesByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Company.fromJson(doc.data));
    });

    print('ListAPI.getCompaniesByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<DeliveryAcceptance>> getDeliveryAcceptances(
      String documentId, String collection) async {
    print('ListAPI.getDeliveryAcceptances .......  documentId: $documentId');
    List<DeliveryAcceptance> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryAcceptances')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptances $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryAcceptance.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryAcceptance> getDeliveryAcceptanceForNote(
      String deliveryNoteId, String documentId, String collection) async {
    print(
        'ListAPI.getDeliveryAcceptanceForNote .......  documentId: $documentId deliveryNoteId: $deliveryNoteId');
    DeliveryAcceptance da;

    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryAcceptances')
        .where('deliveryNote',
            isEqualTo:
                'resource:com.oneconnect.biz.DeliveryNote#$deliveryNoteId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptanceForNote $e');
      return da;
    });

    if (qs.documents.isNotEmpty) {
      da = DeliveryAcceptance.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryAcceptanceForNote ############ found: ${qs.documents.length}');
    return da;
  }

  static Future<List<Supplier>> getSuppliers() async {
    print('ListAPI.getSuppliers .......  ');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSuppliers $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Supplier.fromJson(doc.data));
    });

    print('ListAPI.getSuppliers ############ found: ${list.length}');
    return list;
  }

  static Future<List<InvestorProfile>> getInvestorProfiles() async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorProfiles $e');
      return list;
    });

    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        list.add(new InvestorProfile.fromJson(doc.data));
      });
    }

    print('ListAPI.getInvestorProfiles ############ found: ${list.length}');
    return list;
  }

  static Future<List<AutoTradeOrder>> getAutoTradeOrders() async {
    List<AutoTradeOrder> list = List();
    var qs = await _firestore
        .collection('autoTradeOrders')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeOrders $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new AutoTradeOrder.fromJson(doc.data));
    });

    print('ListAPI.getAutoTradeOrders ############ found: ${list.length}');
    return list;
  }

  static Future<List<PrivateSectorType>> getPrivateSectorTypes() async {
    List<PrivateSectorType> list = List();
    var qs = await _firestore
        .collection('privateSectorTypes')
        .orderBy('type')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPrivateSectorTypes $e');
      return list;
    });

    print('ListAPI.getPrivateSectorTypes found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new PrivateSectorType.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvestorProfile>> getProfile(String participantId) async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .where('investor',
            isEqualTo: 'resource:com.oneconnect.biz.Investor#$participantId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getProfile $e');
      return list;
    });

    print('ListAPI.getProfile found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvestorProfile.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Sector>> getSectors() async {
    List<Sector> list = List();
    var qs = await _firestore
        .collection('sectors')
        .orderBy('sectorName')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSectors $e');
      return list;
    });

    print('ListAPI.getSectors found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Sector.fromJson(doc.data));
    });

    return list;
  }
}

class OfferBag {
  Offer offer;
  List<InvoiceBid> invoiceBids = List();

  OfferBag({this.offer, this.invoiceBids});
  doPrint() {
    prettyPrint(offer.toJson(), '######## OFFER:');
    invoiceBids.forEach((m) {
      prettyPrint(m.toJson(), '%%%%%%%%% BID:');
    });
  }
}
