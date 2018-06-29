import 'dart:async';

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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
  static _DashboardState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_DashboardState>());
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements SnackBarListener, FCMListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');

  AnimationController animationController;
  Animation<double> animation;
  Investor investor;
  List<Invoice> invoices;
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<InvestorInvoiceSettlement> investorSettlements;
  List<GovtInvoiceSettlement> govtSettlements;
  List<CompanyInvoiceSettlement> companySettlements;
  User user;
  String fullName;
  DeliveryAcceptance acceptance;

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
  }

  void _configMessaging() async {
    investor = await SharedPrefs.getInvestor();
    configureMessaging(this);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///get  summaries from Firestore
  _getSummaryData() async {
    prettyPrint(investor.toJson(), 'Dashboard_getSummaryData: ');

    await _getInvoices();
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

  Future _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh invoices data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    invoices =
        await ListAPI.getInvoices(investor.documentReference, 'suppliers');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  Invoice lastInvoice;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  int totalInvoices, totalPOs, totalNotes, totalPayments;
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
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
          ),
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
                padding: const EdgeInsets.only(top: 20.0),
                child: ListView(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: totalPayments == null ? 0 : totalPayments,
                        label: 'Payments',
                        totalStyle: paymentStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onInvoiceTapped,
                      child: SummaryCard(
                        total: totalInvoices == null ? 0 : totalInvoices,
                        label: 'Invoice Offers',
                        totalStyle: invoiceStyle,
                      ),
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
//    Navigator.push(
//      context,
//      new MaterialPageRoute(builder: (context) => new DeliveryAcceptanceList()),
//    );
  }

  void _onPaymentsTapped() {}

  void _onInvoiceTapped() {}

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {
    // TODO: implement onCompanySettlement
  }

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note accepted',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'INVOICE',
        listener: this,
        icon: Icons.done);
  }

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {
    // TODO: implement onDeliveryNote
  }

  @override
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement) {
    // TODO: implement onGovtInvoiceSettlement
  }

  @override
  onInvestorSettlement(InvestorInvoiceSettlement settlement) {
    // TODO: implement onInvestorSettlement
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    // TODO: implement onInvoiceBidMessage
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    // TODO: implement onInvoiceMessage
  }

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
    prettyPrint(wallet.toJson(), 'Dashboard.onWalletMessage: wallet:');
    var dec = await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
    print('_DashboardState.onWalletMessage dec: $dec');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Wallet Created',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'INVOICE',
        listener: this,
        icon: Icons.done);
  }
}
