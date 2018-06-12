import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController animationController;
  Animation<double> animation;
  Supplier supplier;
  final Firestore _firestore = Firestore.instance;
  List<Invoice> invoices;
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<InvestorInvoiceSettlement> investorSettlements;
  List<GovtInvoiceSettlement> govtSettlements;
  List<CompanyInvoiceSettlement> companySettlements;

  @override
  initState() {
    super.initState();
    print('_DashboardState.initState .............. to get summary');
    _getSummaryData();
  }

  ///get  summaries from Firestore
  _getSummaryData() async {
    supplier = await SharedPrefs.getSupplier();
    if (supplier != null) {
      print(
          '_MainPageState._getSummaryData SUPPLIER - will get supplier suummaries ${supplier.toJson()}');
      //get invoices

    }
  }

  final invoiceStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 28.0,
      color: Colors.pink,
      fontFamily: 'Raleway');
  final poStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 28.0,
      color: Colors.black,
      fontFamily: 'Raleway');
  final delNoteStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 28.0,
      color: Colors.blue,
      fontFamily: 'Raleway');
  final paymentStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 28.0,
      color: Colors.teal,
      fontFamily: 'Raleway');

  double opacity = 1.0;
  String name;
  @override
  Widget build(BuildContext context) {
    supplier = widget.supplier;
    govtEntity = widget.govtEntity;
    if (supplier != null) {
      name = supplier.name;
    }
    if (govtEntity != null) {
      name = govtEntity.name;
    }
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
          title: Text('BFN - Dashboard'),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Row(
              children: <Widget>[
                Text(
                  name == null ? 'Organisation' : name,
                  style: TextStyle(color: Colors.white),
                )
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
              opacity: 0.4,
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
                        total: 46,
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
                        total: 33,
                        label: 'Invoices',
                        date: '30 December 2018',
                        lastLabel: 'Last:',
                        amount: 10300.95,
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: 14,
                        label: 'Purchase Orders',
                        date: '30 January 2018',
                        lastLabel: 'Last:',
                        amount: 6300.00,
                        totalStyle: poStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: 25,
                        label: 'Delivery Notes',
                        date: '30 January 2018',
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
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }
}

class SummaryCard extends StatelessWidget {
  final int total;
  final String label, date, lastLabel;
  final double amount;
  final TextStyle totalStyle;

  SummaryCard(
      {this.total,
      this.totalStyle,
      this.label,
      this.date,
      this.lastLabel,
      this.amount});
  final bigLabel = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 24.0,
      color: Colors.grey,
      fontFamily: 'Raleway');

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 120.0,
      child: new Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 4.0,
          child: Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      label,
                      style: bigLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 20.0),
                      child: Text(
                        '$total',
                        style: totalStyle,
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, bottom: 10.0, top: 0.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      lastLabel,
                      style: TextStyle(color: Colors.grey),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        date,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '$amount',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
