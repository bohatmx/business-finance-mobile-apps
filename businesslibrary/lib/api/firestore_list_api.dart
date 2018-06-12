import 'dart:async';

import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreListAPI {
  static final Firestore _firestore = Firestore.instance;

  static Future<List<PurchaseOrder>> getSupplierPurchaseOrders(
      Supplier supplier) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('purchaseOrders')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierPurchaseOrders  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierPurchaseOrders found ${list.length}');
    return list;
  }

  static Future<List<DeliveryNote>> getSupplierDeliveryNotes(
      Supplier supplier) async {
    List<DeliveryNote> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('deliveryNotes')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierDeliveryNotes  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new DeliveryNote.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierDeliveryNotes found ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getSupplierInvoices(Supplier supplier) async {
    List<Invoice> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('invoices')
        .orderBy('date')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierInvoices  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var invoice = new Invoice.fromJson(doc.data);
      list.add(invoice);
    });
    print('FirestoreListAPI.getSupplierPurchaseOrders found ${list.length}');
    return list;
  }

  static Future<List<GovtInvoiceSettlement>> getSupplierGovtSettlements(
      Supplier supplier) async {
    List<GovtInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('govtInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierGovtSettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new GovtInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print('FirestoreListAPI.getSupplierGovtSettlements found ${list.length}');
    return list;
  }

  static Future<List<CompanyInvoiceSettlement>> getSupplierCompanySettlements(
      Supplier supplier) async {
    List<CompanyInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('companyInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierCompanySettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new CompanyInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print(
        'FirestoreListAPI.getSupplierCompanySettlements found ${list.length}');
    return list;
  }

  static Future<List<InvestorInvoiceSettlement>> getSupplierInvestorSettlements(
      Supplier supplier) async {
    List<InvestorInvoiceSettlement> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplier.documentReference)
        .collection('investorInvoiceSettlements')
        .getDocuments()
        .catchError((e) {
      print('FirestoreListAPI.getSupplierInvestorSettlements  ERROR $e');
      return null;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new InvestorInvoiceSettlement.fromJson(doc.data);
      list.add(m);
    });
    print(
        'FirestoreListAPI.getSupplierInvestorSettlements found ${list.length}');
    return list;
  }
}
