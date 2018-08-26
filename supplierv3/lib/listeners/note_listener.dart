import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PurchaseOrderListener {
  onPurchaseOrder(PurchaseOrder po);
}

abstract class DeliveryAcceptanceListener {
  onDeliveryAcceptance(DeliveryAcceptance da);
}

abstract class InvoiceAcceptanceListener {
  onInvoiceAcceptance(InvoiceAcceptance ia);
}

void listenForPurchaseOrder(
    String supplierDocRef, PurchaseOrderListener listener) async {
  print(
      '\n\nlistenForPurchaseOrder ########## listening for Purchase Orders ........');
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('purchaseOrders');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForPurchaseOrder: change \n\n ${change.document.data} \n\n');
      var po = PurchaseOrder.fromJson(change.document.data);
      assert(po != null);
      listener.onPurchaseOrder(po);
    });
  });
}

void listenForDeliveryAcceptance(
    String supplierDocRef, DeliveryAcceptanceListener listener) async {
  print(
      '\n\listenForDeliveryAcceptance ########## listening for Delivery Acceptance ........');
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('deliveryAcceptances');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForDeliveryAcceptance: change \n\n ${change.document.data} \n\n');
      var da = DeliveryAcceptance.fromJson(change.document.data);
      assert(da != null);
      listener.onDeliveryAcceptance(da);
    });
  });
}

void listenForInvoiceAcceptance(
    String supplierDocRef, InvoiceAcceptanceListener listener) async {
  print(
      '\n\listenForInvoiceAcceptance ########## listening for InvoiceAcceptance ........');
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('invoiceAcceptances');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForInvoiceAcceptance: change \n\n ${change.document.data} \n\n');
      var ia = InvoiceAcceptance.fromJson(change.document.data);
      assert(ia != null);
      listener.onInvoiceAcceptance(ia);
    });
  });
}
