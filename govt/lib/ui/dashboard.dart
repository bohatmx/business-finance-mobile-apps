import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/purchase_order_list.dart';
import 'package:govt/ui/summary_card.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController animationController;
  Animation<double> animation;
  GovtEntity govtEntity;
  List<Invoice> invoices;
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<GovtInvoiceSettlement> govtSettlements;
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
    print('_DashboardState._getSummaryData ..................................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    govtEntity = await SharedPrefs.getGovEntity();
    assert(govtEntity != null);
    name = govtEntity.name;
    print(
        '_DashboardState._getSummaryData govt doc id: ${govtEntity.documentReference}');
    setState(() {});
    print(
        '_MainPageState._getSummaryData GOVT_ENTITY -  ${govtEntity.toJson()}');
    //get invoices
    purchaseOrders = await ListAPI.getPurchaseOrders(
        govtEntity.documentReference, 'govtEntities');
    print(
        '_DashboardState._getSummaryData @@@ purchaseOrders: ${purchaseOrders.length}');
    setState(() {
      totalPOs = purchaseOrders.length;
    });
    deliveryNotes = await ListAPI.getDeliveryNotes(
        govtEntity.documentReference, 'govtEntities');
    setState(() {
      totalNotes = deliveryNotes.length;
    });
    invoices =
        await ListAPI.getInvoices(govtEntity.documentReference, 'govtEntities');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
    });

    govtSettlements = await FirestoreListAPI.getGovtSettlements(govtEntity);

    setState(() {
      totalPayments = govtSettlements.length;
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
                padding: const EdgeInsets.only(top: 2.0),
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
//    Navigator.push(
//      context,
//      new MaterialPageRoute(builder: (context) => new InvoiceListPage()),
//    );
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
//    Navigator.push(
//      context,
//      new MaterialPageRoute(builder: (context) => new DeliveryNoteListPage()),
//    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }
}
