import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/main.dart';
import 'package:investor/ui/charts.dart';
import 'package:investor/ui/offer_list.dart';
import 'package:investor/ui/profile.dart';
import 'package:investor/ui/unsettled_bids.dart';
import 'package:scoped_model/scoped_model.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
  static _DashboardState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_DashboardState>());

  Dashboard(this.message);

  final String message;
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements SnackBarListener, InvoiceBidListener, OfferListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.biz.CHANNEL');
  final FirebaseMessaging _fm = new FirebaseMessaging();

  AnimationController animationController;
  Animation<double> animation;
  Investor investor;

  List<InvestorInvoiceSettlement> investorSettlements = List();

  User user;
  String fullName;
  DeliveryAcceptance acceptance;
  BasicMessageChannel<String> basicMessageChannel;
  AppLifecycleState lifecycleState;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);
    _getCachedPrefs();
    items = buildDaysDropDownItems();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('_DashboardState.didChangeAppLifecycleState state: $state');
    if (state == AppLifecycleState.resumed) {
      print(
          '_DashboardState.didChangeAppLifecycleState _getSummaryData calling ....');
      _refresh();
    }
    setState(() {
      lifecycleState = state;
    });
  }

  void _subscribeToFCM() {
    FCM.configureFCM(
        invoiceBidListener: this, offerListener: this, context: context);
    _fm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS);
    _fm.subscribeToTopic(FCM.TOPIC_OFFERS);
    print('_DashboardState._subscribeToFCM ########## subscribed!');
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;
  //InvestorBidSummary investorBidSummary;

  @override
  void dispose() {
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool refreshModel = false;
  List<InvoiceBid> bids;

  static const MAX_OFFERS = 300;
  void _refresh() async {
    print('_DashboardState._refresh ............ requesting refresh ...');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Refreshing data',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    setState(() {
      count = 0;
      refreshModel = true;
    });
  }

  Future _getCachedPrefs() async {
    investor = await SharedPrefs.getInvestor();
    print(
        '\n\n\n_DashboardState._getCachedPrefs ################### $investor');
    if (investor == null) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => StartPage()),
      );
      return;
    }
    _subscribeToFCM();
    _checkSectors();
    user = await SharedPrefs.getUser();
    setState(() {});
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 6.0,
          title: Text(
            'BFN',
            style: Styles.whiteSmall,
          ),
          leading: Icon(
            Icons.apps,
            color: Colors.indigo.shade900,
          ),
          bottom: _getBottom(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: _onProfileRequested,
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refresh,
            ),
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: _getBody(),
      ),
    );
  }

  int count = 0;
  Widget _getBody() {
    return ScopedModelDescendant<InvestorAppModel>(
      builder: (context, _, model) {
        _checkConditions(model);
        return Stack(
          children: <Widget>[
            new Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
              child: ListView(
                children: <Widget>[
                  new InkWell(
                    onTap: _onOffersTapped,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SummaryCard(
                        total: model.dashboardData == null
                            ? 0
                            : model.dashboardData.totalOpenOffers,
                        label: 'Invoice Offers',
                        totalStyle: Styles.pinkBoldMedium,
                        totalValue: model.dashboardData == null
                            ? 0.00
                            : model.dashboardData.totalOpenOfferAmount,
                        totalValueStyle: Styles.tealBoldSmall,
                      ),
                    ),
                  ),
                  new InkWell(
                    onTap: _onInvoiceBidsTapped,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 38.0),
                      child: InvestorSummaryCard(
                        context: context,
                        dashboardData: model.dashboardData,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _checkConditions(InvestorAppModel model) async {
    print(
        '\n\n_checkConditions #### invoiceBidArrived: $invoiceBidArrived offerArrived: $offerArrived refreshModel: $refreshModel count: $count');

    count++;

    if (invoiceBidArrived) {
      invoiceBidArrived = false;
      model.invoiceBidArrived(invoiceBid);
    }
    if (offerArrived) {
      offerArrived = false;
      model.offerArrived(offer);
    }
    if (refreshModel) {
      print(
          '\n\n_checkConditions --------- refreshModel: $refreshModel - will try a big time refresh');
      refreshModel = false;
      await model.refreshModel();
      print(
          '_DashboardState._checkConditions ========== have completed refresh, now what?');
      try {
        _scaffoldKey.currentState.removeCurrentSnackBar();
      } catch (e) {}
      setState(() {});
    }
  }

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new WalletPage(
              name: investor.name,
              participantId: investor.participantId,
              type: InvestorType)),
    );
  }

  refresh() {
    print(
        '_DashboardState.refresh: ################## REFRESH called. getSummary ...');
    setState(() {
      refreshModel = true;
    });
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  action: $action');
    switch (action) {
      case OfferConstant:
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new OfferList()),
        );
        break;
      case 2:
        break;
    }
  }

  void _onInvoiceBidsTapped() {
    print('_DashboardState._onInvoiceTapped ...............');
    setState(() {
      mTitle = 'The Good Ship BFN';
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnsettledBids()),
    );
  }

  String mTitle = 'BFN is Rock Solid!';

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: new Column(
        children: <Widget>[
          ScopedModelDescendant<InvestorAppModel>(
            builder: (context, child, model) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      model.investor == null ? '' : model.investor.name,
                      style: Styles.yellowBoldMedium,
                    ),
                    refreshModel == false
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  AutoTradeOrder order;
  InvestorProfile profile;
  OpenOfferSummary offerSummary;

  List<DropdownMenuItem<int>> items = List();

  void _onOffersTapped() {
    print('_DashboardState._onOffersTapped');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new OfferList()),
    );
  }

  static const OfferConstant = 1,
      DeliveryAcceptanceConstant = 2,
      GovtSettlement = 3,
      PurchaseOrderConstant = 4,
      InvoiceBidConstant = 5,
      InvestorSettlement = 6,
      WalletConstant = 7,
      InvoiceAcceptedConstant = 8;
  Offer offer;

  void _onProfileRequested() {
    print('_DashboardState._onProfileRequested');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ProfilePage()),
    );
  }

  void fix() async {
    print(
        '\n\n\n_DashboardState.fix ########################## start FIX .....');
    Firestore fs = Firestore.instance;
    var start = DateTime.now();
    var qs = await fs.collection('invoiceOffers').getDocuments();
    print('_DashboardState.fix offers found: ${qs.documents.length}');
    for (var doc in qs.documents) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      await doc.reference.setData(offer.toJson());
    }
    var end = DateTime.now();
    print(
        '_DashboardState.fix ----- FIX complete: ${end.difference(start).inSeconds} seconds elapsed.');
  }

  _showBottomSheet(InvoiceBid bid) {
    if (_scaffoldKey.currentState == null) return;
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 2),
        height: 360.0,
        color: Colors.brown.shade200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 20.0,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Trading Result',
                    style: Styles.purpleBoldMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InvoiceBidCard(
                bid: bid,
              ),
            ),
          ],
        ),
      );
    });
  }

  InvoiceBid invoiceBid;
  bool invoiceBidArrived = false;
  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) async {
    print(
        '_DashboardState.onInvoiceBidMessage invoiceBid arrived ###############################');
    this.invoiceBid = invoiceBid;
    invoiceBidArrived = true;

    setState(() {});
  }

  double opacity = 1.0;
  String name;

  bool offerArrived = false;
  @override
  onOfferMessage(Offer offer) async {
    print(
        '_DashboardState.onOfferMessage #################### ${offer.supplierName} ${offer.offerAmount}');
    setState(() {
      offerArrived = true;
    });
    _showSnack(
        'Offer arrived ${getFormattedAmount('${offer.offerAmount}', context)}');
  }

  void _showSnack(String message) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: Styles.white,
        backgroundColor: Theme.of(context).primaryColor);
  }
}

