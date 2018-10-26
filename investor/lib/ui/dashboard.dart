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
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/ui/firestore_listener.dart';
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
    implements SnackBarListener, OfferListener, BidListener, FCMListener {
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
      _getSummaryData();
    }
    setState(() {
      lifecycleState = state;
    });
  }

  void _subscribeToFCM() {
    configureMessaging(this);
    _firebaseMessaging.subscribeToTopic('invoiceBids');
    _firebaseMessaging.subscribeToTopic('offers');
    print('_DashboardState._subscribeToFCM ########## subscribed!');
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      DataAPI3.addSectors();
    }
  }

  List<Sector> sectors;

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
    summaryBusy = true;
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    dashboardData = await ListAPI.getInvestorDashboardData(
        investor.participantId, investor.documentReference);

    _scaffoldKey.currentState.hideCurrentSnackBar();
    summaryBusy = false;
    setState(() {});
  }

  Future _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    investor = await SharedPrefs.getInvestor();

    assert(investor != null);
    name = investor.name;
    listenForOffer(this);
    listenForBid(this, investor.documentReference);
    setState(() {});
    _getSummaryData();
  }

  Future _getSettlements() async {
    print('_DashboardState._getSettlements ......');
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
          elevation: 3.0,
          title: Text(
            'BFN',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          leading: Container(),
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
        body: Stack(
          children: <Widget>[
            new Opacity(
              opacity: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/fincash.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            new Opacity(
              opacity: opacity,
              child: new Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: ListView(
                  children: <Widget>[
                    new InkWell(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: dashboardData == null ? 0 : 0,
                        label: 'Bids Settled',
                        totalStyle: Styles.blueBoldLarge,
                      ),
                    ),
                    new InkWell(
                      onTap: _onOffersTapped,
                      child: SummaryCard(
                        total: dashboardData.totalOpenOffers == null
                            ? 0
                            : dashboardData.totalOpenOffers,
                        label: 'Open Invoice Offers',
                        totalStyle: Styles.pinkBoldMedium,
                      ),
                    ),
                    new InkWell(
                      onTap: _onInvoiceBidsTapped,
                      child: InvestorSummaryCard(dashboardData, context),
                    ),
                  ],
                ),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                  ),
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

  List<DropdownMenuItem<int>> items = List();

  Future _getOffers() async {
    offers = await ListAPI.getOpenOffers();
    setState(() {});
    print(
        '\n\n_DashboardState._getOffers ................ ${offers.length}\n\n');
  }

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

  final bigLabel = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: Colors.grey,
  );
  final smallLabel = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
    color: Colors.grey,
  );
  final totalStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: Colors.pink,
  );
  final totalStyleBlack = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: Colors.black,
  );
  final totalStyleTeal = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.teal,
  );

  @override
  onInvoiceBid(InvoiceBid bid) async {
    print(
        '\n\n_DashboardState.onInvoiceBid +++++++++++++ arrived safely. Bueno Senor!......... ${bid.investorName} ${bid.amount}\n\n');

    invoiceBids.insert(0, bid);
    setState(() {});
    await _getOffers();
    print('_DashboardState.onInvoiceBidMessage ############ ${offers.length}');
    setState(() {});
  }

  @override
  onOfferMessage(Offer offer) {
    print('_DashboardState.onOfferMessage');
    prettyPrint(offer.toJson(), 'OFFER arrived via FCM');
  }

  @override
  onInvoiceBidMessage(invoiceBid) async {
    print('\n\n_DashboardState.onInvoiceBidMessage \n${invoiceBid.toJson()}');
    invoiceBids.insert(0, invoiceBid);
    setState(() {});
    await _getOffers();
    print('_DashboardState.onInvoiceBidMessage ############ ${offers.length}');
    setState(() {});
  }

//  int totalInvoiceBids, totalOffers, totalNotes, totalPayments;
//  double totalInvoiceBidAmount = 0.00;
  final invoiceStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.pink,
  );
  final poStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.black,
  );
  final delNoteStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.blue,
  );
  final paymentStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.teal,
  );

  double opacity = 1.0;
  String name;
}

class InvestorSummaryCard extends StatelessWidget {
  final DashboardData dashboardData;
  final BuildContext context;
  InvestorSummaryCard(this.dashboardData, this.context);

  Widget _getTotalBids() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Number of Bids',
            style: Styles.greyLabelSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              dashboardData.totalBids == null
                  ? '0'
                  : '${dashboardData.totalBids}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTotalBidValue() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Total Bid Amount',
            style: Styles.greyLabelSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              dashboardData.totalBidAmount == null
                  ? '0'
                  : '${getFormattedAmount('${dashboardData.totalBidAmount}', context)}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAverageDiscount() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Average Discount',
            style: Styles.greyLabelSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              dashboardData.averageDiscountPerc == null
                  ? '0'
                  : '${getFormattedAmount('${dashboardData.averageDiscountPerc}', context)}%',
              style: Styles.purpleBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAverageBidAmount() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Average Bid Amount',
            style: Styles.greyLabelSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              dashboardData.averageBidAmount == null
                  ? '0'
                  : '${getFormattedAmount('${dashboardData.averageBidAmount}', context)}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      child: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 8.0,
          child: Column(
            children: <Widget>[
              Container(
                height: 140.0,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/fincash.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              _getTotalBids(),
              _getTotalBidValue(),
              _getAverageBidAmount(),
              _getAverageDiscount(),
              Container(
                child: RaisedButton(
                  elevation: 6.0,
                  color: Colors.indigo.shade400,
                  onPressed: _onBtnPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Show Charts',
                      style: Styles.whiteSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBtnPressed() {}
}
