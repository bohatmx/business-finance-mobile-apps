import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/ui/firestore_listener.dart';
import 'package:investor/ui/offer_list.dart';
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
    with TickerProviderStateMixin
    implements SnackBarListener, OfferListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.biz.CHANNEL');

  String message;
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

  @override
  initState() {
    super.initState();
    print('_DashboardState.initState .............. to get summary');
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);
    _getCachedPrefs();

    items = buildDaysDropDownItems();
    _checkSectors();
  }

  void _checkSectors() async {
    sectors = await ListAPI.getSectors();
    if (sectors.isEmpty) {
      var api = DataAPI(getURL());
      api.addSectors();
    }
  }

  List<Sector> sectors;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///get  summaries from Firestore
  _getSummaryData() async {
    prettyPrint(investor.toJson(), 'Dashboard_getSummaryData: ');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    await _getOffers();
    await _getInvoiceBids();
    await _getSettlements();
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  Future _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    investor = await SharedPrefs.getInvestor();

    assert(investor != null);
    name = investor.name;
    listenForOffer(this);
    setState(() {});
    _getSummaryData();
  }

  Future _getSettlements() async {
    print('_DashboardState._getSettlements ......');
  }

  Future _getInvoiceBids() async {
    invoiceBids =
        await ListAPI.getInvoiceBidsByInvestor(investor.documentReference);
    print('_DashboardState._getInvoiceBids +++++++ ${invoiceBids.length}');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (invoiceBids.isNotEmpty) {
      lastInvoiceBid = invoiceBids.last;
    }
    setState(() {
      totalInvoiceBids = invoiceBids.length;
    });
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    invoiceBids.forEach((n) {
      totalInvoiceBidAmount += n.amount;
    });
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  int totalInvoiceBids, totalOffers, totalNotes, totalPayments;
  double totalInvoiceBidAmount = 0.00;
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

  @override
  Widget build(BuildContext context) {
    message = widget.message;

    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
//          backgroundColor: Colors.indigo.shade400,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Row(
                        children: <Widget>[
                          DropdownButton<int>(
                            items: items,
                            value: _days,
                            elevation: 4,
                            onChanged: _onDropDownChanged,
                          ),
                        ],
                      ),
                    ),
                    new InkWell(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: totalPayments == null ? 0 : totalPayments,
                        label: 'Bids Settled',
                        totalStyle: paymentStyle,
                      ),
                    ),
                    new InkWell(
                      onTap: _onOffersTapped,
                      child: SummaryCard(
                        total: totalOffers == null ? 0 : totalOffers,
                        label: 'Invoice Offers',
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new InkWell(
                      onTap: _onInvoiceBidsTapped,
                      child: InvoiceBidSummaryCard(invoiceBids),
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
  int _days = 7;

  List<DropdownMenuItem<int>> items = List();

  void _onDropDownChanged(int value) async {
    print('_DashboardState._onDropDownChanged ..... value: $value');
    setState(() {
      _days = value;
    });

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading $_days days data ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    await _getOffers();
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
  }

  DateTime startTime, endTime;

  Future _getOffers() async {
    print('_DashboardState._getOffers ................');
    endTime = DateTime.now();
    startTime = DateTime.now().subtract(Duration(days: _days));
    offers = await ListAPI.getOffersByPeriod(startTime, endTime);
    setState(() {
      totalOffers = offers.length;
    });
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
    prettyPrint(offer.toJson(), '_DashboardState.onOffer');
    DateTime now = DateTime.now();
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
}

class InvoiceBidSummaryCard extends StatelessWidget {
  final List<InvoiceBid> bids;

  InvoiceBidSummaryCard(this.bids);

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
  double totalBidAmount = 0.00;
  int numberOfBids = 0;
  @override
  Widget build(BuildContext context) {
    bids.forEach((m) {
      totalBidAmount += m.amount;
    });
    print('InvoiceBidSummaryCard.build totalBidAmount: $totalBidAmount');
    return Container(
      height: 140.0,
      child: new Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 6.0,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 2.0),
                child: Text(
                  'Your Invoice Bids',
                  style: Styles.greyLabelSmall,
                ),
              ),
              new Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total Value',
                      style: smallLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        totalBidAmount == null
                            ? '0.00'
                            : getFormattedAmount('$totalBidAmount', context),
                        style: Styles.tealBoldLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Number of Bids',
                      style: smallLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        bids == null ? '0' : '${bids.length}',
                        style: Styles.blackBoldLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
