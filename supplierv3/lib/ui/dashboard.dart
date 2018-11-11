import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/main.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoices.dart';
import 'package:supplierv3/ui/make_offer.dart';
import 'package:supplierv3/ui/offer_list.dart';
import 'package:supplierv3/ui/purchase_order_list.dart';
import 'package:supplierv3/ui/summary_card.dart';

class Dashboard extends StatefulWidget {
  final String message;

  Dashboard(this.message);

  @override
  _DashboardState createState() => _DashboardState();
//  static _DashboardState of(BuildContext context) =>
//      context.ancestorStateOfType(const TypeMatcher<_DashboardState>());
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements
        SnackBarListener,
        PurchaseOrderListener,
        DeliveryAcceptanceListener,
        InvoiceAcceptanceListener,
        InvoiceBidListener,
        GeneralMessageListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
  FirebaseMessaging _fcm = FirebaseMessaging();
  String message;
  AnimationController animationController;
  Animation<double> animation;
  Supplier supplier;
  List<Invoice> invoices;
  List<Offer> allOffers = List();
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<InvestorInvoiceSettlement> investorSettlements;
  List<GovtInvoiceSettlement> govtSettlements;
  List<CompanyInvoiceSettlement> companySettlements;
  User user;
  String fullName;
  DeliveryAcceptance acceptance;
  DashboardData dashboardData;
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
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///get  summaries from Firestore
  _getSummaryData(bool showSnack) async {
    prettyPrint(supplier.toJson(), 'Dashboard_getSummaryData: ');
    if (showSnack) {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Loading dashboard data',
          textColor: Colors.white,
          backgroundColor: Colors.black);
    }
    try {
      dashboardData = await ListAPI.getSupplierDashboardData(
          supplier.participantId, supplier.documentReference);
      await SharedPrefs.saveDashboardData(dashboardData);
      prettyPrint(
          dashboardData.toJson(), '\n\n@@@@@@@@@@@ RETURNED dash data:');
      setState(() {});
      _getDetailData();
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: '$e',
          listener: this,
          actionLabel: 'close');
      return;
    }

    try {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    } catch (e) {}
    //
  }

  void _getDetailData() async {
    print('\n\n_DashboardState._getDetailData ############ get Supplier data');
    var m = await ListAPI.getSupplierPurchaseOrders(supplier.documentReference);
    await Database.savePurchaseOrders(PurchaseOrders(m));
    var n =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    await Database.saveDeliveryNotes(DeliveryNotes(n));
    var p = await ListAPI.getInvoices(supplier.documentReference, 'suppliers');
    await Database.saveInvoices(Invoices(p));
    var o = await ListAPI.getOffersBySupplier(supplier.participantId);
    await Database.saveOffers(Offers(o));
    print(
        '\n\n_DashboardState._getDetailData ######### done getting supplier data');
  }

  Future _getCachedPrefs() async {
    supplier = await SharedPrefs.getSupplier();
    if (supplier == null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new StartPage()),
      );
      return;
    }
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;

    dashboardData = await SharedPrefs.getDashboardData();
    assert(supplier != null);
    name = supplier.name;
    setState(() {});
    _getSummaryData(false);
    //
    FCM.configureFCM(
      purchaseOrderListener: this,
      deliveryAcceptanceListener: this,
      invoiceAcceptanceListener: this,
      invoiceBidListener: this,
      generalMessageListener: this,
    );
    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);

    print(
        '\n\n_DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - POs, Delivery acceptance, Invoice acceptance');

    allOffers = await ListAPI.getOpenOffersBySupplier(supplier.participantId);
    allOffers.forEach((i) {
      _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + i.offerId);
    });
    print(
        '_DashboardState._listenForBids -n subscribed to invoice bid topics: ${allOffers.length}');
  }

  Invoice lastInvoice;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  double opacity = 1.0;
  String name;
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
                  name == null ? 'Organisation' : name,
                  style: Styles.whiteBoldMedium,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onRefreshPressed() {
    _getSummaryData(true);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
          title: Text(
            'BFN',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          leading: Icon(
            Icons.apps,
            color: Colors.white,
          ),
          bottom: _getBottom(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.library_books),
              onPressed: _goToContracts,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _onRefreshPressed,
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
            ),
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: Stack(
          children: <Widget>[
            Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _onInvoiceTapped,
                      child: dashboardData == null
                          ? Container()
                          : SummaryCard(
                              totalCount: dashboardData.invoices,
                              totalCountLabel: 'Invoices',
                              totalCountStyle: Styles.pinkBoldLarge,
                              totalValue: dashboardData == null
                                  ? 0.0
                                  : dashboardData.totalInvoiceAmount,
                              elevation: 2.0,
                            ),
                    ),
                    GestureDetector(
                      onTap: _onOffersTapped,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: dashboardData == null
                            ? Container()
                            : OfferSummaryCard(
                                data: dashboardData,
                                elevation: 16.0,
                              ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onPurchaseOrdersTapped,
                      child: dashboardData == null
                          ? Container()
                          : SummaryCard(
                              totalCount: dashboardData.purchaseOrders,
                              totalCountLabel: 'Purchase Orders',
                              totalCountStyle: Styles.blueBoldLarge,
                              totalValue: dashboardData == null
                                  ? 0.0
                                  : dashboardData.totalPurchaseOrderAmount,
                            ),
                    ),
                    GestureDetector(
                      onTap: _onDeliveryNotesTapped,
                      child: dashboardData == null
                          ? Container()
                          : SummaryCard(
                              totalCount: dashboardData.deliveryNotes,
                              totalCountLabel: 'Delivery Notes',
                              totalCountStyle: Styles.blackBoldLarge,
                              totalValue: dashboardData == null
                                  ? 0.0
                                  : dashboardData.totalDeliveryNoteAmount,
                            ),
                    ),
                    GestureDetector(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        totalCount: dashboardData == null ? 0 : 0,
                        totalCountLabel: 'Payments',
                        totalCountStyle: Styles.greyLabelMedium,
                        totalValue: 0.0,
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

  _onOffersTapped() {
    print('_DashboardState._onOffersTapped ...............');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfferList(),
        ));
  }

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WalletPage(
              name: supplier.name,
              participantId: supplier.participantId,
              type: SupplierType)),
    );
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InvoicesOnOffer()),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PurchaseOrderListPage()),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeliveryNoteList()),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  refresh() {
    print(
        '_DashboardState.refresh: ################## REFRESH called. getSummary ...');
    _getSummaryData(false);
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  action: $action');

    switch (action) {
      case PurchaseOrderConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PurchaseOrderListPage()),
        );
        break;
      case DeliveryAcceptanceConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeliveryAcceptanceList()),
        );
        break;
      case InvoiceAcceptedConstant:
        _startOffer();
        break;
      case CompanySettlementConstant:
        break;
      case InvestorSettlement:
        break;
      case InvoiceBidConstant:
        break;
      case WalletConstant:
        break;
      case GovtSettlement:
        break;
    }
  }

  void _startOffer() async {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoice ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var inv = await ListAPI.getSupplierInvoiceByNumber(
        invoiceAcceptance.invoiceNumber, supplier.documentReference);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MakeOfferPage(inv)),
    );
  }

  void _goToContracts() {
    print('_DashboardState._goToContracts .......');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContractList()),
    );
  }

  static const CompanySettlementConstant = 1,
      DeliveryAcceptanceConstant = 2,
      GovtSettlement = 3,
      PurchaseOrderConstant = 4,
      InvoiceBidConstant = 5,
      InvestorSettlement = 6,
      WalletConstant = 7,
      InvoiceAcceptedConstant = 8;

  PurchaseOrder purchaseOrder;

  DeliveryAcceptance deliveryAcceptance;

  InvoiceAcceptance invoiceAcceptance;

  InvoiceBid invoiceBid;

  @override
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) {
    _showSnack('Delivery Acceptance arrived', Colors.green);
  }

  @override
  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance) {
    _showSnack('Invoice Acceptance arrived', Colors.yellow);
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    _showSnack('Invoice Bid  arrived', Colors.lightBlue);
    _getSummaryData(true);
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    _showSnack('Purchase Order arrived', Colors.lime);
    _getSummaryData(true);
  }

  @override
  onGeneralMessage(Map map) {
    _showSnack(map['message'], Colors.white);
  }

  void _showSnack(String message, Color color) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: color,
        backgroundColor: Colors.black);
  }
}

class OfferSummaryCard extends StatelessWidget {
  final DashboardData data;
  final double elevation;
  OfferSummaryCard({this.data, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 16.0 : elevation,
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Invoice Offers',
                    style: Styles.blackBoldMedium,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Open Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${data.totalOpenOffers}',
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 120.0,
                    child: Text(
                      'Open Offer Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${data.totalOpenOfferAmount}', context)}',
                      style: Styles.tealBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Closed Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${data.closedOffers}',
                    style: Styles.greyLabelMedium,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Cancelled Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${data.cancelledOffers}',
                    style: Styles.greyLabelMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
