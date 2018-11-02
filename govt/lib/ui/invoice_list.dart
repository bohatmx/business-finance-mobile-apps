import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/invoice_settlement.dart';

class InvoiceList extends StatefulWidget {
  final List<Invoice> invoices;

  InvoiceList(this.invoices);

  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList>
    implements SnackBarListener, InvoiceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  GovtEntity entity;
  List<Invoice> invoices;
  Invoice invoice;
  User user;

  @override
  initState() {
    super.initState();
    _getCached();
  }

  _getInvoices() async {
    print('_InvoiceListState._getInvoices ..........');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Looding invoices ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    invoices =
        await ListAPI.getInvoices(entity.documentReference, 'govtEntities');

    _scaffoldKey.currentState.hideCurrentSnackBar();
    print('_InvoiceListState._getInvoices, found: ${invoices.length} ');
    setState(() {});
  }

  _getCached() async {
    entity = await SharedPrefs.getGovEntity();
    user = await SharedPrefs.getUser();
    FCM.configureFCM(
      invoiceListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + entity.participantId);
    print('_InvoiceListState._getCached SUBSCRIBED to invoices topic');
    _getInvoices();
    setState(() {});
  }

  void _acceptInvoice() async {
    print('_InvoiceListState._acceptInvoice');

    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Accepting  invoice ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var acceptance = new InvoiceAcceptance(
        supplierName: invoice.supplierName,
        customerName: entity.name,
        supplierDocumentRef: invoice.supplierDocumentRef,
        date: getUTCDate(),
        invoice: 'resource:com.oneconnect.biz.Invoice#${invoice.invoiceId}',
        govtEntity:
            'resource:com.oneconnect.biz.GovtEntity#${entity.participantId}',
        invoiceNumber: invoice.invoiceNumber,
        user: 'resource:com.oneconnect.biz.User#${user.userId}');

    try {
      var result = await DataAPI3.acceptInvoice(acceptance);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (result != null) {
        showError();
      } else {
        _getInvoices();
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice accepted',
            textColor: Colors.lightBlue,
            backgroundColor: Colors.black);
      }
    } catch (e) {
      showError();
    }
  }

  void showError() {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Acceptance FAILED',
        listener: this,
        actionLabel: 'Close');
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Invoices',
          style: Styles.blackBoldMedium,
        ),
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
                            fontSize: 20.0,
                            fontWeight: FontWeight.normal,
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
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: invoices == null ? 0 : invoices.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        _showDialog(invoices.elementAt(index));
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

  void _showDialog(Invoice invoice) {
    prettyPrint(invoice.toJson(), '_showDialog: invoice:');

    this.invoice = invoice;
    if (invoice.invoiceAcceptance == null) {
      showInvoiceAcceptanceDialog();
    } else {
      showInvoiceSettlementDialog();
    }
  }

  void showInvoiceSettlementDialog() {
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

  void showInvoiceAcceptanceDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Acceptance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to accept this Invoice?\n\ "),
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
                    onPressed: _acceptInvoice,
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

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  InvoiceCard({this.invoice, this.context});

  @override
  Widget build(BuildContext context) {
    String amount;
    String _getFormattedAmt() {
      amount = '${invoice.totalAmount}';
      return amount;
    }

    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: Card(
        elevation: 4.0,
        color: Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.description,
                        color: getRandomColor(),
                      ),
                    ),
                    Text(
                      getFormattedDateLongWithTime(invoice.date, context),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 16.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.supplierName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 4.0, top: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 70.0,
                      child: Text(
                        'Amount',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        amount == null
                            ? '0.00'
                            : getFormattedAmount('$amount', context),
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 10.0, top: 0.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 70.0,
                      child: Text(
                        'Invoice No:',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice == null ? '0.00' : invoice.invoiceNumber,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 0.0, top: 4.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('Accepted'),
                    ),
                    Text(
                      invoice.invoiceAcceptance == null ? 'NO' : 'YES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Opacity(
                        opacity: invoice.invoiceAcceptance == null ? 0.0 : 1.0,
                        child: Icon(
                          Icons.done,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('Settled'),
                    ),
                    Text(
                      invoice.isSettled == false ? 'NO' : 'YES',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Opacity(
                        opacity: invoice.isSettled == true ? 1.0 : 0.0,
                        child: Icon(
                          Icons.done,
                          color: Colors.teal,
                        ),
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
