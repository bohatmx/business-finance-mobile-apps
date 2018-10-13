import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Firestore _firestore = Firestore.instance;
Future<int> addDeliveryNoteToFirestore(DeliveryNote deliveryNote) async {
  var ref = await _firestore
      .collection('govtEntities')
      .document(deliveryNote.govtDocumentRef)
      .collection('deliveryNotes')
      .add(deliveryNote.toJson())
      .catchError((e) {
    print('DataAPI.registerDeliveryNote ERROR $e');
    return DataAPI3.FirestoreError;
  });
  print('DataAPI3.registerDeliveryNote added to Firestore: ${ref.path}');
  var ref2 = await _firestore
      .collection('suppliers')
      .document(deliveryNote.supplierDocumentRef)
      .collection('deliveryNotes')
      .add(deliveryNote.toJson())
      .catchError((e) {
    print('DataAPI3.registerDeliveryNote ERROR $e');
    return DataAPI3.FirestoreError;
  });
  print('DataAPI3.registerDeliveryNote added to Firestore: ${ref2.path}');
  return DataAPI3.Success;
}

Future<int> addPurchaseOrderToFirestore(PurchaseOrder purchaseOrder) async {
  ///write govt or company po
  var ref = await _firestore
      .collection('govtEntities')
      .document(purchaseOrder.govtDocumentRef)
      .collection('purchaseOrders')
      .add(purchaseOrder.toJson())
      .catchError((e) {
    print('DataAPI.registerPurchaseOrder ERROR $e');
    return DataAPI3.FirestoreError;
  });

  ///write po to intended supplier
  var ref2 = await _firestore
      .collection('suppliers')
      .document(purchaseOrder.supplierDocumentRef)
      .collection('purchaseOrders')
      .add(purchaseOrder.toJson())
      .catchError((e) {
    print('DataAPI.registerPurchaseOrder ERROR $e');
    return DataAPI3.FirestoreError;
  });
  print('DataAPI.registerPurchaseOrder document issuer path: ${ref.path}');
  print('DataAPI.registerPurchaseOrder document supplier path: ${ref2.path}');
  return DataAPI3.Success;
}

Future<int> addInvoiceToFirestore(Invoice invoice) async {
  var ref = await _firestore
      .collection('govtEntities')
      .document(invoice.govtDocumentRef)
      .collection('invoices')
      .add(invoice.toJson())
      .catchError((e) {
    print('DataAPI.registerInvoice  ERROR $e');
    return DataAPI3.FirestoreError;
  });
  print('DataAPI.registerInvoice added to Firestore: ${ref.path}');
  invoice.documentReference = ref.documentID;

  var ref2 = await _firestore
      .collection('suppliers')
      .document(invoice.supplierDocumentRef)
      .collection('invoices')
      .add(invoice.toJson())
      .catchError((e) {
    print('DataAPI.registerInvoice  ERROR $e');
    return DataAPI3.FirestoreError;
  });
  print('DataAPI.registerInvoice added to Firestore: ${ref2.path}');
  return DataAPI3.Success;
}
