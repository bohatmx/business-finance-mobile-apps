import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/ui/offer_list.dart';

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
    implements SnackBarListener, FCMListener {
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
    _configMessaging();
    items = buildDaysDropDownItems();
  }

  void _configMessaging() async {
    configureMessaging(this);
    basicMessageChannel = BasicMessageChannel(
        'com.oneconnect.biz.CHANNEL/message', new StringCodec());
    basicMessageChannel.setMessageHandler((msg) {
      print('_DashboardState._configMessaging message from Android side: $msg');
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: msg,
          textColor: Colors.white,
          backgroundColor: Colors.deepPurple,
          actionLabel: "OK",
          listener: this,
          icon: Icons.add_alert);
    });
    var parms = {
      'title': 'Business Finance Network',
      'content': 'This is a test notification for the investors!!',
    };
    final String result = await platform.invokeMethod('setNotification', parms);
    print('_DashboardState._configMessaging METHOD CALL result: $result');
    investor = await SharedPrefs.getInvestor();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///get  summaries from Firestore
  _getSummaryData() async {
    prettyPrint(investor.toJson(), 'Dashboard_getSummaryData: ');

    await _getOffers();
    await _getInvoiceBids();
    await _getSettlements();
  }

  Future _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    investor = await SharedPrefs.getInvestor();
    assert(investor != null);
    name = investor.name;
    setState(() {});
    _getSummaryData();
  }

  Future _getSettlements() async {
    print('_DashboardState._getSettlements ......');
  }

  Future _getInvoiceBids() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh invoiceBid data',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    invoiceBids =
        await ListAPI.getInvoiceBidsByInvestor(investor.participantId);
    if (invoiceBids.isNotEmpty) {
      lastInvoiceBid = invoiceBids.last;
    }
    setState(() {
      totalInvoiceBids = invoiceBids.length;
    });
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  int totalInvoiceBids, totalOffers, totalNotes, totalPayments;
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
    if (message != null) {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: message,
          textColor: Colors.white,
          icon: Icons.done_all,
          listener: this,
          actionLabel: 'OK',
          backgroundColor: Colors.black);
    }
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
          title: Text(
            'BFN - Dashboard',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          leading: Container(),
          bottom: _getBottom(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _getSummaryData,
            ),
            IconButton(
              icon: Icon(Icons.category),
              onPressed: _toggleView,
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
                padding: const EdgeInsets.only(top: 10.0),
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
                        label: 'Payments',
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

  void _toggleView() {
    print('_MainPageState._toggleView .... ');
    if (opacity == 0.0) {
      opacity = 1.0;
    } else {
      opacity = 0.0;
    }

    setState(() {});
  }

  refresh() {
    print(
        '_DashboardState.refresh: ################## REFRESH called. getSummary ...');
    _getSummaryData();
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  start DeliveryAcceptance ==> create invoice');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new OfferList()),
    );
  }

  void _onPaymentsTapped() {
    print('_DashboardState._onPaymentsTapped ............');
  }

  void _onInvoiceBidsTapped() {
    print('_DashboardState._onInvoiceTapped ...............');
  }

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {}

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {}

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {}

  @override
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement) {}

  @override
  onInvestorSettlement(InvestorInvoiceSettlement settlement) {}

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {}

  @override
  onInvoiceMessage(Invoice invoice) {}

  @override
  onOfferMessage(Offer offer) {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Offer arrived',
        textColor: Colors.white,
        backgroundColor: Colors.teal,
        actionLabel: 'INVOICE',
        listener: this,
        icon: Icons.done);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    prettyPrint(purchaseOrder.toJson(), 'po arrived');
  }

  @override
  onWalletError() {
    print('_DashboardState.onWalletError');
    AppSnackbar.showErrorSnackbar(
      scaffoldKey: _scaffoldKey,
      message: 'Wallet creation failed',
      actionLabel: 'Error',
      listener: this,
    );
  }

  @override
  onWalletMessage(Wallet wallet) async {
    prettyPrint(wallet.toJson(), 'Dashboard.onWalletMessage: @@@@@@@@ wallet:');
    var dec = await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
    print('_DashboardState.onWalletMessage decrypted secret: $dec');
    await SharedPrefs.saveWallet(wallet);
    DataAPI api = DataAPI(getURL());
    await api.addWallet(wallet);
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Wallet Created',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.done);
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
                padding: const EdgeInsets.all(8.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
                child: Text(
                  fullName == null ? 'user' : fullName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

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
    fontSize: 16.0,
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
    fontSize: 20.0,
    color: Colors.teal,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: new Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 6.0,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Text(
                  'Your Invoice Bids',
                  style: bigLabel,
                ),
              ),
              new Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Open Invoice Bids',
                      style: smallLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        '10,000,000.00',
                        style: totalStyleTeal,
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
                      'Settled Invoice Bids',
                      style: smallLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        '99,000,000.00',
                        style: totalStyleBlack,
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
