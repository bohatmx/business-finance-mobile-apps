import 'dart:async';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';

import 'package:scoped_model/scoped_model.dart';
abstract class ModelListener {
  onComplete();
}

class InvestorAppModel extends Model {
  String _title = 'BFN State Test';
  int _pageLimit = 10;
  DashboardData _dashboardData = DashboardData();
  List<InvoiceBid> _unsettledInvoiceBids, _settledInvoiceBids;
  List<Offer> _offers;
  Investor _investor;
  ModelListener _modelListener;

  int get pageLimit => _pageLimit;
  List<InvoiceBid> get unsettledInvoiceBids => _unsettledInvoiceBids;
  List<InvoiceBid> get settledInvoiceBids => _settledInvoiceBids;
  List<Offer> get offers => _offers;
  Investor get investor => _investor;
  DashboardData get dashboardData => _dashboardData;
  String get title => _title;

  InvestorAppModel() {
    initialize();
  }
  double getTotalSettledBidAmount() {
    if (_settledInvoiceBids == null) return 0.0;
    var t = 0.0;
    _settledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    return t;
  }
  double getTotalUnsettledBidAmount() {
    var t = 0.0;
    _unsettledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    return t;
  }
  void setModelListener(ModelListener listener) {
    _modelListener = listener;
    print('InvestorAppModel.setModelListener listener has been set.');
  }

  Future processSettledBid(InvoiceBid bid) async {
    bid.isSettled = true;
    _settledInvoiceBids.insert(0, bid);

    var bids = await Database.getUnsettledInvoiceBids();
    _unsettledInvoiceBids.clear();
    bids.forEach((b) {
      if (b.invoiceBidId != bid.invoiceBidId) {
        _unsettledInvoiceBids.add(b);
      }
    });
    _setItemNumbers(_unsettledInvoiceBids);
    print(
        'InvestorAppModel._removeBidFromCache bids in cache: ${_unsettledInvoiceBids.length} added to settled: ${_settledInvoiceBids.length}');
    await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    notifyListeners();
    return null;
  }

  void offerArrived(Offer offer) async {
    print(
        '\n\nInvestorAppModel.offerArrived - ${offer.supplierName} ${offer.offerAmount}');
    _dashboardData.totalOpenOffers++;
    _dashboardData.totalOpenOfferAmount += offer.offerAmount;

    await SharedPrefs.saveDashboardData(dashboardData);
    _offers = await Database.getOffers();
    _offers.insert(0, offer);
    await Database.saveOffers(Offers(_offers));
    notifyListeners();
  }

  void invoiceBidArrived(InvoiceBid invoiceBid) async {
    _dashboardData.totalOpenOffers--;
    _dashboardData.totalOfferAmount -= invoiceBid.amount;
    _dashboardData.totalOpenOfferAmount -= invoiceBid.amount;

    String m = NameSpace + 'Investor#${investor.participantId}';
    print(
        '\n\nInvestorAppModel.invoiceBidArrived \n${invoiceBid.investorName} ${invoiceBid.investor}  - #### LOCAL:  ${investor.name} $m');

    if (invoiceBid.investor == m) {
      _dashboardData.totalUnsettledBids++;
      _dashboardData.totalUnsettledAmount += invoiceBid.amount;
    }

    if (invoiceBid.investor.split('#').elementAt(1) == investor.participantId) {
      _dashboardData.totalBids++;
      _dashboardData.totalBidAmount += invoiceBid.amount;
      await SharedPrefs.saveDashboardData(dashboardData);
      _unsettledInvoiceBids = await Database.getUnsettledInvoiceBids();
      _unsettledInvoiceBids.insert(0, invoiceBid);
      await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    }
    notifyListeners();
  }

  Future updatePageLimit(int pageLimit) async {
    return await SharedPrefs.savePageLimit(pageLimit);
  }

  Future settleInvoiceBid(InvoiceBid bid) async {
    print('InvestorAppModel.settleInvoiceBid');
    _unsettledInvoiceBids.forEach((b) {
      if (bid.invoiceBidId == b.invoiceBidId) {
        b.isSettled = true;
      }
    });

    notifyListeners();
  }

