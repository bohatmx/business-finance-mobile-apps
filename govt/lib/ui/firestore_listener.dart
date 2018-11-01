import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DeliveryNoteArrivedListener {
  onDeliveryNoteArrived(DeliveryNote po);
}

const SECONDS = 30;
void listenForDeliveryNote(
    String govtDocRef, DeliveryNoteArrivedListener listener) async {
  print(
      '\nlistenForDeliveryNote ########## listening for DeliveryNote ........');
  CollectionReference reference = Firestore.instance
      .collection('govtEntities')
      .document(govtDocRef)
      .collection('deliveryNotes');
//
//  reference.snapshots().listen((querySnapshot) {
//    querySnapshot.documentChanges.forEach((change) {
//      if (change.type == DocumentChangeType.added) {
//        var note = DeliveryNote.fromJson(change.document.data);
//        assert(note != null);
//
//        var now = DateTime.now();
//        var diff = now.difference(DateTime.parse(note.date));
//        if (diff.inSeconds < SECONDS) {
//          prettyPrint(note.toJson(),
//              '\n\n###################  listenForDeliveryNote  reference.snapshots().listen((querySnapshot) - found:');
//          listener.onDeliveryNoteArrived(note);
//        } else {
//          print(
//              'listenForDeliveryNote ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
//        }
//      }
//    });
//  });
}

abstract class InvoiceArrivedListener {
  onInvoiceArrived(Invoice inv);
}

void listenForInvoice(
    String govtDocRef, InvoiceArrivedListener listener) async {
  print('\listenForInvoice ########## listening for Invoice ........');
  CollectionReference reference = Firestore.instance
      .collection('govtEntities')
      .document(govtDocRef)
      .collection('invoices');

//  reference.snapshots().listen((querySnapshot) {
//    querySnapshot.documentChanges.forEach((change) {
//      if (change.type == DocumentChangeType.added) {
//        var inv = Invoice.fromJson(change.document.data);
//        assert(inv != null);
//
//        var now = DateTime.now();
//        var diff = now.difference(DateTime.parse(inv.date));
//        if (diff.inSeconds < SECONDS) {
//          prettyPrint(inv.toJson(),
//              '\n\n###### listenForInvoice: change type is ADDED');
//          listener.onInvoiceArrived(inv);
//        } else {
//          print(
//              'listenForInvoice ----------------------------- ignored, OLDER than $SECONDS secs ....');
//        }
//      }
//    });
//  });
}