class InvestorSummaryCard extends StatelessWidget {
  final DashboardData dashboardData;
  final BuildContext context;

  InvestorSummaryCard({this.dashboardData, this.context});

  Widget _getTotalBids() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            '# Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            dashboardData == null ? '0' : '${dashboardData.totalBids}',
            style: Styles.blackBoldMedium,
          ),
        ),
      ],
    );
  }

  Widget _getTotalBidValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            'Total Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            dashboardData == null
                ? '0.00'
                : '${getFormattedAmount('${dashboardData.totalBidAmount}', context)}',
            style: Styles.blackBoldLarge,
          ),
        ),
      ],
    );
  }

  Widget _getAverageDiscount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Avg Discount',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            dashboardData == null ? '0.0%' : _getAvgDiscount(),
            style: Styles.purpleBoldSmall,
          ),
        ),
      ],
    );
  }

  String _getAvgDiscount() {
    if (dashboardData == null) {
      return '0.0%';
    }
    if (dashboardData.averageDiscountPerc == null) {
      return '0.0%';
    }
    return dashboardData.averageDiscountPerc.toStringAsFixed(2) + '%';
  }

  Widget _getAverageBidAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Average Bid',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            dashboardData == null
                ? '0'
                : '${getFormattedAmount('${dashboardData.averageBidAmount}', context)}',
            style: Styles.blackSmall,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Colors.brown.shade50,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getTotalBids(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 20.0),
            child: _getTotalBidValue(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getAverageBidAmount(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getAverageDiscount(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  dashboardData == null
                      ? '0.00'
                      : '${dashboardData.totalUnsettledBids}',
                  style: Styles.blackSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  dashboardData == null
                      ? '0.00'
                      : '${getFormattedAmount('${dashboardData.totalUnsettledAmount}', context)}',
                  style: Styles.blackSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  dashboardData == null
                      ? '0.00'
                      : '${dashboardData.totalSettledBids}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  dashboardData == null
                      ? '0.00'
                      : '${getFormattedAmount('${dashboardData.totalSettledAmount}', context)}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: RaisedButton(
              elevation: 6.0,
              color: Colors.indigo.shade200,
              onPressed: _onBtnPressed,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Show Charts',
                  style: Styles.whiteSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBtnPressed() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Charts()),
    );
  }
}