  void initialize() async {
    print('\n\nInvestorAppModel.initialize ################################ ');
    _investor = await SharedPrefs.getInvestor();
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }
    if (_investor == null) {
      return;
    }
    _dashboardData = await SharedPrefs.getDashboardData();
    if (_dashboardData == null) {
      await refreshDashboard();
    }
    _unsettledInvoiceBids = await Database.getUnsettledInvoiceBids();
    if (_unsettledInvoiceBids.isEmpty) {
      await refreshInvoiceBids();
    } else {
      _setItemNumbers(_unsettledInvoiceBids);
    }
    _settledInvoiceBids = await Database.getSettledInvoiceBids();
    if (_settledInvoiceBids.isEmpty) {
      await refreshInvoiceBids();
    } else {
      _setItemNumbers(_settledInvoiceBids);
    }
    _offers = await Database.getOffers();
    if (_offers.isEmpty) {
      await refreshOffers();
    } else {
      _setItemNumbers(_offers);
    }
    _title =
    'BFN Model ${getFormattedDateHour('${DateTime.now().toIso8601String()}')}';
    doPrint();
    notifyListeners();
  }

  Future refreshDashboard() async {
    print('InvestorAppModel.refreshDashboard ............................');
    _investor = await SharedPrefs.getInvestor();
    _dashboardData = await ListAPI.getInvestorDashboardData(
        _investor.participantId, _investor.documentReference);
    await SharedPrefs.saveDashboardData(_dashboardData);
    notifyListeners();
    if (_modelListener != null) {
      _modelListener.onComplete();
    }
  }

  Future refreshInvoiceBids() async {
    print('InvestorAppModel.refreshInvoiceBids ...........................');
    _investor = await SharedPrefs.getInvestor();

    _unsettledInvoiceBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        _investor.documentReference);
    await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    _setItemNumbers(_unsettledInvoiceBids);
    
    _settledInvoiceBids = await ListAPI.getSettledInvoiceBidsByInvestor(_investor.documentReference);
    await Database.saveSettledInvoiceBids(InvoiceBids(_settledInvoiceBids));
    _setItemNumbers(_settledInvoiceBids);

    notifyListeners();
    if (_modelListener != null) {
      _modelListener.onComplete();
    }
  }

  Future refreshOffers() async {
    print('InvestorAppModel.refreshOffers .................................');
    _offers = await ListAPI.getOpenOffersViaFunctions();
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    notifyListeners();
    if (_modelListener != null) {
      _modelListener.onComplete();
    }
  }
/*
firestore.collection('users').document(userId).snapshots().asyncMap((snap) async {
      List<String> groceryListsArr = snap.data['groceryLists'];
      var groceryList = <DocumentSnapshot>[];
      for (var groceryPath in groceryListsArr) {
        groceryList.add(await firestore.document(groceryPath).get());
      }
      retur
 */
  Future refreshModel() async {
    print(
        '\n\nInvestorAppModel.refreshModel ............. refresh everything! ....................');
    if (_investor == null) {
      _investor = await SharedPrefs.getInvestor();
    }
    _unsettledInvoiceBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        _investor.participantId);
    await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    _setItemNumbers(_unsettledInvoiceBids);
    print('InvestorAppModel.refreshModel unsettled bids: ${unsettledInvoiceBids.length}');

    _settledInvoiceBids = await ListAPI.getSettledInvoiceBidsByInvestor(_investor.participantId);
    await Database.saveSettledInvoiceBids(InvoiceBids(_settledInvoiceBids));
    _setItemNumbers(_settledInvoiceBids);
    print('InvestorAppModel.refreshModel settled bids: ${settledInvoiceBids.length}');

    _dashboardData = await ListAPI.getInvestorDashboardData(
        _investor.participantId, _investor.documentReference);
    prettyPrint(_dashboardData.toJson(), '######### Dashboard data retrieved');
    await SharedPrefs.saveDashboardData(_dashboardData);

    _offers = await ListAPI.getOpenOffersViaFunctions();
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);

    if (_modelListener != null) {
      _modelListener.onComplete();
    }
    notifyListeners();
  }

  void _setItemNumbers(List<Findable> list) {
    if (list == null) return;
    int num = 1;
    list.forEach((o) {
      o.itemNumber = num;
      num++;
    });
  }

  void doPrint() {
    print(
        '\n\n\nInvestorAppModel.doPrint STARTED ######################################\n');
    if (_investor != null) {
      prettyPrint(_investor.toJson(), '######## Investor in Model');
    }
    if (_dashboardData != null) {
      prettyPrint(
          _dashboardData.toJson(), '####### DashboardData inside Model');
    }
    if (_unsettledInvoiceBids != null)
      print(
          'InvestorAppModel.doPrint invoiceBids in Model: ${_unsettledInvoiceBids.length}');
    if (_offers != null)
      print('InvestorAppModel.doPrint offers in Model: ${_offers.length}');
    print(
        '\nInvestorAppModel.doPrint ENDED. ############################################\n\n\n');
  }
}
