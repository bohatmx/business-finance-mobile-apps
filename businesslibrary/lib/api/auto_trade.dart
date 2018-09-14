import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

const Namespace = 'resource:com.oneconnect.biz.';

///Data model of the unit that is used to manage auto trades
class ExecutionUnit {
  AutoTradeOrder order;
  InvestorProfile profile;
  Offer offer;

  static const Success = 0, ErrorInvalidTrade = 1, ErrorBadBid = 2;

  ExecutionUnit(
      {@required this.order, @required this.profile, @required this.offer});
}

///Manage the auto buying of offers by investors
class AutoTradeExecutionBuilder {
  List<ExecutionUnit> executionUnitList;
  DataAPI api = DataAPI(getURL());
  AutoTradeListener listener;
  final Firestore _firestore = Firestore.instance;

  List<ExecutionUnit> executeAutoTrades(
      List<AutoTradeOrder> orders,
      List<InvestorProfile> profiles,
      List<Offer> offers,
      AutoTradeListener listener) {
    this.listener = listener;
    executionUnitList = List();

    while (offers.isNotEmpty) {
      _doOrderBuild(orders, offers);
    }

    executionUnitList.forEach((exec) {
      InvestorProfile profile;
      profiles.forEach((p) {
        if (exec.order.investorProfile.split('#').elementAt(1) == p.profileId) {
          profile = p;
        }
      });
      exec.profile = profile;
    });

    index = 0;
    _controlInvoiceBids();
  }

  void _doOrderBuild(List<AutoTradeOrder> orders, List<Offer> offers) {
    print(
        'AutoTradeExecutionBuilder._doOrderBuild .... offers: ${offers.length} executionUnitList : ${executionUnitList.length}  ');
    orders.forEach((order) {
      try {
        var offer = offers.elementAt(0);
        var t = ExecutionUnit(offer: offer, order: order);
        executionUnitList.add(t);
        offers.remove(offer);
        print(
            'AutoTradeExecutionBuilder._doOrderBuild ----- executionUnitList : ${executionUnitList.length}  offers: ${offers.length}');
      } catch (e) {
        print('AutoTradeExecutionBuilder._doOrderBuild ERROR : $e');
      }
    });
  }

  int index = 0;

  void _controlInvoiceBids() {
    if (index < executionUnitList.length) {
      _doInvoiceBid(executionUnitList.elementAt(index));
    } else {
      print(
          '\n\n\AutoTradeExecutionBuilder.control @@@@@@@@@ WE ARE DONE\n\n\n');
      if (index == executionUnitList.length + 1) {
        listener.onError(bidCount);
      } else {
        listener.onComplete(bidCount);
      }
    }
  }

  ///validate the potential bid via profile settings and then write bid to BFN
  _doInvoiceBid(ExecutionUnit exec) {
    print(
        'AutoTradeExecutionBuilder._doInvoiceBid .......:  #### offer amt: ${exec.offer.offerAmount} for ${exec.profile.name}');
    bool validInvAmount = false,
        validSec = false,
        validSupp = false,
        validTotal = false;
    double total = 0.00;

    //get investor and then their open bids, check total amount
    _firestore
        .collection('investors')
        .where('participantId',
            isEqualTo: exec.profile.investor.split('#').elementAt(1))
        .getDocuments()
        .then((qs) {
      _firestore
          .collection('investors')
          .document(qs.documents.first.documentID)
          .collection('invoiceBids')
          .where('isSettled', isEqualTo: false)
          .getDocuments()
          .then((qs2) {
        print('AutoTradeExecutionBuilder._doInvoiceBid *** '
            'found open bids: ${qs2.documents.length}, '
            'name: ${exec.profile.name}');

        if (qs2.documents.isNotEmpty) {
          qs2.documents.forEach((doc) {
            var m = InvoiceBid.fromJson(doc.data);
            total += m.amount;
          });
        }
        print('AutoTradeExecutionBuilder._doInvoiceBid +++++++ ++++++++++++++ '
            'total  amount: $total bids: ${qs2.documents.length} '
            'maxInvestableAmount ${exec.profile.maxInvestableAmount}');
        if (exec.profile.maxInvestableAmount >=
            (total + exec.offer.offerAmount)) {
          validTotal = true;
        }
        if (exec.profile.maxInvoiceAmount > exec.offer.offerAmount) {
          validInvAmount = true;
        }

        //check if profile has sector filters
        if (exec.profile.sectors != null && exec.profile.sectors.isNotEmpty) {
          exec.profile.sectors.forEach((sector) {
            if (exec.offer.sector == sector) {
              validSec = true;
            }
          });
        } else {
          validSec = true;
        }
        //
        //check if profile has supplier filters
        if (exec.profile.suppliers != null &&
            exec.profile.suppliers.isNotEmpty) {
          exec.profile.suppliers.forEach((supplier) {
            if (exec.offer.supplier == supplier) {
              validSupp = true;
            }
          });
        } else {
          validSupp = true;
        }
        //
        if (validSec && validSupp && validInvAmount && validTotal) {
          print(
              'AutoTradeExecutionBuilder._doInvoiceBid @@@@@@@@@@ Hooray!!! trade is  VALID ####################### writing bid ....');
          writeBid(exec);
        } else {
          print(
              'AutoTradeExecutionBuilder._doInvoiceBid @@@@@@@@@@ Fuck!!! trade is  NOT VALID #######################');
          return 7;
        }
      }).catchError((e) {
        print('AutoTradeExecutionBuilder._doInvoiceBid ERROR $e');
        return 9;
      });
    });
  }

  ///Write bid to BFN and to Firestoree
  void writeBid(ExecutionUnit exec) {
    var bid = InvoiceBid(
      offer: Namespace + 'Offer#${exec.offer.offerId}',
      investor: exec.profile.investor,
      autoTradeOrder:
          Namespace + 'AutoTradeOrder#${exec.order.autoTradeOrderId}',
      amount: exec.offer.offerAmount,
      discountPercent: 100.0,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      isSettled: false,
      reservePercent: 100.0,
      investorName: exec.profile.name,
      wallet: exec.order.wallet,
    );
    api
        .makeInvoiceAutoBid(
      bid: bid,
      offer: exec.offer,
      order: exec.order,
    )
        .then((res) {
      if (res == '0') {
        print('AutoTradeExecutionBuilder._doInvoiceBid: ***** '
            'Houustton, we have a BFN prpblem!!..................yfje..kutf..769f WTF?');
        index = executionUnitList.length + 1;
      } else {
        print('AutoTradeExecutionBuilder._doInvoiceBid: \n\n\n'
            '***** New York!!!, we are GOOD. Like fantastic? BID ON BLOCKCHAIN!!!!\n\n\n');
        bidCount++;
        index++;
        listener.onInvoiceAutoBid(bid);
      }
      _controlInvoiceBids();
    }).catchError((e) {
      print('AutoTradeExecutionBuilder._doInvoiceBid $e');
    });
  }

  int bidCount = 0;
}

abstract class AutoTradeListener {
  onComplete(int count);
  onError(int count);
  onInvoiceAutoBid(InvoiceBid bid);
}
