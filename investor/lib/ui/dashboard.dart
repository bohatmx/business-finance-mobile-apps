import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
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
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investor/app_model.dart';
import 'package:investor/investor_model_bloc.dart';
import 'package:investor/investor_summary_card.dart';
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
    implements
        SnackBarListener,
        InvoiceBidListener,
        OfferListener,
        InvestorCardListener,
        ModelListener {
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
  InvestorAppModel2 appModel;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }


  List<Offer> mOfferList = List();
  List<InvestorProfile> profiles = List();
  FCM _fcm = FCM();
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
    _fcm.configureFCM(invoiceBidListener: this, offerListener: this);
    _fm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS);
    _fm.subscribeToTopic(FCM.TOPIC_OFFERS);
    print(
        '_DashboardState._subscribeToFCM ########## subscribed! ${FCM.TOPIC_INVOICE_BIDS} and ${FCM.TOPIC_OFFERS}');
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

  List<InvoiceBid> bids;

  void _refresh() async {
    print('_DashboardState._refresh ............ requesting refresh ...');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Refreshing data',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    await investorModelBloc.refreshDashboard();
    _scaffoldKey.currentState.removeCurrentSnackBar();
    setState(() {
      count = 0;
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
    setState(() {
      count = 0;
    });
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InvestorAppModel2>(
        initialData: investorModelBloc.appModel,
        stream: investorModelBloc.appModelStream,
        builder: (context, snapshot) {
          appModel = snapshot.data;
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
                leading: IconButton(
                    icon: Icon(
                      Icons.apps,
                      color: Colors.white,
                    ),
                    onPressed: _changeTheme),
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
        });
  }

  int count = 0;

  Widget _getBody() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.3,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fincash.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: _getListView(),
        ),
      ],
    );
  }

  Widget _getListView() {
    var tiles = List<ListTile>();
    tiles.clear();
    messages.forEach((m) {
      var tile = ListTile(
        leading: Icon(
          Icons.apps,
          color: getRandomColor(),
        ),
        title: Text(
          '${m.title}',
          style: Styles.blackBoldSmall,
        ),
        subtitle: Text(
          '${m.subTitle}',
          style: Styles.blackSmall,
        ),
      );
      tiles.add(tile);
    });

    return appModel == null
        ? Container()
        : ListView(
            children: <Widget>[
              new InkWell(
                onTap: _onInvoiceBidsTapped,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: InvestorSummaryCard(
                    context: context,
                    listener: this,
                    appModel: appModel,
                  ),
                ),
              ),
              new InkWell(
                onTap: _onOffersTapped,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SummaryCard(
                    total: appModel.dashboardData == null
                        ? 0
                        : appModel.dashboardData.totalOpenOffers,
                    label: 'Offers Open for Bids',
                    totalStyle: Styles.pinkBoldMedium,
                    totalValue: appModel.dashboardData == null
                        ? 0.00
                        : appModel.dashboardData.totalOpenOfferAmount,
                    totalValueStyle: Styles.tealBoldMedium,
                  ),
                ),
              ),
              messages == null
                  ? Container()
                  : Column(
                      children: tiles,
                    ),
            ],
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
    setState(() {});
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

  void _onInvoiceBidsTapped() async {
    print('_DashboardState._onInvoiceTapped ...............');

    if (appModel.unsettledInvoiceBids.isEmpty) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No outstanding invoice bids\nRefresh data ...',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      await investorModelBloc.refreshDashboard();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnsettledBids()),
    );
  }

  String mTitle = 'BFN is Rock Solid!';

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: appModel == null
            ? Container()
            : Column(
                children: <Widget>[
                  Text(
                    appModel.investor == null ? '' : appModel.investor.name,
                    style: Styles.yellowBoldMedium,
                  ),
                ],
              ),
      ),
    );
  }

/*
Column(
                   children: <Widget>[

                     refreshModel == false
                         ? Container()
                         : Padding(
                             padding: const EdgeInsets.only(bottom: 8.0),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: <Widget>[
                                 Padding(
                                   padding:
                                       const EdgeInsets.only(right: 8.0),
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
 */
  AutoTradeOrder order;
  InvestorProfile profile;
  OpenOfferSummary offerSummary;

  List<DropdownMenuItem<int>> items = List();

  void _onOffersTapped() {
    print('_DashboardState._onOffersTapped');
    Navigator.push(
      context,
      new MaterialPageRoute(
          maintainState: false, builder: (context) => new OfferList()),
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

  List<BidMessage> messages = List();

  InvoiceBid invoiceBid;
  _showBottomSheet(InvoiceBid bid) {
    if (_scaffoldKey.currentState == null) return;
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: Duration(seconds: 2),
        height: 420.0,
        color: Colors.brown.shade200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Auto Trading Result: ${getFormattedDateHour('${DateTime.now()}')}',
                    style: Styles.blackBoldMedium,
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

  bool invoiceBidArrived = false;
  @override
  onInvoiceBidMessage(InvoiceBid bid) async {
    print(
        '_DashboardState.onInvoiceBidMessage - bid arrived in dashboard ###############################');
    this.invoiceBid = bid;
    invoiceBidArrived = true;

    setState(() {});
    String msg =
        'Bid made, amount: ${getFormattedAmount('${bid.amount}', context)} discount; ${bid.discountPercent.toStringAsFixed(2)} %';

    var id = bid.investor.split('#').elementAt(1);
    if (id == investor.participantId) {
      var amt = getFormattedAmount('${bid.amount}', context);
      var dt = getFormattedDateShortWithTime(
          '${DateTime.parse(bid.date).toLocal().toIso8601String()}', context);
      var msg =
          BidMessage(title: 'Invoice Bid made for: $amt', subTitle: '$dt');
      setState(() {
        messages.add(msg);
      });
      _showBottomSheet(bid);
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: msg,
          textColor: Styles.white,
          backgroundColor: Theme.of(context).primaryColor);
    }
  }

  double opacity = 1.0;
  String name;

  bool offerArrived = false;
  @override
  onOfferMessage(Offer offer) async {
    print(
        '_DashboardState.onOfferMessage #################### ${offer.supplierName} ${offer.offerAmount}');
    setState(() {
      this.offer = offer;
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

  @override
  onComplete() {
    print(
        '\n\n_DashboardState.onComplete - ####################### message from AppModel, ######### what now??, kill snackbar?');
    try {
      setState(() {
        //refreshModel = true;
      });
      _scaffoldKey.currentState.removeCurrentSnackBar();
    } catch (e) {
      print('_DashboardState.onComplete -- error killing snackbar or state $e');
    }
  }

  @override
  onCharts() {
    print('_DashboardState.onCharts ..................');
    investorModelBloc.refreshDashboard();

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Charts()),
    );
    return null;
  }

  @override
  onRefresh() {
    print('_DashboardState.onRefresh call: appModel.refreshInvoiceBids(); ');
    investorModelBloc.refreshDashboard();
    return null;
  }

  void _changeTheme() {
    bloc.changeToRandomTheme();
  }
}

class BidMessage {
  String title, subTitle;

  BidMessage({this.title, this.subTitle});
}
