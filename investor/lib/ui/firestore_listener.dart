import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OfferListener {
  onOffer(Offer offer);
}

abstract class BidListener {
  onInvoiceBid(InvoiceBid bid);
}

const SECONDS = 10;

void listenForOffer(OfferListener listener) async {
  print('\n\nistenForOffer ########## listening for Offers ........');
  CollectionReference reference =
      Firestore.instance.collection('invoiceOffers');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        var offer = Offer.fromJson(change.document.data);
        assert(offer != null);

        var now = DateTime.now().toUtc();
        var diff = now.difference(DateTime.parse(offer.date));
        if (diff.inSeconds < SECONDS) {
          print(
              'listenForOffer ====================> difference in Seconds: ${diff.inSeconds}, now in utc format: ${now.toIso8601String()}');
          print(
              '\n\n###################  listenForOffer - found freshman OFFER..${offer.offerAmount} on: ${offer.date}');
          listener.onOffer(offer);
        } else {
          print(
              'listenForOffer ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
        }
      }
    });
  });
}

void listenForBid(BidListener listener, String investorDocRef) async {
  print('\n\nistenForBid ########## listening for Bids ........');
  CollectionReference reference = Firestore.instance
      .collection('investors')
      .document(investorDocRef)
      .collection('invoiceBids');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        var bid = InvoiceBid.fromJson(change.document.data);
        assert(bid != null);

        var now = DateTime.now().toUtc();
        var diff = now.difference(DateTime.parse(bid.date));
        if (diff.inSeconds < SECONDS) {
          print(
              'listenForOffer ====================>  difference in Seconds: ${diff.inSeconds}, now in utc format: ${now.toIso8601String()}');
          print(
              '\n\n###################  listenForBid - found freshly done bid: ${bid.amount} on ${bid.date}');
          listener.onInvoiceBid(bid);
        } else {
          print(
              'listenForBid ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
        }
      }
    });
  });
}
