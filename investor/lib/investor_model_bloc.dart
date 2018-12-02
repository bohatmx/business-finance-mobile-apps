import 'dart:async';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/Finders.dart';

class InvestorModelBloc implements Model2Listener{
  final StreamController<InvestorAppModel2> _appModelController = StreamController<InvestorAppModel2>();
  final InvestorAppModel2 _appModel = InvestorAppModel2();

  InvestorModelBloc() {
    print('\n\nInvestorModelBloc.InvestorModelBloc - CONSTRUCTOR - set listener and initialize app model');
    _appModel.setModelListener(this);
    _appModel.initialize();
  }

  get appModel => _appModel;

  refreshDashboard() async {
    await _appModel.refreshDashboard();
    _appModelController.sink.add(_appModel);
  }


  closeStream() {
    _appModelController.close();
  }

  get appModelStream => _appModelController.stream;

  @override
  onComplete() {
    print('\n\nInvestorModelBloc.onComplete ########## adding model to stream sink ......... ');
    _appModelController.sink.add(_appModel);
  }
}

final investorModelBloc = InvestorModelBloc();

abstract class Model2Listener {
  onComplete();
}

class InvestorAppModel2  {
  String _title = 'BFN State Test';
  int _pageLimit = 10;
  DashboardData _dashboardData = DashboardData();
  List<InvoiceBid> _unsettledInvoiceBids, _settledInvoiceBids;
  List<InvestorInvoiceSettlement> _settlements;
  List<Offer> _offers;
  Investor _investor;
  Model2Listener _modelListener;

  int get pageLimit => _pageLimit;
  List<InvoiceBid> get unsettledInvoiceBids => _unsettledInvoiceBids;
  List<InvoiceBid> get settledInvoiceBids => _settledInvoiceBids;
  List<Offer> get offers => _offers;
  List<InvestorInvoiceSettlement> get settlements => _settlements;
  Investor get investor => _investor;
  DashboardData get dashboardData => _dashboardData;
  String get title => _title;

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

  void setModelListener(Model2Listener listener) {
    _modelListener = listener;
    print('InvestorAppModel.setModelListener listener has been set.');
  }

  Future processSettledBid(InvoiceBid bid) async {
    bid.isSettled = true;
    _settledInvoiceBids.insert(0, bid);

    _unsettledInvoiceBids.remove(bid);
    _setItemNumbers(_unsettledInvoiceBids);
    print(
        'InvestorAppModel._removeBidFromCache bids in cache: ${_unsettledInvoiceBids.length} added to settled: ${_settledInvoiceBids.length}');
    _dashboardData.unsettledBids = _unsettledInvoiceBids;
    _dashboardData.settledBids = _settledInvoiceBids;
    await Database.saveDashboard(_dashboardData);
    if (_modelListener != null) {
      _modelListener.onComplete();
    }
    return null;
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
      _dashboardData.unsettledBids.insert(0, invoiceBid);
      _unsettledInvoiceBids.insert(0, invoiceBid);
      _dashboardData.totalBids++;
      _dashboardData.totalBidAmount += invoiceBid.amount;
      await Database.saveDashboard(_dashboardData);
    }
    if (_modelListener != null) {
      _modelListener.onComplete();
    }

  }

  Future updatePageLimit(int pageLimit) async {
    await SharedPrefs.savePageLimit(pageLimit);
    _pageLimit = pageLimit;
  }

  void initialize() async {
    print('\n\nInvestorAppModel.initialize ################################ ');
    _investor = await SharedPrefs.getInvestor();
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }
    await refreshDashboard();
    print('\n\nInvestorAppModel.initialize - REFRESH MODEL COMPLETE - refreshDashboard *************');
  }

  Future refreshDashboard() async {
    print('InvestorAppModel.refreshDashboard ............................');
    _investor = await SharedPrefs.getInvestor();
    _dashboardData = await Database.getDashboard();
    if (_dashboardData != null) {
      print('\n\nInvestorAppModel2.refreshDashboard - _dashboardData != null calling  _modelListener.onComplete();\n');
      _modelListener.onComplete();
    }
    print('InvestorAppModel2.refreshDashboard ----- REFRESH from functions ...............');
    _dashboardData = await ListAPI.getInvestorDashboardData(
        _investor.participantId, _investor.documentReference);
    await Database.saveDashboard(_dashboardData);
    _settledInvoiceBids = _dashboardData.settledBids;
    _setItemNumbers(_settledInvoiceBids);
    _unsettledInvoiceBids = _dashboardData.unsettledBids;
    _setItemNumbers(_unsettledInvoiceBids);
    _offers = _dashboardData.openOffers;
    _setItemNumbers(_offers);
    _settlements = _dashboardData.settlements;
    _setItemNumbers(_settlements);
    doPrint();

    if (_modelListener != null) {
      print('\n\nInvestorAppModel2.refreshDashboard:  after refresh from functions: calling  _modelListener.onComplete();\n');
      _modelListener.onComplete();
    }
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

    if (_unsettledInvoiceBids != null)
      print(
          'InvestorAppModel.doPrint _unsettledInvoiceBids in Model: ${_unsettledInvoiceBids.length}');
    if (_offers != null)
      print('InvestorAppModel.doPrint offers in Model: ${_offers.length}');
    if (_settlements != null)
      print('InvestorAppModel.doPrint _settlements in Model: ${_settlements.length}');
    if (_settledInvoiceBids != null)
      print('InvestorAppModel.doPrint _settledInvoiceBids in Model: ${_settledInvoiceBids.length}');
    if (_investor != null) {
      prettyPrint(_investor.toJson(), 'doPrint: ######## Investor in Model');
    }
    if (_dashboardData != null) {
      prettyPrint(_dashboardData.toJson(),
          'doPrint: ####### DashboardData inside Model');
    }
  }
}