class InvestorAppModel extends Model {
  String _title = 'BFN State Test';
  DashboardData _dashboardData = DashboardData();
  List<InvoiceBid> _invoiceBids;
  List<Offer> _offers;
  Investor _investor;

  List<InvoiceBid> get invoiceBids => _invoiceBids;
  List<Offer> get offers => _offers;
  Investor get investor => _investor;
  DashboardData get dashboardData => _dashboardData;
  String get title => _title;

  InvestorAppModel() {
    initialize();
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
      _invoiceBids = await Database.getInvoiceBids();
      _invoiceBids.insert(0, invoiceBid);
      await Database.saveInvoiceBids(InvoiceBids(_invoiceBids));
    }
    notifyListeners();
  }

  void initialize() async {
    print('\n\nInvestorAppModel.initialize ################################ ');
    _investor = await SharedPrefs.getInvestor();
    if (_investor == null) {
      return;
    }
    _dashboardData = await SharedPrefs.getDashboardData();
    if (_dashboardData == null) {
      await refreshDashboard();
    }
    _invoiceBids = await Database.getInvoiceBids();
    if (_invoiceBids.isEmpty) {
      await refreshInvoiceBids();
    }
    _offers = await Database.getOffers();
    if (_offers.isEmpty) {
      await refreshOffers();
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
  }

  Future refreshInvoiceBids() async {
    print('InvestorAppModel.refreshInvoiceBids ...........................');
    _investor = await SharedPrefs.getInvestor();
    _invoiceBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        _investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(_invoiceBids));
    notifyListeners();
  }

  Future refreshOffers() async {
    print('InvestorAppModel.refreshOffers .................................');
    _offers = await ListAPI.getOpenOffers(MAX_RECORDS);
    await Database.saveOffers(Offers(_offers));
    notifyListeners();
  }

  Future refreshModel() async {
    print('InvestorAppModel.refreshModel .................................');
    _investor = await SharedPrefs.getInvestor();
    _invoiceBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        _investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(_invoiceBids));

    _dashboardData = await ListAPI.getInvestorDashboardData(
        _investor.participantId, _investor.documentReference);
    await SharedPrefs.saveDashboardData(_dashboardData);

    _offers = await ListAPI.getOpenOffers(MAX_RECORDS);
    await Database.saveOffers(Offers(_offers));

    notifyListeners();
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
    print(
        'InvestorAppModel.doPrint invoiceBids in Model: ${_invoiceBids.length}');
    print('InvestorAppModel.doPrint offers in Model: ${_offers.length}');
    print(
        '\nInvestorAppModel.doPrint ENDED. ############################################\n\n\n');
  }
}

const MAX_RECORDS = 300;
