import 'package:businesslibrary/data/offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OfferListener {
  onOffer(Offer po);
}

void listenForOffer(OfferListener listener) async {
  print('\n\listenForOffer ########## listening for Offers ........');
  CollectionReference reference =
      Firestore.instance.collection('invoiceOffers');

  reference.snapshots().listen((querySnapshot) {
    querySnapshot.documentChanges.forEach((change) {
      print(
          '\n\n###### listenForOffer: change \n\n ${change.document.data} \n\n');
      var offer = Offer.fromJson(change.document.data);
      assert(offer != null);
      listener.onOffer(offer);
    });
  });
}
