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
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/fcm_handler.dart';
import 'package:supplierv3/ui/invoice_bids.dart';
import 'package:supplierv3/ui/invoice_list.dart';
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
    implements SnackBarListener, FCMessageListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
  String message;
  AnimationController animationController;
  Animation<double> animation;
  Supplier supplier;
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

    configureAppMessaging(this);
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
    await getPurchaseOrders();
    await getDelNotes();
    await _getInvoices();
    await _getSettlements();

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
  }

  Future getDelNotes() async {
    deliveryNotes =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    setState(() {
      totalNotes = deliveryNotes.length;
    });
  }

  Future getPurchaseOrders() async {
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
    if (message != null) {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: message,
          textColor: Colors.white,
          icon: Icons.done_all,
          listener: this,
          actionLabel: 'OK',
          action: 0,
          backgroundColor: Colors.black);
      message = null;
    }
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
              name: supplier.name,
              participantId: supplier.participantId,
              type: SupplierType)),
    );
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
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
      WalletConstant = 7;

  @override
  onCompanySettlement(CompanyInvoiceSettlement settlement) {
    // TODO: implement onCompanySettlement
  }

  @override
  onDeliveryAcceptance(DeliveryAcceptance deliveryAcceptance) {
    // TODO: implement onDeliveryAcceptance
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
  onInvoiceAcceptance(InvoiceAcceptance invoiceAcceptance) {
    // TODO: implement onInvoiceAcceptance
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) async {
    print('_DashboardState.onInvoiceBidMessage ########### should happen????');

    String id = invoiceBid.offer.split("#").elementAt(1);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading bids',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black);
    var bag = await ListAPI.getOfferById(id);

    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceBids(bag)),
    );
  }

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: 'OK',
        listener: this,
        icon: Icons.message,
        action: PurchaseOrderConstant);
    purchaseOrders.insert(0, purchaseOrder);
    setState(() {
      totalPOs = purchaseOrders.length;
    });
  }
}
