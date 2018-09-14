import 'dart:async';

import 'package:businesslibrary/api/auto_trade.dart';
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
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:monitor/local_util.dart';
import 'package:monitor/ui/theme_util.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
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
  int _index = 0;

  @override
  void initState() {
    super.initState();
//    BlockchainUtil.listenForBlockchainEvents(this);
    _getLists();
  }

  int minutes = 10;
  _getMinutes() async {
    minutes = await SharedPrefs.getMinutes();
    controller.text = '$minutes';
    setState(() {});
  }

  _getLists() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Refreshing lists ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    _orders = await ListAPI.getAutoTradeOrders();
    _profiles = await ListAPI.getInvestorProfiles();
    _offers = await ListAPI.getOpenOffers();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _getMinutes();
    _index = 0;
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

  _start() async {
    print(
        '_MyHomePageState._start ..... Timer.periodic(Duration((minutes: $minutes) time: ${DateTime.now().toIso8601String()}');
    Timer.periodic(Duration(minutes: minutes), (count) async {
      print(
          '_MyHomePageState._start:\n\n\n TIMER tripping - starting AUTO TRADE cycle .......time: ${DateTime.now().toIso8601String()}....\n\n');
      _index = 0;
      _orders = await ListAPI.getAutoTradeOrders();
      _profiles = await ListAPI.getInvestorProfiles();
      _offers = await ListAPI.getOpenOffers();
      _orders.shuffle();

      if (_offers.isEmpty) {
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'No open offers available',
            textColor: Styles.white,
            backgroundColor: Styles.black);
        return;
      }
      _offers.sort((a, b) => b.offerAmount.compareTo(a.offerAmount));
      if (_orders.isNotEmpty && _profiles.isNotEmpty && _offers.isNotEmpty) {
        var z = AutoTradeExecutionBuilder();
        z.executeAutoTrades(_orders, _profiles, _offers, this);
      }
    });
  }

  @override
  onComplete(int count) {
    print('_MyHomePageState.onComplete ......... proocessed; $count');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Auto Trades completed. Processed $count',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }

  @override
  onError(int count) {
    print('_MyHomePageState.onError ....ERROR ERROOR..... proocessed; $count');
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Auto Trades ERROR. Processed $count',
        listener: this,
        actionLabel: 'close');
  }

  void _restart() async {
    await _getLists();
    setState(() {});
    if (_orders.isNotEmpty && _profiles.isNotEmpty && _offers.isNotEmpty) {
      var z = AutoTradeExecutionBuilder();
      z.executeAutoTrades(_orders, _profiles, _offers, this);
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'OneConnect BFN',
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
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Business Finance Network'),
        bottom: _getBottom(),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Automatic Trade every',
                            style: Styles.greyLabelLarge,
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
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Auto Trade Orders',
                            style: Styles.greyLabelLarge,
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
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Open Invoice Offers',
                            style: Styles.greyLabelLarge,
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
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _restart,
        tooltip: 'Restart',
        child: new Icon(Icons.repeat),
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
    SharedPrefs.saveMinutes(minutes);
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Reset timer to $minutes minutes',
        textColor: Styles.white,
        backgroundColor: Styles.purple);
    _start();
  }
}
