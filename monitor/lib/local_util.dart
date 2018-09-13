import 'dart:convert';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';

class Util {}

abstract class BlockchainListener {
  onInvoiceBid(InvoiceBid bid);
  onOffer(Offer offer);
  onPurchaseOrder(PurchaseOrder purchaseOrder);
  onDeliveryNote(DeliveryNote deliveryNote);
  onInvoice(Invoice invoice);
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance);
  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance);
}

class BlockchainUtil {
  static var channel =
      new IOWebSocketChannel.connect("ws://bfnrestv3.eu-gb.mybluemix.net");

  static listenForBlockchainEvents(BlockchainListener listener) async {
    print(
        'listenForBlockchainEvents ------- starting  #################################');
    channel.stream.listen((message) {
      print(
          '\n\n############# listenForBlockchainEvents WebSocket  ###################: \n\n' +
              message);
      try {
        var data = json.decode(message);
        String clazz = data['\$class'];
        if (clazz.contains('Offer')) {
          var m = data['offer'];
          var offer = Offer.fromJson(m);
          prettyPrint(offer.toJson(),
              'listenForBlockchainEvents ===============> Offer from web socket: ');
          listener.onOffer(offer);
          return;
        }
        if (clazz.contains('InvoiceBid')) {
          var m = data['bid'];
          var invoiceBid = InvoiceBid.fromJson(m);
          prettyPrint(invoiceBid.toJson(),
              'listenForBlockchainEvents ===============> InvoiceBid from web socket: ');
          listener.onInvoiceBid(invoiceBid);
          return;
        }
        if (clazz.contains('PurchaseOrder')) {
          var m = data['purchaseOrder'];
          var po = PurchaseOrder.fromJson(m);
          prettyPrint(po.toJson(),
              'listenForBlockchainEvents ===============> PurchaseOrder from web socket: ');
          listener.onPurchaseOrder(po);
          return;
        }
        if (clazz.contains('DeliveryNote')) {
          var m = data['deliveryNote'];
          var dn = DeliveryNote.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryNote from web socket: ');
          listener.onDeliveryNote(dn);
          return;
        }
        if (clazz.contains('Invoice')) {
          var m = data['invoice'];
          var dn = Invoice.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryNote from web socket: ');
          listener.onInvoice(dn);
          return;
        }
        if (clazz.contains('DeliveryAcceptance')) {
          var m = data['deliveryAcceptance'];
          var dn = DeliveryAcceptance.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> DeliveryAcceptance from web socket: ');
          listener.onDeliveryAcceptance(dn);
          return;
        }
        if (clazz.contains('InvoiceAcceptance')) {
          var m = data['invoiceAcceptance'];
          var dn = InvoiceAcceptance.fromJson(m);
          prettyPrint(dn.toJson(),
              'listenForBlockchainEvents ===============> InvoiceAcceptance from web socket: ');
          listener.onInvoiceAcceptance(dn);
          return;
        }
      } catch (e) {
        print('listenForBlockchainEvents ERROR $e');
      }
    });
  }
}

const Namespace = 'resource:com.oneconnect.biz.';

class ExecutionUnit {
  AutoTradeOrder order;
  InvestorProfile profile;
  Offer offer;

  static const Success = 0, ErrorInvalidTrade = 1, ErrorBadBid = 2;

  ExecutionUnit(
      {@required this.order, @required this.profile, @required this.offer});
}

class AutoTradeExecutionBuilder {
  List<ExecutionUnit> executionUnitList;
  DataAPI api = DataAPI(getURL());
  AutoTradeListener listener;

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

  final Firestore _firestore = Firestore.instance;

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

  _doInvoiceBid(ExecutionUnit exec) {
    print(
        'AutoTradeExecutionBuilder._doInvoiceBid ....... ${exec.offer.offerAmount} for ${exec.profile.name}');
    bool validInvAmount = false,
        validSec = false,
        validSupp = false,
        validTotal = false;
    double total = 0.00;
    //get investor an then their open bids, check total
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
        if (exec.profile.maxInvestableAmount > total) {
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
        print(
            'AutoTradeExecutionBuilder._doInvoiceBid: ***** Houustton, we have a prpblem!!..................yfje..kutf..769f WTF?');
        index = executionUnitList.length + 1;
      } else {
        print(
            'AutoTradeExecutionBuilder._doInvoiceBid: \n\n\n***** New York!!!, we are GOOD. Like fantastic? BID ON BLOCKCHAIN!!!!\n\n\n');
        bidCount++;
        index++;
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
}
