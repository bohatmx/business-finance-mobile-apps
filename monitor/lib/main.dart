import 'dart:async';
import 'dart:collection';

import 'package:businesslibrary/api/auto_trade.dart';
import 'package:businesslibrary/api/file_util.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:monitor/local_util.dart';
import 'package:monitor/ui/journal.dart';
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
    implements BlockchainListener, SnackBarListener, AutoTradeListener {
  static const NUMBER_OF_BIDS_TO_MAKE = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<AutoTradeOrder> _orders;
  List<InvestorProfile> _profiles;
  List<Offer> _offers;
  AutoTradeExecutionBuilder autoTradeExecutionBuilder;

  @override
  void initState() {
    super.initState();
//    BlockchainUtil.listenForBlockchainEvents(this);
    _getLists();
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

  _getLists() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading data for trades ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
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

      _showProgress = true;
      setState(() {});
      _offers = await ListAPI.getOpenOffers();
      if (_offers.isNotEmpty) {
        _orders = await ListAPI.getAutoTradeOrders();
        _profiles = await ListAPI.getInvestorProfiles();
        _orders.shuffle();
      } else {
        print('_MyHomePageState._start ***************'
            ' No open offers available. Will try again in $minutes minutes');
        return;
      }

      _offers.sort((a, b) => b.offerAmount.compareTo(a.offerAmount));
      if (_orders.isNotEmpty && _profiles.isNotEmpty && _offers.isNotEmpty) {
        autoTradeExecutionBuilder = AutoTradeExecutionBuilder();
        autoTradeExecutionBuilder.executeAutoTrades(
            _orders, _profiles, _offers, this);
      }
    });
  }

  int _index = 0;
  List<InvoiceBid> bids = List();
  @override
  onInvoiceAutoBid(InvoiceBid bid) async {
    this.bids.add(bid);
    print(
        '_MyHomePageState.onInvoiceBid -- telling the folks back home we invested in an Offer ))))) ${bid.amount}');
    try {
      List<InvoiceBid> mbids = await FileUtil.getInvoiceBids();
      if (mbids == null) {
        mbids = List();
      }
      bids.forEach((m) {
        mbids.insert(0, m);
      });
      bids.sort((a, b) => b.date.compareTo(a.date));
      var x = InvoiceBids(bids);
      await FileUtil.saveInvoiceBids(x);
    } catch (e) {
      print('_MyHomePageState.onInvalidTrade  FILE PROBLEM $e');
    }

    summarize();
  }

  String time, count, amount;
  @override
  onComplete(int count) async {
    print(
        '_MyHomePageState.onComplete ......... processed; $count timer.tick: ${timer.tick} bids: ${bids.length} offers: ${_offers.length}');
    _offers = await ListAPI.getOpenOffers();
    _showProgress = false;
    summarize();
  }

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
    _showProgress = true;
    setState(() {});
    await _getLists();
    setState(() {});
    print(
        '\n\n_MyHomePageState._restart ....startting auto trades ........... offers: ${_offers.length}\n\n');
    if (_orders.isNotEmpty && _profiles.isNotEmpty && _offers.isNotEmpty) {
      var z = AutoTradeExecutionBuilder();
      z.executeAutoTrades(_orders, _profiles, _offers, this);
    } else {
      _showProgress = false;
      setState(() {});
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
      body: ListView(
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
                        padding:
                            const EdgeInsets.only(left: 60.0, right: 100.0),
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
                    padding: const EdgeInsets.only(
                        top: 4.0, left: 20.0, bottom: 10.0),
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
                              _showProgress == true
                                  ? ''
                                  : 'Auto Trading Session',
                              style: Styles.greyLabelMedium,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _showProgress == false
                                    ? ''
                                    : 'Auto Trade running...',
                                style: Styles.blueMedium,
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
                              time == null ? '00:00' : time,
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
                                amount == null ? '0.00' : amount,
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
                                count == null ? '0' : count,
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
                                invalidUnits == null
                                    ? '0'
                                    : '${invalidUnits.length}',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _restart,
        tooltip: 'Restart',
        child: Icon(Icons.repeat),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {
    print('_MyHomePageState.onDeliveryAcceptance');
  }

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {
    print('_MyHomePageState.onDeliveryNote');
  }

  @override
  onInvoice(Invoice invoice) {
    print('_MyHomePageState.onInvoice');
  }

  @override
  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance) {
    print('_MyHomePageState.onInvoiceAcceptance');
  }

  @override
  onInvoiceBid(InvoiceBid bid) {
    print('_MyHomePageState.onInvoiceBid');
  }

  @override
  onOffer(Offer offer) {
    print('_MyHomePageState.onOffer');
  }

  @override
  onPurchaseOrder(PurchaseOrder purchaseOrder) {
    print('_MyHomePageState.onPurchaseOrder');
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

  ExecutionUnit exec;
  List<ExecutionUnit> invalidUnits = List();
  HashMap<String, ExecutionUnit> map = HashMap<String, ExecutionUnit>();
  @override
  onInvalidTrade(ExecutionUnit exec) async {
    this.exec = exec;
    map['${exec.order.autoTradeOrderId}-${exec.offer.offerId}'] = exec;
    invalidUnits.clear();
    map.forEach((key, ex) {
      invalidUnits.add(ex);
    });

    try {
      List<ExecutionUnit> mUnits = await FileUtil.getExecutionUnits();
      if (mUnits == null) {
        mUnits = List();
      }
      invalidUnits.forEach((m) {
        mUnits.insert(0, m);
      });
      mUnits.sort((a, b) => b.date.compareTo(a.date));
      await FileUtil.saveExecutionUnits(ExecutionUnits(mUnits));
    } catch (e) {
      print('_MyHomePageState.onInvalidTrade  FILE PROBLEM $e');
    }

    summarize();
  }

  void _onSessionTapped() {
    if (bids.isEmpty && invalidUnits.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No session details available',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new JournalPage(
                bids: bids,
                units: invalidUnits,
              )),
    );
  }
}
