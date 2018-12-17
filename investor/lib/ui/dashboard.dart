import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/blocs/chat_bloc.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/chat_response.dart';
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
import 'package:businesslibrary/util/message.dart';
import 'package:businesslibrary/util/support/chat_page.dart';
import 'package:businesslibrary/util/support/contact_us.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:businesslibrary/blocs/investor_model_bloc.dart';
import 'package:investor/investor_summary_card.dart';
import 'package:investor/ui/charts.dart';
import 'package:investor/ui/offer_list.dart';
import 'package:investor/ui/profile.dart';
import 'package:investor/ui/unsettled_bids.dart';

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
    implements SnackBarListener, InvestorCardListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.biz.CHANNEL');

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
    appModel = investorModelBloc.appModel;
  }

  List<Offer> mOfferList = List();
  List<InvestorProfile> profiles = List();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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

  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\ _DashboardState################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');
    bool isRunningIOs = await isDeviceIOS();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n_DashboardState ################ Message from FCM ################# ${DateTime.now().toIso8601String()}');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOs == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print('FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('_DashboardState.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              '_DashboardState.configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            '_DashboardState.configureFCM ************************** messageType: $messageType');

        try {
          switch (messageType) {
            case 'OFFER':
              var m = Offer.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM OFFER MESSAGE :');
              onOfferMessage(m);
              break;
            case 'CHAT_RESPONSE':
              var m = ChatResponse.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM CHAT_RESPONSE MESSAGE :');
              onChatResponseMessage(m);
              break;
            case 'INVOICE_BID':
              var m = InvoiceBid.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM INVOICE_BID MESSAGE :');
              onInvoiceBidMessage(m);
              break;

            case 'INVESTOR_INVOICE_SETTLEMENT':
              Map map = json.decode(mJSON);
              prettyPrint(
                  map, '\n\n########## FCM INVESTOR_INVOICE_SETTLEMENT :');
              onInvestorInvoiceSettlement(
                  InvestorInvoiceSettlement.fromJson(map));
              break;
          }
        } catch (e) {
          print(
              '_DashboardState.configureFCM - Houston, we have a problem with null listener somewhere. error below\n\n');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print('_DashboardState.configureFCM  onLaunch *********** ');
        prettyPrint(message, 'message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print('_DashboardState.configureFCM  onResume *********** ');
        prettyPrint(message, 'message delivered on RESUME!');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});

    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _firebaseMessaging
        .subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + investor.participantId);
    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_OFFERS);
    _firebaseMessaging.subscribeToTopic(
        FCM.TOPIC_INVESTOR_INVOICE_SETTLEMENTS + investor.participantId);
    print(
        '\n\n_DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - Bids, Offers, Settlements and General');
  }
  //end of FCM methods ######################

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

  void _setTheme(int index) {
    themeBloc.changeToTheme(index);
  }
  Future _getCachedPrefs() async {
    var index = await SharedPrefs.getThemeIndex();
    _setTheme(index);
    investor = await SharedPrefs.getInvestor();
    _configureFCM();
    _checkSectors();
    user = await SharedPrefs.getUser();
    appModel = investorModelBloc.appModel;
    setState(() {
      count = 0;
    });
  }

  InvoiceBid lastInvoiceBid;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  @override
  Widget build(BuildContext context) {
    if (appModel == null || appModel.investor == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard loading'),
        ),
      );
    }
    print('\n\n\n_DashboardState.build ********** DASHBOARD RE_BUILD ***********');
//    _configureFCM();
    return StreamBuilder<InvestorAppModel2>(
        initialData: investorModelBloc.appModel,
        stream: investorModelBloc.appModelStream,
        builder: (context, snapshot) {
          appModel = snapshot.data;
          investor = appModel.investor;
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
                    icon: Icon(Icons.refresh),
                    onPressed: _refresh,
                  ),
                  IconButton(
                    icon: Icon(Icons.help),
                    onPressed: _goToContactUsPage,
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
        leading: m.icon,
        title: Text(
          '${m.message}',
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

  void _goToContactUsPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ContactUs()),
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

  List<Message> messages = List();

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

  onInvoiceBidMessage(InvoiceBid bid) async {
    print(
        '_DashboardState.onInvoiceBidMessage - bid arrived in dashboard ###############################');
    this.invoiceBid = bid;
    invoiceBidArrived = true;

    setState(() {
      messages.add(Message(
          type: Message.INVOICE_BID,
          message:
              'Invoice Bid made: ${getFormattedDateShortWithTime('${bid.date}', context)} ',
          subTitle: bid.supplierName));
    });

    _showSnack(
        'Invoice Bid arrived ${getFormattedAmount('${bid.amount}', context)}');
    var id = bid.investor.split('#').elementAt(1);
    if (id == investor.participantId) {
      _showBottomSheet(bid);
    }
    await investorModelBloc.refreshDashboard();
  }

  double opacity = 1.0;
  String name;

  bool offerArrived = false;

  onOfferMessage(Offer offer) async {
    print(
        '_DashboardState.onOfferMessage #################### ${offer.supplierName} ${offer.offerAmount}');
    setState(() {
      messages.add(Message(
          type: Message.OFFER,
          message:
              'Offer arrived: ${getFormattedDateShortWithTime('${offer.date}', context)} ',
          subTitle: offer.supplierName));
    });
    await investorModelBloc.refreshDashboard();
    _showSnack(
        'Offer arrived ${getFormattedAmount('${offer.offerAmount}', context)}');
  }

  onInvestorInvoiceSettlement(InvestorInvoiceSettlement s) async {
    print('_DashboardState.onInvestorInvoiceSettlement');
    setState(() {
      messages.add(Message(
          type: Message.SETTLEMENT,
          message:
              'Settlement arrived: ${getFormattedDateShortWithTime('${s.date}', context)} ',
          subTitle: s.supplierName));
    });
    await investorModelBloc.refreshDashboard();
  }

  void _showSnack(String message) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: Styles.white,
        backgroundColor: Theme.of(context).primaryColor);
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
    themeBloc.changeToRandomTheme();
  }

  void onChatResponseMessage(ChatResponse chatResponse) {
    this.chatResponse = chatResponse;
    prettyPrint(
        chatResponse.toJson(), 'DASHBOARD: ############ chatResponse received, should start Chat');
    _showSnack(chatResponse.responseMessage);
    //_showGoToChatDialog();
    chatBloc.receiveChatResponse(chatResponse);


  }
  ChatResponse chatResponse;
  void _showGoToChatDialog() {

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(
            "Respond to Incoming Message",
            style: Styles.greyLabelMedium,
          ),
          content: Container(
            height: 200.0,
            child: Text(
                'Do you  want to respond to this message:\n${chatResponse.responseMessage}\nfrom ${chatResponse.responderName}'),
          ),
          actions: <Widget>[
            FlatButton(onPressed: _ignore, child: Text('NO')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                  color: Colors.teal,
                  onPressed: _goToChat, child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('YES', style: Styles.whiteSmall,),
                  ),),
            ),
          ],
        ));
  }

  void _ignore() {
    Navigator.pop(context);
  }
  void _goToChat() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
              chatResponse: chatResponse,
            )));
  }
}

class BidMessage {
  String title, subTitle;

  BidMessage({this.title, this.subTitle});
}
