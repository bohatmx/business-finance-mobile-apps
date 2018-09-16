import 'package:businesslibrary/api/data_api.dart';
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

  static const Success = 0, ErrorInvalidTrade = 1, ErrorBadBid = 2;

  ExecutionUnit(
      {@required this.order,
      @required this.profile,
      @required this.offer,
      @required this.account});
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

  executeAutoTrades(List<AutoTradeOrder> orders, List<InvestorProfile> profiles,
      List<Offer> offers, AutoTradeListener listener) {
    this.listener = listener;
    this.orders = orders;
    this.offers = offers;
    this.profiles = profiles;

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
        var t = ExecutionUnit(offer: offer, order: order);
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

  void _controlInvoiceBids() {
    if (index < executionUnitList.length) {
      _validateInvoiceBid(executionUnitList.elementAt(index));
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
  _validateInvoiceBid(ExecutionUnit exec) {
    print(
        'AutoTradeExecutionBuilder._validateInvoiceBid .......:  #### offer amt: ${exec.offer.offerAmount} for ${exec.profile.name}');
    bool validInvAmount = false,
        validSec = false,
        validSupp = false,
        validTotal = false,
        validAccountBalance = false;
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
        //todo - check account balance covers the total open ids - for now, assume balance is valid
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
            validAccountBalance) {
          print(
              'AutoTradeExecutionBuilder._doInvoiceBid @@@@@@@@@@ Hooray!!! trade is  VALID ####################### writing bid ....');
          writeBid(exec);
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
      listener.onError(bidCount);
      index = executionUnitList.length;
      _controlInvoiceBids();
    });
  }
}

abstract class AutoTradeListener {
  onComplete(int count);
  onError(int count);
  onInvoiceAutoBid(InvoiceBid bid);
  onInvalidTrade(ExecutionUnit exec);
}
