import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoice_list.dart';
import 'package:supplierv3/ui/purchase_order_list.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
  @override
  initState() {
    super.initState();
    print('_DashboardState.initState .............. to get summary');
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);
    _getSummaryData();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  ///get  summaries from Firestore
  _getSummaryData() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    supplier = await SharedPrefs.getSupplier();
    assert(supplier != null);
    name = supplier.name;
    setState(() {});
    print('_MainPageState._getSummaryData SUPPLIER -  ${supplier.toJson()}');
    //get invoices
    purchaseOrders = await ListAPI.getPurchaseOrders(
        supplier.documentReference, 'suppliers');
    setState(() {
      totalPOs = purchaseOrders.length;
    });
    deliveryNotes =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    setState(() {
      totalNotes = deliveryNotes.length;
    });
    invoices =
        await ListAPI.getInvoices(supplier.documentReference, 'suppliers');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
    });
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
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                      child: Text(
                        fullName == null ? 'user' : fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.only(top: 2.0),
                child: ListView(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: totalPayments == null ? 0 : totalPayments,
                        label: 'Payments',
                        date: '30 December 2018',
                        lastLabel: 'Last:',
                        amount: 450300.95,
                        totalStyle: paymentStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onInvoiceTapped,
                      child: SummaryCard(
                        total: totalInvoices == null ? 0 : totalInvoices,
                        label: 'Invoices',
                        date: lastInvoice == null ? '' : lastInvoice.date,
                        lastLabel: 'Last:',
                        amount: lastInvoice == null ? 0.0 : lastInvoice.amount,
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: totalPOs == null ? 0 : totalPOs,
                        label: 'Purchase Orders',
                        date: lastPO == null ? '' : lastPO.date,
                        lastLabel: 'Last:',
                        amount: lastPO == null ? 0.0 : lastPO.amount,
                        totalStyle: poStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: totalNotes == null ? 0 : totalNotes,
                        label: 'Delivery Notes',
                        date: lastNote == null ? '' : lastNote.date,
                        lastLabel: 'Last:',
                        amount: 0.00,
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

  void _toggleView() {
    print('_MainPageState._toggleView .... ');
    if (opacity == 0.0) {
      opacity = 1.0;
    } else {
      opacity = 0.0;
    }

    setState(() {});
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceListPage()),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new PurchaseOrderListPage()),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryNoteListPage()),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }
}
