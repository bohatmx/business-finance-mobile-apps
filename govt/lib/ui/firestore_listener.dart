import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DeliveryNoteArrivedListener {
  onDeliveryNoteArrived(DeliveryNote po);
}

void listenForDeliveryNote(
    String govtDocRef, DeliveryNoteArrivedListener listener) async {
  print(
      '\nlistenForDeliveryNote ########## listening for DeliveryNote ........');
  CollectionReference reference = Firestore.instance
      .collection('govtEntities')
      .document(govtDocRef)
      .collection('deliveryNotes');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForDeliveryNote: change \n\n ${change.document.data} \n\n');
      var note = DeliveryNote.fromJson(change.document.data);
      assert(note != null);
      listener.onDeliveryNoteArrived(note);
    });
  });
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

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForInvoice: change \n\n ${change.document.data} \n\n');
      var note = Invoice.fromJson(change.document.data);
      assert(note != null);
      listener.onInvoiceArrived(note);
    });
  });
}
