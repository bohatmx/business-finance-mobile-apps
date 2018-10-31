import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
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

const SECONDS = 30;

void listenForPurchaseOrder(
    String supplierDocRef, PurchaseOrderListener listener) async {
  print(
      '\n\nlistenForPurchaseOrder ########## listening for Purchase Orders ........\n\n');
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('purchaseOrders');

//  try {
//    reference.snapshots().listen((querySnapshot) {
//      querySnapshot.documentChanges.forEach((change) {
//        if (change.type == DocumentChangeType.added) {
//          var po = PurchaseOrder.fromJson(querySnapshot.documents.last.data);
//          assert(po != null);
////          print('listenForPurchaseOrder date: ${po.date}');
//          var now = DateTime.now();
//          var diff = now.difference(DateTime.parse(po.date));
//          if (diff.inSeconds < SECONDS) {
////            prettyPrint(po.toJson(),
////                '\n\n###################  listenForPurchaseOrder  reference.snapshots().listen((querySnapshot) - found:');
//            listener.onPurchaseOrder(po);
//          } else {
////            print(
////                'listenForPurchaseOrder ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
//          }
//        }
//      });
//    });
//  } catch (e) {
//    print(e);
//  }
}

void listenForDeliveryAcceptance(
    String supplierDocRef, DeliveryAcceptanceListener listener) async {
  print(
      '\n\n listenForDeliveryAcceptance ########## listening for Delivery Acceptance ........\n\n');
  //suppliers/-LMnSqQ1v9XiF936BJC-/deliveryAcceptances/-LMnSqQ1v9XiF936BJC0
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('deliveryAcceptances');
//
//  reference.snapshots().listen((querySnapshot) {
//    querySnapshot.documentChanges.forEach((change) {
//      if (change.type == DocumentChangeType.added) {
//        var da = DeliveryAcceptance.fromJson(change.document.data);
//        assert(da != null);
//
////        var now = DateTime.now();
////        var diff = now.difference(DateTime.parse(da.date));
////        if (diff.inSeconds < SECONDS) {
////          prettyPrint(da.toJson(),
////              '\n\n###################  listenForDeliveryAcceptance  reference.snapshots().listen((querySnapshot) - found:');
////          listener.onDeliveryAcceptance(da);
////        } else {
////          print(
////              'listenForDeliveryAcceptance ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
////        }
//      }
//    });
//  });
}

void listenForInvoiceAcceptance(
    String supplierDocRef, InvoiceAcceptanceListener listener) async {
//  print(
//      '\n\nlistenForInvoiceAcceptance ########## listening for InvoiceAcceptance ........\n\n');
  CollectionReference reference = Firestore.instance
      .collection('suppliers')
      .document(supplierDocRef)
      .collection('invoiceAcceptances');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        var ia = InvoiceAcceptance.fromJson(change.document.data);
        assert(ia != null);

        var now = DateTime.now();
        var diff = now.difference(DateTime.parse(ia.date));
        if (diff.inSeconds < SECONDS) {
//          prettyPrint(ia.toJson(),
//              '\n\n###################  listenForInvoiceAcceptance  reference.snapshots().listen((querySnapshot) - found:');
          listener.onInvoiceAcceptance(ia);
        } else {
//          print(
//              'listenForInvoiceAcceptance ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
        }
      }
    });
  });
}

abstract class InvoiceBidListener {
  onInvoiceBid(InvoiceBid bid);
}

void listenForInvoiceBid(String offerId, InvoiceBidListener listener) async {
  var qs = await Firestore.instance
      .collection('invoiceOffers')
      .where('offerId', isEqualTo: offerId)
      .getDocuments();
  if (qs.documents.isEmpty) {
    return;
  }
  String offerDocRef = qs.documents.first.documentID;
  var offer = Offer.fromJson(qs.documents.first.data);

//  print(
//      '\n\n listenForInvoiceBid ########## listening for Invoice Bids .......: offerId: $offerId  ....');
  //prettyPrint(offer.toJson(), '###### Listening for bids for this OFFER:');
  CollectionReference reference = Firestore.instance
      .collection('invoiceOffers')
      .document(offerDocRef)
      .collection('invoiceBids');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        var bid = InvoiceBid.fromJson(change.document.data);
        assert(bid != null);

        var now = DateTime.now();
        var diff = now.difference(DateTime.parse(bid.date));
        if (diff.inSeconds < SECONDS) {
//          prettyPrint(bid.toJson(),
//              '\n\n###################  listenForInvoiceBid  reference.snapshots().listen((querySnapshot) - found:');
          listener.onInvoiceBid(bid);
        } else {
//          print(
//              'listenForInvoiceBid ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
        }
      }
    });
  });
}
