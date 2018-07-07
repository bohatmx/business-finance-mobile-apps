import 'dart:async';

import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/delivery_note_list.dart';
import 'package:govt/ui/invoice_list.dart';
import 'package:govt/ui/purchase_order_list.dart';
import 'package:govt/ui/summary_card.dart';

class Dashboard extends StatefulWidget {
  final String message;

  Dashboard(this.message);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements SnackBarListener, FCMListener {
  static const Payments = 1,
      Invoices = 2,
      PurchaseOrders = 3,
      DeliveryNotes = 4,
      DeliveryAcceptances = 5;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  AnimationController animationController;
  Animation<double> animation;
  GovtEntity govtEntity;
  List<Invoice> invoices;
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<GovtInvoiceSettlement> govtSettlements;
  User user;
  String fullName;
  int messageReceived;
  String message;
  @override
  initState() {
    super.initState();
    print('_DashboardState.initState .............. to get summary');
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);

    _messaging();
    _getCache();
  }

  _getCache() async {
    govtEntity = await SharedPrefs.getGovEntity();
  }

  void _messaging() async {
    await _getCachedPrefs();
    await configureMessaging(this);
    _subscribeToFCM();
  }

  Future _subscribeToFCM() async {
    govtEntity = await SharedPrefs.getGovEntity();
    var topic = 'invoices' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic);
    var topic2 = 'general';
    _firebaseMessaging.subscribeToTopic(topic2);
    var topic3 = 'settlements' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic3);
    var topic4 = 'deliveryNotes' + govtEntity.documentReference;
    _firebaseMessaging.subscribeToTopic(topic4);

    print(
        '_StartPageState._configMessaging ... ############# subscribed to FCM topics '
        '\n $topic \n $topic2 \n $topic3 \n $topic4');
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    govtEntity = await SharedPrefs.getGovEntity();
    assert(govtEntity != null);
    name = govtEntity.name;
    print(
        '_DashboardState._getSummaryData ....... govt documentId: ${govtEntity.documentReference}');
    setState(() {});
    print(
        '_MainPageState._getSummaryData ......... GOVT_ENTITY -  ${govtEntity.toJson()}');
    _getSummaryData();
  }

  ///get  summaries from Firestore
  _getPOData() async {
    print('_DashboardState._getPOData ................');

    purchaseOrders = await ListAPI.getPurchaseOrders(
        govtEntity.documentReference, 'govtEntities');
    print(
        '_DashboardState._getSummaryData @@@@@@@@@@@@ purchaseOrders: ${purchaseOrders.length}');
    setState(() {
      totalPOs = purchaseOrders.length;
    });
  }

  _getInvoices() async {
    print('_DashboardState._getInvoices ................');
    invoices =
        await ListAPI.getInvoices(govtEntity.documentReference, 'govtEntities');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
      print(
          '_DashboardState._getSummaryData ++++++++++++  invoices: ${invoices.length}');
    });
  }

  _getNotes() async {
    print('_DashboardState._getNotes ......................');
    deliveryNotes = await ListAPI.getDeliveryNotes(
        govtEntity.documentReference, 'govtEntities');
    setState(() {
      totalNotes = deliveryNotes.length;
      print(
          '_DashboardState._getSummaryData ========== deliveryNotes:  ${deliveryNotes.length}');
    });
  }

  _getSettlements() async {
    govtSettlements = await FirestoreListAPI.getGovtSettlements(govtEntity);
    setState(() {
      totalPayments = govtSettlements.length;
      print(
          '_DashboardState._getSummaryData ------------  payments: $totalPayments');
    });
  }

  _getSummaryData() async {
    print('_DashboardState._getSummaryData ..................................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    await _getPOData();
    await _getInvoices();
    await _getNotes();
    await _getSettlements();

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
          elevation: 16.0,
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
                      child: Text(name == null ? 'Organisation' : name,
                          style: Theme.of(context).primaryTextTheme.title
//                          color: Colors.white,
//                          fontSize: 20.0,
//                          fontWeight: FontWeight.w900,
//                        ),
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
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
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
                    new InkWell(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: totalPayments == null ? 0 : totalPayments,
                        label: 'Payments',
                        totalStyle: paymentStyle,
                      ),
                    ),
                    new InkWell(
                      onTap: _onInvoicesTapped,
                      child: SummaryCard(
                        total: totalInvoices == null ? 0 : totalInvoices,
                        label: 'Invoices',
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new InkWell(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: totalPOs == null ? 0 : totalPOs,
                        label: 'Purchase Orders',
                        totalStyle: poStyle,
                      ),
                    ),
                    new InkWell(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: totalNotes == null ? 0 : totalNotes,
                        label: 'Delivery Notes',
                        totalStyle: delNoteStyle,
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

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new WalletPage(
              name: govtEntity.name,
              participantId: govtEntity.participantId,
              type: GovtEntityType)),
    );
  }

  void _onInvoicesTapped() {
    print('_MainPageState._onInvoicesTapped ... go  to list of invoices');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceList(invoices)),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderListPage(purchaseOrders)),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new DeliveryNoteList(deliveryNotes)),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  @override
  onActionPressed(int action) {
    if (messageReceived == null) {
      print('_DashboardState.onActionPressed ERROR ERROR ');
      return;
    }
    print('_DashboardState.onActionPressed $messageReceived');
    switch (messageReceived) {
      case DeliveryNotes:
        _onDeliveryNotesTapped();
        break;
      case Invoices:
        _onInvoicesTapped();
        break;
    }
  }

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {}

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {}

  @override
  onDeliveryNote(DeliveryNote deliveryNote) {
    setState(() {
      deliveryNotes.insert(0, deliveryNote);
    });
    prettyPrint(deliveryNote.toJson(), 'FCM message received DeliveryNote: ');
    messageReceived = DeliveryNotes;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note arrived',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'Notes',
        listener: this,
        icon: Icons.email);
  }

  @override
  onGovtInvoiceSettlement(GovtInvoiceSettlement settlement) {}

  @override
  onInvestorSettlement(InvestorInvoiceSettlement settlement) {}

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {}

  @override
  onInvoiceMessage(Invoice invoice) {
    prettyPrint(
        invoice.toJson(), 'Dashbboard: ------ FCM message received Invoice: ');
    setState(() {
      invoices.insert(0, invoice);
      totalInvoices = invoices.length;
    });
    messageReceived = Invoices;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice arrived',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'Invoices',
        listener: this,
        icon: Icons.email);
  }

  @override
  onOfferMessage(Offer offer) {}

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {}

  @override
  onWalletError() {
    print('_DashboardState.onWalletError WALLET ERROR ');
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Wallet creation failed',
        listener: this,
        actionLabel: 'Close');
  }

  @override
  onWalletMessage(Wallet wallet) async {
    prettyPrint(wallet.toJson(),
        'onWalletMessage ... ############### arrived via fcm: ');

    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Wallet created',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.email);
  }
}
