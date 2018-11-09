import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:govt/ui/invoice_settlement.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList>
    implements SnackBarListener, InvoiceListener, Pager3Listener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();

  GovtEntity entity;
  List<Invoice> invoices = List();
  List<Invoice> baseList;
  Invoice invoice;
  User user;
  int currentStartKey;
  DashboardData dashboardData;
  int pageLimit;

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
    baseList = await Database.getInvoices();
    _getInvoicePageItems();

    _scaffoldKey.currentState.hideCurrentSnackBar();
    print(
        '\n\n_InvoiceListState._getInvoices, ############ found: ${invoices.length} ');
    setState(() {});
  }

  _getInvoicePageItems() {
    var result = Finder.find(
        intDate: currentStartKey, pageLimit: pageLimit, baseList: baseList);
    invoices.clear();
    result.items.forEach((item) {
      if (item is Invoice) {
        invoices.add(item);
        print(
            '${item.date} - ${item.intDate} ${item.customerName} --> ${item.supplierName}');
      }
    });
    currentStartKey = result.startKey;
  }

  _getCached() async {
    entity = await SharedPrefs.getGovEntity();
    user = await SharedPrefs.getUser();
    dashboardData = await SharedPrefs.getDashboardData();
    pageLimit = await SharedPrefs.getPageLimit();

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

  Widget _getBottom() {
    return PreferredSize(
        child: Column(
          children: <Widget>[
            baseList == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, bottom: 10.0, left: 8.0, right: 8.0),
                    child: Pager3(
                      addHeader: true,
                      listener: this,
                      elevation: 8.0,
                      items: baseList,
                      pageLimit: pageLimit == null ? 4 : pageLimit,
                      itemName: 'Invoices',
                      type: PagerHelper.INVOICE,
                    ),
                  ),
          ],
        ),
        preferredSize: Size.fromHeight(200.0));
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
        backgroundColor: Colors.pink.shade200,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getInvoices,
          )
        ],
        bottom: _getBottom(),
      ),
      backgroundColor: Colors.brown.shade100,
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController controller1 = ScrollController();

  Widget _buildList() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: invoices == null ? 0 : invoices.length,
        controller: controller1,
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
        });
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
    baseList.insert(0, invoice);
    setState(() {});
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Have not.',
        textColor: Styles.white,
        backgroundColor: Colors.brown.shade300);
  }

  @override
  onInitialPage(List<Findable> items) {
    _setInvoices(items);
  }

  @override
  onPage(List<Findable> items) {
    _setInvoices(items);
  }

  void _setInvoices(List<Findable> items) {
    invoices.clear();
    items.forEach((f) {
      invoices.add(f);
    });
    setState(() {});
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

    double width = 80.0;
    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        invoice.itemNumber == null
                            ? '0'
                            : '${invoice.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                    ),
                    Text(
                      getFormattedDateLongWithTime(invoice.date, context),
                      style: Styles.blackSmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: Text(
                          invoice.supplierName,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
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
                      width: width,
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
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 4.0, top: 0.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: width,
                      child: Text(
                        'Invoice No:',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice == null ? '0.00' : invoice.invoiceNumber,
                        style: Styles.blackSmall,
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
                      child: Container(
                        width: width,
                        child: Text(
                          'Accepted',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    Text(
                      invoice.invoiceAcceptance == null ? 'NO' : 'YES',
                      style: Styles.blackSmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Opacity(
                        opacity: invoice.invoiceAcceptance == null ? 0.0 : 1.0,
                        child: Icon(
                          Icons.done,
                          size: 24.0,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: width,
                        child: Text(
                          'Settled',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                    Text(
                      invoice.isSettled == false ? 'NO' : 'YES',
                      style: Styles.blackSmall,
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
