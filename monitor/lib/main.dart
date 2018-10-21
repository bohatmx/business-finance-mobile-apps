import 'dart:async';
import 'dart:io';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
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
  List<Offer> _offers;

  @override
  void initState() {
    super.initState();
    _getLists(true);
    configureMessaging(this);
    _firebaseMessaging.subscribeToTopic('invoiceBids');
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
    _offers = await ListAPI.getOpenOffers();
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
  AutoTradeStart autoTradeStart;

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
    timer = Timer.periodic(Duration(minutes: minutes), (mTimer) async {
      print(
          '_MyHomePageState._start:\n\n\n TIMER tripping - starting AUTO TRADE cycle .......time: '
          '${DateTime.now().toIso8601String()}.  mTimer.tick: ${mTimer.tick}...\n\n');
      _offers = await ListAPI.getOpenOffers();
      if (_offers.isNotEmpty) {
        setState(() {
          _showProgress = true;
        });
        var result = await DataAPI3.executeAutoTrades();
        if (result > 0) {
          AppSnackbar.showErrorSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'Problem with Auto Trade Session',
              listener: this,
              actionLabel: 'close');
        } else {
          sleep(Duration(seconds: 1));
          autoTradeStart = await SharedPrefs.getAutoTradeStart();
          print('_MyHomePageState._start ++++ summary in the house!');
          setState(() {
            _showProgress = false;
          });
          autoTradeStart = await ListAPI.getAutoTradeStart();
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
        return;
      }
    });
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

  @override
  onError(int count) {
    print(
        '_MyHomePageState.onError ....ERROR ERROOR..... processed; $count timer.tick: ${timer.tick}');
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Auto Trades ERROR. Processed OK: $count',
        listener: this,
        actionLabel: 'close');
  }

  void _restart() async {
    await _getLists(true);
    setState(() {});
    print(
        '\n\n_MyHomePageState._restart ....starting auto trades ........... offers: ${_offers.length}\n\n');
    if (_orders.isNotEmpty && _profiles.isNotEmpty && _offers.isNotEmpty) {
      setState(() {
        _showProgress = true;
      });
      var result = await DataAPI3.executeAutoTrades();

      if (result > 0) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Problem with Auto Trade Session',
            listener: this,
            actionLabel: 'close');
      } else {
        sleep(Duration(seconds: 2));
        autoTradeStart = await SharedPrefs.getAutoTradeStart();
        print('_MyHomePageState._start ++++ summary in the house!');
        setState(() {
          _showProgress = false;
        });
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Auto Trade Session complete',
            textColor: Styles.white,
            backgroundColor: Styles.black);
        autoTradeStart = await ListAPI.getAutoTradeStart();
        prettyPrint(
            autoTradeStart.toJson(), '##### AutoTradeStart from Firestore');
        setState(() {});
        _getLists(false);
      }
    }
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
                  'OneConnect - BFN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
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
  bool _showProgress = true;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Business Finance Network'),
        bottom: _getBottom(),
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

//  @override
//  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {
//    print('_MyHomePageState.onDeliveryAcceptance');
//  }
//
//  @override
//  onDeliveryNote(DeliveryNote deliveryNote) {
//    print('_MyHomePageState.onDeliveryNote');
//  }
//
//  @override
//  onInvoice(Invoice invoice) {
//    print('_MyHomePageState.onInvoice');
//  }
//
//  @override
//  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance) {
//    print('_MyHomePageState.onInvoiceAcceptance');
//  }
//
//  @override
//  onInvoiceBid(InvoiceBid bid) {
//    print('_MyHomePageState.onInvoiceBid');
//  }
//
//  @override
//  onOffer(Offer offer) {
//    print('_MyHomePageState.onOffer');
//  }
//
//  @override
//  onPurchaseOrder(PurchaseOrder purchaseOrder) {
//    print('_MyHomePageState.onPurchaseOrder');
//  }

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
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Automatic Trade every',
                        style: Styles.greyLabelMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, right: 100.0),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.numberWithOptions(),
                        onChanged: _onMinutesChanged,
                        maxLength: 3,
                        style: Styles.purpleBoldLarge,
                        decoration: InputDecoration(
                          icon: Icon(Icons.access_time),
                          labelText: 'Minutes',
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, left: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Auto Trade Orders',
                        style: Styles.greyLabelMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _orders == null ? '0' : '${_orders.length}',
                          style: Styles.pinkBoldReallyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4.0, left: 20.0, bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Open Invoice Offers',
                        style: Styles.greyLabelMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _offers == null ? '0' : '${_offers.length}',
                          style: Styles.blueBoldReallyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            _showProgress == true ? '' : 'Auto Trading Session',
                            style: Styles.greyLabelMedium,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _showProgress == false
                                  ? ''
                                  : 'Auto Trade running...',
                              style: Styles.blueBoldMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 80.0,
                          child: Text(
                            'Time: ',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            autoTradeStart == null
                                ? '00:00'
                                : getFormattedDateHour(
                                    autoTradeStart.dateEnded),
                            style: Styles.purpleBoldLarge,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80.0,
                            child: Text(
                              'Amount:',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              autoTradeStart == null
                                  ? '0.00'
                                  : getFormattedAmount(
                                      '${autoTradeStart.totalAmount}', context),
                              style: Styles.tealBoldLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80.0,
                            child: Text(
                              'Trades: ',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              autoTradeStart == null
                                  ? '0'
                                  : '${autoTradeStart.totalValidBids}',
                              style: Styles.blackBoldLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80.0,
                            child: Text(
                              'Invalid: ',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              autoTradeStart == null
                                  ? '0'
                                  : '${autoTradeStart.totalInvalidBids}',
                              style: Styles.pinkBoldLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 80.0,
                            child: Text(
                              'Possible Amount: ',
                              style: Styles.greyLabelSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              autoTradeStart == null
                                  ? '0'
                                  : getFormattedAmount(
                                      '${autoTradeStart.possibleAmount}',
                                      context),
                              style: Styles.pinkBoldLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print('_MyHomePageState.onInvoiceBidMessage ${invoiceBid.toJson()}');
    var msg =
        'Invoice Bid ${invoiceBid.amount} reserved: ${invoiceBid.reservePercent} \n Bid at: ${getFormattedDateHour(DateTime.now().toIso8601String())}';
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: msg,
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }
}
