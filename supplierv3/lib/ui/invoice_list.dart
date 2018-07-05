import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/invoice_page.dart';
import 'package:supplierv3/ui/make_offer.dart';

class InvoiceList extends StatefulWidget {
  final List<Invoice> invoices;

  InvoiceList(this.invoices);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static const MakeOffer = '1', CancelOffer = '2', EditInvoice = '3';
  List<Invoice> invoices;
  Invoice invoice;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isInvoice;
  List<DropdownMenuItem<String>> items = List();

  @override
  void initState() {
    super.initState();

    _getCached();
    if (widget.invoices == null) {
      _getInvoices();
    }
  }

  _showMenuDialog(Invoice invoice) {
    this.invoice = invoice;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Actions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 240.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Invoice Number: ${invoice.invoiceNumber}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildItems(),
                  ],
                ),
              ),
            ));
  }

  _onInvoiceDetails() {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceDetailsPage(invoice)),
    );
  }

  Widget _buildItems() {
    var item1 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.attach_money,
                color: Colors.green.shade800,
              ),
            ),
            Text('Make Invoice Offer'),
          ],
        ),
      ),
    );
    var item2 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _cancelOffer,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.cancel,
                color: Colors.red.shade800,
              ),
            ),
            Text('Cancel Invoice Offer'),
          ],
        ),
      ),
    );
    var item3 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onInvoiceDetails,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.description,
                color: Colors.blue.shade800,
              ),
            ),
            Text('View Invoice Details'),
          ],
        ),
      ),
    );

    return Column(
      children: <Widget>[
        item1,
        item2,
        item3,
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          ),
        ),
      ],
    );
  }

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    setState(() {});
  }

  _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoices ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    invoices =
        await ListAPI.getInvoices(invoice.supplierDocumentRef, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _calculateTotal();
  }

  void _calculateTotal() {
    if (invoices.isNotEmpty) {
      double total = 0.00;
      invoices.forEach((inv) {
        double amt = inv.amount;
        total += amt;
      });

      totalAmount = getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  String totalAmount;
  @override
  Widget build(BuildContext context) {
    invoices = widget.invoices;
    if (invoices == null) {
      _getInvoices();
    } else {
      _calculateTotal();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
        elevation: 8.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onInvoiceAdd,
          ),
        ],
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    supplier == null ? 'Blank Supplier?' : supplier.name,
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 20.0, top: 10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          totalAmount == null ? '0.00' : totalAmount,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(110.0)),
      ),
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: invoices == null ? 0 : invoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        _showMenuDialog(invoices.elementAt(index));
                      },
                      child: InvoiceCard(
                        invoice: invoices.elementAt(index),
                        context: context,
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  onActionPressed(int action) {
    print('_InvoiceListState.onActionPressed');
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';
  void _onOffer() {
    print('_InvoiceListState._onOffer');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
    );
  }

  void _cancelOffer() {
    print('_InvoiceListState._cancelOffer ..........');
  }

  void _onInvoiceAdd() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryAcceptanceList()),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  InvoiceCard({this.invoice, this.context});

  @override
  Widget build(BuildContext context) {
    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 2.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.description,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  getFormattedLongestDate(invoice.date),
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      invoice.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 10.0, top: 10.0),
              child: Row(
                children: <Widget>[
                  Text('Amount'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      amount == null ? '0.00' : amount,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String amount;
  String _getFormattedAmt() {
    amount = '${invoice.amount}';
    print('InvoiceCard._getFormattedAmt $amount');
    return amount;
  }
}
