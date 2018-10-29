import 'dart:async';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/invalid_trade.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:monitor/ui/theme_util.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: getTheme(),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    implements SnackBarListener, FCMListener {
  static const NUMBER_OF_BIDS_TO_MAKE = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  List<AutoTradeOrder> _orders;
  List<InvestorProfile> _profiles;
  DateTime startDate;
  OpenOfferSummary summary;

  @override
  void initState() {
    super.initState();
    _getLists(true);
    configureMessaging(this);
    _firebaseMessaging.subscribeToTopic('invoiceBids');
    _firebaseMessaging.subscribeToTopic('heartbeats');
    print(
        '_MyHomePageState.initState ############ subscribed to invoiceBids topic');
  }

  int minutes = 1;
  _getMinutes() async {
    minutes = await SharedPrefs.getMinutes();
    if (minutes == null || minutes == 0) {
      minutes = 10;
    }
    controller.text = '$minutes';
    setState(() {});
  }

  _getLists(bool showSnack) async {
    if (showSnack) {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Loading data for trades ...',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
    _orders = await ListAPI.getAutoTradeOrders();
    _profiles = await ListAPI.getInvestorProfiles();
    summary = await ListAPI.getOpenOffersSummary();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    await _getMinutes();

    if (_orders.isNotEmpty && _profiles.isNotEmpty) {
      _start();
    } else {
      print('_MyHomePageState._getLists ------- No orders to process');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No orders to process',
          textColor: Styles.lightBlue,
          backgroundColor: Styles.black);
    }
  }

  Timer timer;
  AutoTradeStart autoTradeStart = AutoTradeStart();

  ///start periodic timer to control AutoTradeExecutionBuilder
  _start() async {
    print(
        '_MyHomePageState._start ..... Timer.periodic(Duration((minutes: $minutes) time: ${DateTime.now().toIso8601String()}');
    if (timer != null) {
      if (timer.isActive) {
        timer.cancel();
        print(
            '_MyHomePageState._start -------- TIMER cancelled. timer.tick: ${timer.tick}');
      }
    }
    try {
      timer = Timer.periodic(Duration(minutes: minutes), (mTimer) async {
        print(
            '_MyHomePageState._start:\n\n\n TIMER tripping - starting AUTO TRADE cycle .......time: '
            '${DateTime.now().toIso8601String()}.  mTimer.tick: ${mTimer.tick}...\n\n');
        summary = await ListAPI.getOpenOffersSummary();

        if (summary.totalOpenOffers > 0) {
          setState(() {
            _showProgress = true;
            autoTradeStart = AutoTradeStart();
            invaliTrades.clear();
            bidsArrived.clear();
          });
          setState(() {
            messages.clear();
          });
          startDate = DateTime.now();
          autoTradeStart = await DataAPI3.executeAutoTrades();
          prettyPrint(
              autoTradeStart.toJson(), '\n\n####### RESULT from AutoTrades:');
          if (autoTradeStart == null) {
            AppSnackbar.showErrorSnackbar(
                scaffoldKey: _scaffoldKey,
                message: 'Problem with Auto Trade Session',
                listener: this,
                actionLabel: 'close');
          } else {
            setState(() {
              _showProgress = null;
            });
            prettyPrint(
                autoTradeStart.toJson(), '##### AutoTradeStart from Firestore');
            AppSnackbar.showSnackbar(
                scaffoldKey: _scaffoldKey,
                message: 'Auto Trade Session complete',
                textColor: Styles.white,
                backgroundColor: Styles.teal);
            _getLists(true);
          }
        } else {
          print('_MyHomePageState._start ***************'
              ' No open offers available. Will try again in $minutes minutes');
          AppSnackbar.showSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'No open offers in network',
              textColor: Styles.lightBlue,
              backgroundColor: Styles.black);
          return;
        }
      });
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Problem with Auto Trade Session',
          listener: this,
          actionLabel: 'close');
    }
  }

  List<InvoiceBid> bids = List();

  String time, count, amount;

  void summarize() {
    double t = 0.00;
    bids.forEach((m) {
      t += m.amount;
    });
    amount = '${getFormattedAmount('$t', context)}';
    this.count = '${bids.length}';
    time = getFormattedDateHour(DateTime.now().toIso8601String());
    setState(() {});
  }

  void _restart() async {
    print(
        '\n\n_MyHomePageState._restart ....starting auto trades ........... offers: $summary.totalOpenOffers\n\n');

    setState(() {
      messages.clear();
    });
    try {
      if (_orders.isNotEmpty &&
          _profiles.isNotEmpty &&
          summary.totalOpenOffers > 0) {
        setState(() {
          _showProgress = true;
          autoTradeStart = AutoTradeStart();
          invaliTrades.clear();
          bidsArrived.clear();
        });
        startDate = DateTime.now();
        autoTradeStart = await DataAPI3.executeAutoTrades();

        if (autoTradeStart == null) {
          AppSnackbar.showErrorSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'Problem with Auto Trade Session',
              listener: this,
              actionLabel: 'close');
        } else {
          print('_MyHomePageState._start ++++ summary in the house!');
          setState(() {
            _showProgress = null;
          });
          AppSnackbar.showSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'Auto Trade Session complete',
              textColor: Styles.white,
              backgroundColor: Styles.black);
          setState(() {});
          _getLists(false);
        }
      } else {
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'No open offers in network',
            textColor: Styles.lightBlue,
            backgroundColor: Styles.black);
      }
    } catch (e) {
      setState(() {
        _showProgress = null;
      });
      _getLists(false);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Problem with Auto Trade Session',
          listener: this,
          actionLabel: 'close');
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'OneConnect - BFN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  TextEditingController controller = TextEditingController();
  bool _showProgress;
  _refresh() {
    _getLists(true);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'BFN Monitor',
          style: Styles.whiteSmall,
        ),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Stack(
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
          _getBody(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _restart,
        tooltip: 'Restart',
        child: Icon(Icons.repeat),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  void _onMinutesChanged(String value) {
    minutes = int.parse(value);
    if (minutes == 0) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Zero is not valid for trade frequency',
          listener: this,
          actionLabel: 'close');
      return;
    }
    SharedPrefs.saveMinutes(minutes);
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Trading Timer set to $minutes minutes',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    _start();
  }

  void _onSessionTapped() {
//    if (bids.isEmpty && invalidUnits.isEmpty) {
//      AppSnackbar.showErrorSnackbar(
//          scaffoldKey: _scaffoldKey,
//          message: 'No session details available',
//          listener: this,
//          actionLabel: 'OK');
//      return;
//    }
//    Navigator.push(
//      context,
//      new MaterialPageRoute(
//          builder: (context) => new JournalPage(
//                bids: bids,
//                units: invalidUnits,
//              )),
//    );
  }

  Widget _getBody() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 4.0,
            color: Colors.orange.shade50,
            child: Column(
              children: <Widget>[
                _getSubHeader(),
                _getAutoTraderView(),
                _getOfferAmountView(),
                _getOfferAmount(),
              ],
            ),
          ),
        ),
        _getSessionCard(),
        _getSessionLog(),
      ],
    );
  }

  List<String> messages = List();
  Widget _getSessionLog() {
    if (messages.isEmpty) {
      return Container();
    }
    List<Widget> widgets = List();

    messages.forEach((message) {
      TextStyle style = Styles.blackMedium;
      if (message.contains('AutoTrade')) {
        style = Styles.blackBoldMedium;
      }
      if (message.contains('BFN')) {
        style = Styles.blackBoldMedium;
      }
      if (message.contains('ALLOWABLE')) {
        style = Styles.blueBoldMedium;
      }
      if (message.contains('completed')) {
        style = Styles.purpleBoldMedium;
      }
      if (message.contains('Matcher')) {
        style = Styles.blackBoldMedium;
      }
      var tile = ListTile(
        leading: Icon(
          Icons.apps,
          color: getRandomColor(),
        ),
        title: Text(
          message,
          style: style,
        ),
      );
      widgets.add(tile);
    });
    return Column(
      children: widgets,
    );
  }

  Widget _getSessionCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: GestureDetector(
        onTap: _onSessionTapped,
        child: Card(
          elevation: 8.0,
          color: Colors.purple.shade50,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                _getHeader(),
                _getTime(),
                _getAmount(),
                _getTrades(),
                _getPossible(),
                _getElapsed(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSubHeader() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Automatic Trade every',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 60.0, right: 100.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(),
            onChanged: _onMinutesChanged,
            maxLength: 3,
            style: Styles.purpleBoldMedium,
            decoration: InputDecoration(
              icon: Icon(Icons.access_time),
              labelText: 'Minutes',
            ),
          ),
        ),
      ],
    );
  }

  Widget _getAutoTraderView() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 20.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              'Auto Traders',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              _orders == null ? '0' : '${_orders.length}',
              style: Styles.pinkBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getOfferAmountView() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 20.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              'Open Offers',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              summary == null
                  ? '0'
                  : getFormattedNumber(summary.totalOpenOffers, context),
              style: Styles.blueBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getOfferAmount() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 20.0, bottom: 30.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 120.0,
            child: Text(
              'Offer Amount',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              summary == null
                  ? '0.00'
                  : '${getFormattedAmount('${summary.totalOfferAmount}', context)}',
              style: Styles.blackBoldMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            _showProgress == true ? '' : 'Auto Trading Session',
            style: Styles.greyLabelMedium,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  _showProgress == null ? '' : 'Auto Trade running...',
                  style: Styles.blueBoldMedium,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    child: _showProgress == null
                        ? Container()
                        : CircularProgressIndicator(
                            strokeWidth: 4.0,
                          ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTime() {
    return Row(
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Time: ',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Text(
            autoTradeStart.dateEnded == null
                ? '00:00'
                : getFormattedDateHour(autoTradeStart.dateEnded),
            style: Styles.purpleBoldMedium,
          ),
        ),
      ],
    );
  }

  Widget _getAmount() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            child: Text(
              'Amount:',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart.totalAmount == null
                  ? '0.00'
                  : getFormattedAmount(
                      '${autoTradeStart.totalAmount}', context),
              style: Styles.tealBoldLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTrades() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            child: Text(
              'Trades: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart.totalValidBids == null
                  ? '0'
                  : '${autoTradeStart.totalValidBids}',
              style: Styles.blackBoldLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPossible() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            child: Text(
              'Possible Total: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart.possibleAmount == null
                  ? '0.00'
                  : getFormattedAmount(
                      '${autoTradeStart.possibleAmount}', context),
              style: Styles.blackBoldLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getElapsed() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.0,
            child: Text(
              'Elapsed: ',
              style: Styles.greyLabelSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              autoTradeStart.elapsedSeconds == null
                  ? '0.0'
                  : '${autoTradeStart.elapsedSeconds} seconds',
              style: Styles.blueMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<InvoiceBid> bidsArrived = List();
  List<InvalidTrade> invaliTrades = List();
  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print(
        '_MyHomePageState.onInvoiceBidMessage ############# INVOICE BID arrived: ${invoiceBid.amount} ${invoiceBid.investorName}');
    var msg =
        'Invoice Bid ${getFormattedAmount('${invoiceBid.amount}', context)} '
        'reserved: ${invoiceBid.reservePercent} % \n Bid made at: ${getFormattedDateHour(DateTime.now().toIso8601String())}';
    bidsArrived.add(invoiceBid);
    var tot = 0.00;
    bidsArrived.forEach((bid) {
      tot += bid.amount;
    });

    if (autoTradeStart == null) {
      autoTradeStart = AutoTradeStart();
    }
    autoTradeStart.totalAmount = tot;
    autoTradeStart.totalValidBids = bidsArrived.length;
    autoTradeStart.elapsedSeconds =
        DateTime.now().difference(startDate).inSeconds * 1.0;
    autoTradeStart.dateEnded =
        getFormattedDateHour('${DateTime.now().toIso8601String()}');
    _getLists(false);
    setState(() {
      messages.add(msg);
    });
    print(msg);
    print(
        '\n_MyHomePageState.onInvoiceBidMessage ... bids arrived: ${bidsArrived.length}\n\n');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: msg,
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }

  @override
  onInvalidTrade(InvalidTrade invalidTrade) {
    prettyPrint(invalidTrade.toJson(), '\n\n###### InvalidTrade arrived:');
    invaliTrades.add(invalidTrade);
    if (autoTradeStart == null) {
      autoTradeStart = AutoTradeStart();
    }

    setState(() {
      autoTradeStart.dateEnded =
          getFormattedDateHour('${DateTime.now().toIso8601String()}');
      autoTradeStart.totalInvalidBids = invaliTrades.length;
      autoTradeStart.elapsedSeconds =
          DateTime.now().difference(startDate).inSeconds * 1.0;
    });
  }

  String _getTotalInvalidAmount() {
    double tot = 0.00;
    invaliTrades.forEach((t) {
      tot += t.offer.offerAmount;
    });
    return getFormattedAmount('$tot', context);
  }

  @override
  onOfferMessage(Offer offer) {
    print('_MyHomePageState.onOfferMessage');
    prettyPrint(offer.toJson(), 'OFFER arrived via FCM');
  }

  @override
  onHeartbeat(Map map) {
    print('\n\n_MyHomePageState.onHeartbeat ############ map: $map');
    if (_showProgress == null || _showProgress == false) {
      return;
    }
    print('_MyHomePageState.onHeartbeat updating messages');
    setState(() {
      messages.add(map['message']);
    });
//    AppSnackbar.showSnackbar(
//        scaffoldKey: _scaffoldKey,
//        message: map['message'],
//        textColor: Styles.white,
//        backgroundColor: Colors.deepOrange);
  }
}
