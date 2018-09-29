import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/stellar/Account.dart';
import 'package:businesslibrary/stellar/Balance.dart';
import 'package:businesslibrary/util/comms.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

const Namespace = 'resource:com.oneconnect.biz.';

///Data model of the unit that is used to manage auto trades
class ExecutionUnit {
  AutoTradeOrder order;
  InvestorProfile profile;
  Offer offer;
  Account account;
  DateTime date;

  static const Success = 0, ErrorInvalidTrade = 1, ErrorBadBid = 2;

  ExecutionUnit(
      {@required this.order,
      this.profile,
      @required this.offer,
      this.date,
      this.account});
  ExecutionUnit.fromJson(Map data) {
    var map1 = data['order'];
    this.order = AutoTradeOrder.fromJson(map1);

    var map2 = data['profile'];
    this.profile = InvestorProfile.fromJson(map2);

    var map3 = data['offer'];
    this.offer = Offer.fromJson(map3);

    var map4 = data['account'];
    this.account = Account.fromJson(map4);

    this.date = data['date'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'order': order,
        'profile': profile,
        'date': date,
        'offer': offer,
        'account': account,
      };
}

///Manage the auto buying of offers by investors
class AutoTradeExecutionBuilder {
  List<ExecutionUnit> executionUnitList;
  DataAPI api = DataAPI(getURL());
  AutoTradeListener listener;
  final Firestore _firestore = Firestore.instance;
  List<AutoTradeOrder> orders;
  int bidCount = 0;
  int index = 0;
  List<Account> accounts = List();
  List<InvestorProfile> profiles;
  List<Offer> offers;
  String documentId;

  executeAutoTrades(List<AutoTradeOrder> orders, List<InvestorProfile> profiles,
      List<Offer> offers, AutoTradeListener listener) async {
    assert(orders != null && orders.isNotEmpty);
    assert(profiles != null && profiles.isNotEmpty);
    assert(offers != null && offers.isNotEmpty);

    this.listener = listener;
    this.orders = orders;
    this.offers = offers;
    this.profiles = profiles;

    ///write AutoTradeStart to stop manual bids while running
    var api = DataAPI(getURL());
    var start = AutoTradeStart(
        dateStarted: DateTime.now(), possibleTrades: offers.length);
    var t = 0.00;
    offers.forEach((o) {
      t += o.offerAmount;
    });
    start.possibleAmount = t;
    documentId = await api.addAutoTradeStart(start);

    offers.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));

