import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor-unsettled-summary.dart';
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
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/main.dart';
import 'package:investor/ui/charts.dart';
import 'package:investor/ui/offer_list.dart';
import 'package:investor/ui/offers_and_bids.dart';
import 'package:investor/ui/profile.dart';

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
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  String _message;
  AnimationController animationController;
  Animation<double> animation;
  Investor investor;
  List<InvoiceBid> invoiceBids = List();
  List<Offer> offers = List();
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
    _subscribeToFCM();
    _checkSectors();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('_DashboardState.didChangeAppLifecycleState state: $state');
    if (state == AppLifecycleState.resumed) {
      print(
          '_DashboardState.didChangeAppLifecycleState _getSummaryData calling ....');
      _getSummaryData();
    }
    setState(() {
      lifecycleState = state;
    });
  }

  void _subscribeToFCM() {
    FCM.configureFCM(invoiceBidListener: this, offerListener: this);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_OFFERS);
    print('_DashboardState._subscribeToFCM ########## subscribed!');
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;
  InvestorUnsettledBidSummary unsettledBidSummary;

  @override
  void dispose() {
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool summaryBusy = false;
  DashboardData dashboardData = DashboardData();

  ///get  summaries from Firestore
  _getSummaryData() async {
    print('Dashboard_getSummaryData: ......................');
    if (summaryBusy) {
      return;
    }
    dashboardData = await SharedPrefs.getDashboardData();
    if (dashboardData != null) {
      setState(() {});
    }
    summaryBusy = true;
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    dashboardData = await ListAPI.getInvestorDashboardData(
        investor.participantId, investor.documentReference);
    await SharedPrefs.saveDashboardData(dashboardData);
    unsettledBidSummary =
        await ListAPI.getInvestorUnsettledBidSummary(investor.participantId);
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    summaryBusy = false;
    setState(() {});

    _getDetailData();
  }

  Future _getDetailData() async {
    var m = await ListAPI.getInvoiceBidsByInvestor(investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(m));

    var o = await ListAPI.getOpenOffers();
    await Database.saveOffers(Offers(o));
  }

  Future _getCachedPrefs() async {
    investor = await SharedPrefs.getInvestor();

    if (investor == null) {
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => StartPage()),
      );
      return;
    }
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    name = investor.name;
    setState(() {});
    _getSummaryData();
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  @override
  Widget build(BuildContext context) {
    _message = widget.message;

    return new WillPopScope(
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
              icon: Icon(Icons.refresh),
              onPressed: _getSummaryData,
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
            ),
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: Stack(
          children: <Widget>[
//            new Opacity(
//              opacity: 0.0,
//              child: Container(
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage('assets/fincash.jpg'),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            ),
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
                        total: dashboardData == null
                            ? 0
                            : dashboardData.totalOpenOffers,
                        label: 'Invoice Offers',
                        totalStyle: Styles.pinkBoldMedium,
                        totalValue: dashboardData == null
                            ? 0.00
                            : dashboardData.totalOpenOfferAmount,
                        totalValueStyle: Styles.tealBoldSmall,
                      ),
                    ),
                  ),
                  new InkWell(
                    onTap: _onInvoiceBidsTapped,
                    child: InvestorSummaryCard(
                      context: context,
                      dashboardData: dashboardData,
                      unsettledBidSummary: unsettledBidSummary,
                    ),
                  ),
                  new InkWell(
                    onTap: _onPaymentsTapped,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SummaryCard(
                        total: dashboardData == null ? 0 : 0,
                        label: 'Bids Settled',
                        totalStyle: Styles.blueBoldLarge,
                        elevation: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    _getSummaryData();
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

  void _onPaymentsTapped() {
    print('_DashboardState._onPaymentsTapped ............');
  }

  void _onInvoiceBidsTapped() {
    print('_DashboardState._onInvoiceTapped ...............');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new OffersAndBids()),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Text(
                  name == null ? 'Organisation' : name,
                  style: Styles.whiteBoldSmall,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  AutoTradeOrder order;
  InvestorProfile profile;
  OpenOfferSummary offerSummary;

  List<DropdownMenuItem<int>> items = List();

//  Future _getOffers() async {
//    offerSummary = await ListAPI.getOpenOffersSummary();
//    await SharedPrefs.saveOpenOfferSummary(offerSummary);
//    offers = offerSummary.offers;
//    setState(() {});
//    print(
//        '\n\n_DashboardState._getOffers ....######### ............ ${offerSummary.offers.length}\n\n');
//  }

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

  @override
  onOffer(Offer o) {
    offer = o;
    print(
        '\n\n_DashboardState.onOffer ...... check date handling ....${o.offerAmount} ${o.date}');
    DateTime now = DateTime.now().toUtc();
    DateTime date = DateTime.parse(o.date);
    Duration difference = now.difference(date);
    if (difference.inHours > 1) {
      print(
          'onOffer -  IGNORED: older than 1 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Offer arrived',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: OfferConstant);

    _getSummaryData();
  }

  void _onProfileRequested() {
    print('_DashboardState._onProfileRequested');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ProfilePage()),
    );
  }

  @override
  onInvoiceBidMessage(invoiceBid) async {
    print('\n\n_DashboardState.onInvoiceBidMessage \n${invoiceBid.toJson()}');
    await _getSummaryData();
    print('_DashboardState.onInvoiceBidMessage ############ ${offers.length}');
    setState(() {});
    _showSnack(
        'Invoice Bid made: ${getFormattedAmount('${invoiceBid.amount}', context)}');
  }

  double opacity = 1.0;
  String name;

  @override
  onOfferMessage(Offer offer) async {
    print('_DashboardState.onOfferMessage ${offer.toJson()}');
    await _getSummaryData();
    setState(() {});
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
  final InvestorUnsettledBidSummary unsettledBidSummary;

  InvestorSummaryCard(
      {this.dashboardData, this.context, this.unsettledBidSummary});

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
            style: Styles.purpleSmall,
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
//            Container(
//              height: 100.0,
//              child: Container(
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage('assets/fincash.jpg'),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
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
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
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
                  unsettledBidSummary == null
                      ? '0.00'
                      : '${unsettledBidSummary.totalUnsettledBids}',
                  style: Styles.blackSmall,
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
                    'Unsettled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  unsettledBidSummary == null
                      ? '0.00'
                      : '${getFormattedAmount('${unsettledBidSummary.totalUnsettledBidAmount}', context)}',
                  style: Styles.blackSmall,
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
