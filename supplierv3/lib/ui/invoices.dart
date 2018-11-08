import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/offerCancellation.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/ui/make_offer.dart';
import 'package:supplierv3/ui/summary_helper.dart';

class InvoicesOnOffer extends StatefulWidget {
  @override
  _InvoicesOnOfferState createState() => _InvoicesOnOfferState();
}

class _InvoicesOnOfferState extends State<InvoicesOnOffer>
    implements Pager3Listener, SnackBarListener {
  List<Invoice> invoices = List(), baseList;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pageLimit = 2, currentStartKey;
  DashboardData dashboardData;
  User user;
  Supplier supplier;

  @override
  void initState() {
    super.initState();

    _getCached();
  }

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    dashboardData = await SharedPrefs.getDashboardData();
    baseList = await Database.getInvoices();
    pageLimit = await SharedPrefs.getPageLimit();

    setState(() {});
  }

  Future _goMakeOffer(Invoice invoice) async {
    //check for acceptance
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    var acceptance = await ListAPI.getInvoiceAcceptanceByInvoice(
        supplier.documentReference,
        'resource:com.oneconnect.biz.Invoice#${invoice.invoiceId}');
    if (acceptance == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'The invoice has not been accepted yet',
          textColor: Styles.yellow,
          backgroundColor: Styles.black);
      return;
    }

    var offX = await ListAPI.getOfferByInvoice(invoice.invoiceId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (offX == null) {
      bool refresh = await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
      );
      if (refresh != null && refresh) {
        _getCached();
      }
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
    }
  }

  void _viewOffer(Invoice invoice) async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Getting Offer details ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var bag = await ListAPI.getOfferByInvoice(invoice.invoiceId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    prettyPrint(bag.offer.toJson(), '_InvoiceListState._viewOffer .......');
    var now = DateTime.now();
    var start = DateTime.parse(bag.offer.startTime);
    var end = DateTime.parse(bag.offer.endTime);
    print(
        'ListAPI.getInvoicesOnOffer start: ${start.toIso8601String()} end: ${end.toIso8601String()} now: ${now.toIso8601String()}');
    if (now.isAfter(start) && now.isBefore(end)) {
      print(
          '_InvoiceListState._viewOffer ======= this is valid. between  start and end times');
      _showCancelDialog(bag.offer);
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer has expired or settled',
          listener: this,
          actionLabel: 'CLOSE');
    }
  }

  Offer offer;
  void _showCancelDialog(Offer offer) {
    this.offer = offer;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Offer Cancellattion",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 200.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'This invoice has been offered to the BFN network.\n\nDo you want to cancel this offer?: \n',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('Offer Amount'),
                        ),
                        Text(
                          offer.offerAmount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${offer.offerAmount}', context),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text('Offer Date'),
                          ),
                          Text(
                            offer.startTime == null
                                ? ''
                                : getFormattedDate(offer.startTime),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('NO')),
                FlatButton(
                  onPressed: _cancelOffer,
                  child: Text('YES'),
                )
              ],
            ));
  }

  void _cancelOffer() async {
    print('_InvoiceListState._cancelOffer ..........');
    Navigator.pop(context);

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking offer ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    var m = await ListAPI.getOfferById(offer.offerId);

    if (m.invoiceBids != null && m.invoiceBids.isNotEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already has bids. Cannot be cancelled',
          listener: this,
          actionLabel: 'CLOSE');
      _scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }

    var cancellation = OfferCancellation(
        offer: 'resource:com.oneconnect.biz.Offer#${offer.offerId}',
        user: 'resource:com.oneconnect.biz.User#${user.userId}');

    var result = await DataAPI.cancelOffer(cancellation);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Cancel failed',
          listener: this,
          actionLabel: 'CLOSE');
    } else {
      Refresh.refresh(supplier);
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer cancelled',
          textColor: Colors.yellow,
          backgroundColor: Colors.black);
    }
  }

  Future _refresh() async {
    await Refresh.refresh(supplier);
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[
          baseList == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 20.0),
                  child: Pager3(
                    addHeader: true,
                    itemName: 'Invoices',
                    items: baseList,
                    pageLimit: pageLimit,
                    elevation: 8.0,
                    listener: this,
                  ),
                ),
        ],
      ),
    );
  }

  _onInvoiceTapped(Invoice invoice) {
    if (invoice.isOnOffer) {
      _viewOffer(invoice);
    } else {
      _goMakeOffer(invoice);
    }
  }

  ScrollController scrollController = ScrollController();
  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: invoices == null ? 0 : invoices.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                _onInvoiceTapped(invoices.elementAt(index));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                child: InvoiceOnOfferCard(
                  invoice: invoices.elementAt(index),
                  context: context,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoices'),
        backgroundColor: Colors.brown.shade200,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
        bottom: _getBottom(),
      ),
      body: _getListView(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  @override
  onInitialPage(List<Findable> items) {
    invoices.clear();
    items.forEach((f) {
      invoices.add(f);
    });

    setState(() {});
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more',
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }

  @override
  onPage(List<Findable> items) {
    invoices.clear();
    items.forEach((f) {
      invoices.add(f);
    });

    setState(() {});
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }
}

class InvoiceOnOfferCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  final double elevation;

  InvoiceOnOfferCard({this.invoice, this.context, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Card(
        elevation: elevation == null ? 2.0 : elevation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${invoice.itemNumber}',
                      style: Styles.blackBoldSmall,
                    ),
                  ),
                  Text(
                    getFormattedDateLongWithTime(invoice.date, context),
                    style: Styles.blackSmall,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      invoice.customerName,
                      style: Styles.blackBoldMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'Amount',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.amount == null ? '0.00' : _getFormattedAmt(),
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'VAT',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.valueAddedTax == null
                            ? '0.00'
                            : _getFormattedAmt(),
                        style: Styles.blackSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60.0,
                    child: Text(
                      'Invoice',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      invoice.invoiceNumber == null
                          ? ''
                          : invoice.invoiceNumber,
                      style: Styles.blackSmall,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60.0,
                      child: Text(
                        'Total',
                        style: Styles.greyLabelSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.totalAmount == null
                            ? '0.00'
                            : _getFormattedAmt(),
                        style: Styles.tealBoldMedium,
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

  String _getFormattedAmt() {
    return getFormattedAmount('${invoice.totalAmount}', context);
  }
}
