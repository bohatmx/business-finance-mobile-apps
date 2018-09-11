import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/util.dart';

class Trading {
  Future<String> makeBid(
      InvoiceBid invoiceBid, Offer offer, Investor investor) {
    var api = DataAPI(getURL());
    var res = api.makeInvoiceBid(invoiceBid, offer, investor);
    return res;
  }
}
