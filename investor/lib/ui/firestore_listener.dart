import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OfferListener {
  onOffer(Offer po);
}

const SECONDS = 30;

void listenForOffer(OfferListener listener) async {
  print('\n\listenForOffer ########## listening for Offers ........');
  CollectionReference reference =
      Firestore.instance.collection('invoiceOffers');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      if (change.type == DocumentChangeType.added) {
        var bid = Offer.fromJson(change.document.data);
        assert(bid != null);

        var now = DateTime.now();
        var diff = now.difference(DateTime.parse(bid.date));
        if (diff.inSeconds < SECONDS) {
          prettyPrint(bid.toJson(),
              '\n\n###################  listenForOffer  reference.snapshots().listen((querySnapshot) - found:');
          listener.onOffer(bid);
        } else {
          print(
              'listenForOffer ---------------------------------------- ignored, OLDER than $SECONDS secs ....');
        }
      }
    });
  });
}
