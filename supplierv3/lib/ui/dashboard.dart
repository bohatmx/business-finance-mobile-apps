import 'dart:async';

import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
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
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/listeners/firestore_listener.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoice_list.dart';
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
        InvoiceBidListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
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
  _getSummaryData() async {
    prettyPrint(supplier.toJson(), 'Dashboard_getSummaryData: ');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading dashboard data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    await _getPurchaseOrders();
    await _getDelNotes();
    await _getInvoices();
    await _getSettlements();
    await _getOffers();

    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  Future _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    supplier = await SharedPrefs.getSupplier();
    assert(supplier != null);
    name = supplier.name;
    setState(() {});
    _getSummaryData();
    //
    listenForPurchaseOrder(supplier.documentReference, this);
    listenForDeliveryAcceptance(supplier.documentReference, this);
    listenForInvoiceAcceptance(supplier.documentReference, this);
  }

  _listenForBids() async {
    allOffers = await ListAPI.getOpenOffersBySupplier(supplier.participantId);
    allOffers.forEach((i) {
      listenForInvoiceBid(i.offerId, this);
    });
  }

  Future _getSettlements() async {
    investorSettlements =
        await FirestoreListAPI.getSupplierInvestorSettlements(supplier);
    govtSettlements =
        await FirestoreListAPI.getSupplierGovtSettlements(supplier);
    companySettlements =
        await FirestoreListAPI.getSupplierCompanySettlements(supplier);
    setState(() {
      totalPayments = investorSettlements.length +
          govtSettlements.length +
          companySettlements.length;
    });
  }

  Future _getInvoices() async {
    invoices =
        await ListAPI.getInvoices(supplier.documentReference, 'suppliers');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
    });
    _listenForBids();
  }

  Future _getDelNotes() async {
    deliveryNotes =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    setState(() {
      totalNotes = deliveryNotes.length;
    });
  }

  Future _getOffers() async {
    allOffers = await ListAPI.getOffersBySupplier(supplier.participantId);
    setState(() {});
    allOffers.forEach((offer) {
      if (offer.isOpen) {
        listenForInvoiceBid(offer.offerId, this);
      }
    });
  }

  Future _getPurchaseOrders() async {
    purchaseOrders = await ListAPI.getPurchaseOrders(
        supplier.documentReference, 'suppliers');
    setState(() {
      totalPOs = purchaseOrders.length;
    });
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

    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
          title: Text(
            'BFN',
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
              icon: Icon(Icons.library_books),
              onPressed: _goToContracts,
            ),
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
                padding: const EdgeInsets.only(top: 10.0),
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
                        label: 'Invoices',
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: totalPOs == null ? 0 : totalPOs,
                        label: 'Purchase Orders',
                        totalStyle: poStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: totalNotes == null ? 0 : totalNotes,
                        label: 'Delivery Notes',
                        totalStyle: delNoteStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onOffersTapped,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: OfferSummaryCard(allOffers),
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
        new MaterialPageRoute(
          builder: (context) => OfferList(),
        ));
  }

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new WalletPage(
              name: supplier.name,
              participantId: supplier.participantId,
              type: SupplierType)),
    );
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceList()),
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
      new MaterialPageRoute(builder: (context) => new DeliveryNoteList(null)),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  refresh() {
    print(
        '_DashboardState.refresh: ################## REFRESH called. getSummary ...');
    _getSummaryData();
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  action: $action');

    switch (action) {
      case PurchaseOrderConstant:
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new PurchaseOrderListPage(purchaseOrders)),
        );
        break;
      case DeliveryAcceptanceConstant:
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new DeliveryAcceptanceList()),
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
      new MaterialPageRoute(builder: (context) => new MakeOfferPage(inv)),
    );
  }

  void _goToContracts() {
    print('_DashboardState._goToContracts .......');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ContractList()),
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
  @override
  onPurchaseOrder(PurchaseOrder po) {
    prettyPrint(po.toJson(), '_DashboardState.onPurchaseOrder');
    purchaseOrder = po;
    var now = DateTime.now();
    var date = DateTime.parse(po.date);
    var difference = now.difference(date);
    if (difference.inHours > 1) {
      print(
          'onPurchaseOrder -  IGNORED: older than 1 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: PurchaseOrderConstant);

    _getPurchaseOrders();
  }

  DeliveryAcceptance deliveryAcceptance;
  @override
  onDeliveryAcceptance(DeliveryAcceptance da) {
    prettyPrint(da.toJson(), '_DashboardState.onDeliveryAcceptance');
    deliveryAcceptance = da;
    var now = DateTime.now();
    var date = DateTime.parse(da.date);
    var difference = now.difference(date);
    if (difference.inSeconds > 30) {
      print(
          'onDeliveryAcceptance-  IGNORED: older than 1 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note Accepted',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: DeliveryAcceptanceConstant);
  }

  InvoiceAcceptance invoiceAcceptance;
  @override
  onInvoiceAcceptance(InvoiceAcceptance ia) {
    prettyPrint(ia.toJson(), '_DashboardState.onInvoiceAcceptance');
    invoiceAcceptance = ia;
    var now = DateTime.now();
    var date = DateTime.parse(ia.date);
    var difference = now.difference(date);
    if (difference.inSeconds > 30) {
      print(
          '_InvoiceListState.onInvoiceBid -  IGNORED: older than 1 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Accepted',
        textColor: Colors.lightGreen,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: InvoiceAcceptedConstant);
  }

  InvoiceBid invoiceBid;
  @override
  onInvoiceBid(InvoiceBid bid) {
    prettyPrint(bid.toJson(), '_DashboardState.onInvoiceAcceptance');
    var now = DateTime.now();
    var date = DateTime.parse(bid.date);
    var difference = now.difference(date);
    if (difference.inHours > 1) {
      print(
          '.onInvoiceBid -  IGNORED: older than 1 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    invoiceBid = bid;
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'A bid has been made',
        textColor: Colors.green,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: InvoiceBidConstant);
  }
}

class OfferSummaryCard extends StatelessWidget {
  final List<Offer> offers;

  OfferSummaryCard(this.offers);

  @override
  Widget build(BuildContext context) {
    var open = 0;
    var closed = 0;
    var cancelled = 0;
    offers.forEach((m) {
      if (m.isOpen) {
        open++;
      }
      if (!m.isOpen) {
        closed++;
      }
      if (m.isCancelled) {
        cancelled++;
      }
    });
    return Card(
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Open Offers',
                  style: Styles.greyLabelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '$open',
                    style: Styles.tealBoldLarge,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Closed Offers',
                  style: Styles.greyLabelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '$closed',
                    style: Styles.pinkBoldLarge,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Cancelled Offers',
                  style: Styles.greyLabelSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '$cancelled',
                    style: Styles.blackBoldLarge,
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
