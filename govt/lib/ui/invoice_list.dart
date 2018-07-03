import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/invoice_settlement.dart';

class InvoiceList extends StatefulWidget {
  final List<Invoice> invoices;

  InvoiceList(this.invoices);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GovtEntity entity;
  List<Invoice> invoices;
  Invoice invoice;
  @override
  initState() {
    super.initState();
    _getCached();
  }

  _getInvoices() async {
    print('_InvoiceListState._getInvoices ..........');
    invoices =
        await ListAPI.getInvoices(entity.documentReference, 'govtEntities');
    print('_InvoiceListState._getInvoices, found: ${invoices.length} ');
    setState(() {});
  }

  _getCached() async {
    entity = await SharedPrefs.getGovEntity();
    setState(() {});
  }

  void _settleInvoice() {
    prettyPrint(invoice.toJson(),
        '_InvoiceListState._settleInvoice  go to InvoiceSettlementPage');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceSettlementPage(invoice)),
    );
  }

  @override
  Widget build(BuildContext context) {
    invoices = widget.invoices;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getInvoices,
          )
        ],
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        entity == null ? '' : entity.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          invoices == null ? '0' : '${invoices.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(60.0)),
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
                        _showSettleDialog(invoices.elementAt(index));
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

  void _showSettleDialog(Invoice invoice) {
    prettyPrint(invoice.toJson(), '_showMenuDialog: invoice:');

    this.invoice = invoice;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Settlement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to settle this Invoice?\n\ "),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Invoice Number:',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${invoice.invoiceNumber}',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'NO',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 16.0, bottom: 10.0),
                  child: RaisedButton(
                    elevation: 4.0,
                    onPressed: _settleInvoice,
                    color: Colors.teal,
                    child: Text(
                      'YES',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ));
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
        color: Colors.amber.shade50,
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
                      invoice.supplierName,
                      style: TextStyle(
                          color: Colors.indigo.shade300,
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
    return amount;
  }
}
