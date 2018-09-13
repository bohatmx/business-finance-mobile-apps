import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
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
import 'package:businesslibrary/util/util.dart';
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
    implements BlockchainListener, SnackBarListener {
  static const NUMBER_OF_BIDS_TO_MAKE = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<AutoTradeOrder> _orders;
  List<InvestorProfile> _profiles;
  List<Offer> _offers;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    BlockchainUtil.listenForBlockchainEvents(this);
    _getLists();
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
    print('_MyHomePageState._start ..... Timer.periodic(Duration(seconds: 60)');
    Timer.periodic(Duration(seconds: 60), (count) async {
      _index = 0;
      _offers = await ListAPI.getOpenOffers();
      _doTradesForAll();
    });
  }

  int offerIndex = 0;

  _doTradesForAll() async {
    print(
        '_MyHomePageState._doTradesForAll ############## ..... index: $_index ############');
    if (_index < _orders.length) {
      if (_offers.isEmpty) {
        _offers = await ListAPI.getOpenOffers();
        _index = 0;
        if (_offers.isEmpty) {
          AppSnackbar.showSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'No Open Offers found',
              textColor: Styles.yellow,
              backgroundColor: Styles.black);
          print(
              '_MyHomePageState._doTradesForAll - no open offers found. will try in 60 seconds: ${DateTime.now().toIso8601String()}');
        } else {
          _doTradesForAll();
          return;
        }
      }
      var profileId =
          _orders.elementAt(_index).investorProfile.split('#').elementAt(1);
      InvestorProfile profile;
      _profiles.forEach((p) {
        if (profileId == p.profileId) {
          profile = p;
        }
      });

      if (profile != null) {
        await _executeTrade(
            _orders.elementAt(_index), profile, _offers.elementAt(0));
        _index++;
        _doTradesForAll();
      }
    } else {
      if (_offers.isNotEmpty) {
        _index = 0;
        _doTradesForAll();
      }
    }
  }

  static const Namespace = 'resource:com.oneconnect.biz.';
  _executeTrade(
      AutoTradeOrder order, InvestorProfile profile, Offer offer) async {
    var now = DateTime.now();
    print(
        '_MyHomePageState._executeTrade ................. : ${DateTime.now().toIso8601String()}');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Trading: ${profile.name}',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    var api = DataAPI(getURL());

    var bid = InvoiceBid(
      offer: Namespace + 'Offer#${offer.offerId}',
      investor: profile.investor,
      autoTradeOrder: Namespace + 'AutoTradeOrder#${order.autoTradeOrderId}',
      amount: offer.offerAmount,
      discountPercent: 100.0,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      isSettled: false,
      reservePercent: 100.0,
      investorName: profile.name,
      wallet: order.wallet,
    );
    var res = await api.makeInvoiceAutoBid(
      bid: bid,
      offer: offer,
      order: order,
    );
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (res == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Failed to start AUTO TRADE',
          listener: this,
          actionLabel: 'close');
    } else {
      _offers.remove(offer);
      print(
          '_MyHomePageState._executeTrade - _offers.removed _offers: ${_offers.length}');
    }

    var done = DateTime.now();
    var diff = done.difference(now).inSeconds;
    print(
        '_MyHomePageState._executeTrade \n\n\n++++++++++++++  AUTO TRADE executed - elapsed: $diff seconds for trade\n\n\n');
  }

  void _restart() async {
    await _getLists();
    setState(() {});
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
}