    executionUnitList = List();
    index = 0;
    _buildAccountList();
  }

  ///get Stellar accounts for checking balances
  void _buildAccountList() async {
    if (index < orders.length) {
      var acc = await StellarCommsUtil.getAccount(
          orders.elementAt(index).wallet.split('#').elementAt(1));
      accounts.add(acc);
      index++;
      print(
          'AutoTradeExecutionBuilder.controlAccounts - account found ${acc.account_id}');
      _buildAccountList();
    } else {
      print(
          '\n\nAutoTradeExecutionBuilder.controlAccounts: done getting Stellar accts: ${accounts.length}');
      doTheWork();
    }
  }

  ///add profiles and accounts to execution list
  void doTheWork() {
    print(
        'AutoTradeExecutionBuilder.doTheWork .............................. \n\n');
    while (offers.isNotEmpty) {
      _buildExecutionList(orders, offers);
    }
    executionUnitList.forEach((exec) {
      profiles.forEach((p) {
        if (exec.order.investorProfile.split('#').elementAt(1) == p.profileId) {
          exec.profile = p;
        }
      });

      accounts.forEach((acc) {
        if (acc.account_id == exec.order.wallet.split('#').elementAt(1)) {
          exec.account = acc;
        }
      });
    });

    index = 0;
    _controlInvoiceBids();
  }

  ///set  up the list of trades to execute
  void _buildExecutionList(List<AutoTradeOrder> orders, List<Offer> offers) {
    print(
        'AutoTradeExecutionBuilder._buildExecutionList .... offers: ${offers.length} '
        'executionUnitList : ${executionUnitList.length}  ');
    orders.forEach((order) {
      try {
        var offer = offers.elementAt(0);
        var t = ExecutionUnit(offer: offer, order: order, date: DateTime.now());
        executionUnitList.add(t);
        offers.remove(offer);
        print(
            'AutoTradeExecutionBuilder._buildExecutionList ----- executionUnitList : '
            '${executionUnitList.length}  offers: ${offers.length}');
      } catch (e) {
        print('AutoTradeExecutionBuilder._buildExecutionList ERROR : $e');
      }
    });
  }

  void _controlInvoiceBids() async {
    if (index < executionUnitList.length) {
      //todo - check if this offer has other partial bids already - do the rules allow auto trades in crowd funding scenario?
      var list = await ListAPI.getInvoiceBidsByOffer(
          executionUnitList.elementAt(index).offer);
      if (list.isEmpty) {
        _validateInvoiceBid(executionUnitList.elementAt(index));
      } else {
        print(
            'AutoTradeExecutionBuilder._controlInvoiceBids - this offer already has bids - ignoring for now');
        index++;
        _controlInvoiceBids();
      }
    } else {
      var api = DataAPI(getURL());
      await api.updateAutoTradeStart(documentId);
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
  _validateInvoiceBid(ExecutionUnit exec) async {
    print(
        'AutoTradeExecutionBuilder._validateInvoiceBid .......:  #### offer amt: ${exec.offer.offerAmount} for ${exec.profile.name}');
    bool validInvAmount = false,
        validSec = false,
        validSupp = false,
        validTotal = false,
        validMinimumDiscount = false,
        validAccountBalance = false;
    double total = 0.00;

    ///get investor and then their open bids, check total amount
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

        ///check if profile has sector filters
        if (exec.profile.sectors != null && exec.profile.sectors.isNotEmpty) {
          exec.profile.sectors.forEach((sector) {
            if (exec.offer.sector == sector) {
              validSec = true;
            }
          });
        } else {
          validSec = true;
        }
        if (exec.profile.minimumDiscount == null) {
          exec.profile.minimumDiscount = 1.0;
        }
        if (exec.profile.minimumDiscount <= exec.offer.discountPercent) {
          validMinimumDiscount = true;
        }
        //
        ///check if profile has supplier filters
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

        //todo - check Stellar account balance covers the total open ids - for now, assume balance is valid
        validAccountBalance = true;
        //
        print(
            'AutoTradeExecutionBuilder._validateInvoiceBid ... checking stellar account balance');
        List<Balance> balances = exec.account.balances;
        balances.forEach((m) {
          if (m.asset_type.contains('BFN')) {
            var bal = double.parse(m.balance);
            if (bal >= total) {
              validAccountBalance = true;
            }
          }
        });

        //
        if (validSec &&
            validSupp &&
            validInvAmount &&
            validTotal &&
            validMinimumDiscount &&
            validAccountBalance) {
          print(
              'AutoTradeExecutionBuilder._doInvoiceBid @@@@@@@@@@ Hooray!!! trade is  VALID ####################### writing bid ....');
          _writeBid(exec);
        } else {
          print(
              'AutoTradeExecutionBuilder._doInvoiceBid @@@@@@@@@@ Fuck!!! trade is  NOT VALID #######################');
          listener.onInvalidTrade(exec);
          index++;
          _controlInvoiceBids();
        }
      }).catchError((e) {
        print('AutoTradeExecutionBuilder._doInvoiceBid ERROR $e');
        listener.onError(bidCount);
        index = executionUnitList.length;
        _controlInvoiceBids();
      });
    });
  }

  ///Write bid to BFN and to Firestoree
  void _writeBid(ExecutionUnit exec) {
    //todo - auto trade reserves 100% of the offer. arbitrary business rule? let investor auto trade even in crowd funding situuation?

    ///check other, possibly partial bids and take what's left of the reserve perc
    ///
    var totReserved = 0.0;
    var myReserve = 100.0;
    var myAmt = 0.0;

    ListAPI.getInvoiceBidsByOffer(exec.offer).then((list) {
      list.forEach((m) {
        totReserved += m.reservePercent;
      });
      if (totReserved == 0.0) {
        myReserve = 100.0;
        myAmt = exec.offer.offerAmount;
      } else {
        myReserve = 100.0 - totReserved;
        myAmt = exec.offer.offerAmount * (myReserve / 100);
      }
      var bid = InvoiceBid(
        offer: Namespace + 'Offer#${exec.offer.offerId}',
        investor: exec.profile.investor,
        autoTradeOrder:
            Namespace + 'AutoTradeOrder#${exec.order.autoTradeOrderId}',
        amount: myAmt,
        discountPercent: exec.offer.discountPercent,
        startTime: DateTime.now().toIso8601String(),
        endTime: DateTime.now().toIso8601String(),
        isSettled: false,
        reservePercent: myReserve,
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
          api.closeOffer(exec.offer.offerId).then((mres) {
            bidCount++;
            index++;
            listener.onInvoiceAutoBid(bid);
          });
        }
        _controlInvoiceBids();
      }).catchError((e) {
        print('AutoTradeExecutionBuilder._doInvoiceBid $e');
        listener.onError(bidCount);
        index = executionUnitList.length;
        _controlInvoiceBids();
      });
    });
  }
}

abstract class AutoTradeListener {
  onComplete(int count);
  onError(int count);
  onInvoiceAutoBid(InvoiceBid bid);
  onInvalidTrade(ExecutionUnit exec);
}
