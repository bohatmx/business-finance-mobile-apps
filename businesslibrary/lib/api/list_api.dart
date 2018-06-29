import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/wallet.dart';
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
    await SharedPrefs.saveWallet(wallet);
    return wallet;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByOffer(String offer) async {
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('offer', isEqualTo: offer)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return null;
    });

    print('ListAPI.getOfferInvoiceBids found: ${qs.documents.length} ');

    qs.documents.forEach((doc) async {
      list.add(new InvoiceBid.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByInvestor(
      String participantId) async {
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceBids')
        .where('participantId', isEqualTo: participantId)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorInvoiceBids $e');
      return null;
    });

    print('ListAPI.getInvestorInvoiceBids found: ${qs.documents.length} ');

    qs.documents.forEach((doc) async {
      list.add(new InvoiceBid.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Offer>> getOffersByPeriod(
      DateTime startTime, DateTime endTime) async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('date', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('date', isLessThanOrEqualTo: endTime.toIso8601String())
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierOffers $e');
      return null;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) async {
      list.add(new Offer.fromJson(doc.data));
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
      return null;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) async {
      list.add(new Offer.fromJson(doc.data));
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
      return null;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) async {
      list.add(new Offer.fromJson(doc.data));
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
      return null;
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
      return null;
    });
    print('ListAPI.getInvoices ............. ))))))) ${qs.documents.length}');
    qs.documents.forEach((doc) {
      list.add(new Invoice.fromJson(doc.data));
    });

    print('ListAPI.getInvoices ################## found: ${list.length}');
    return list;
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
      return null;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryNote.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
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
      return null;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print('ListAPI.getSupplierContracts ############ found: ${list.length}');
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
      return null;
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
      return null;
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
      return null;
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
      return null;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryAcceptance.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
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
      return null;
    });

    qs.documents.forEach((doc) {
      list.add(new Supplier.fromJson(doc.data));
    });

    print('ListAPI.getSuppliers ############ found: ${list.length}');
    return list;
  }
}
