import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/offerCancellation.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/invoice_page.dart';
import 'package:supplierv3/ui/make_offer.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList>
    implements SnackBarListener, CardListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static const MakeOffer = '1', CancelOffer = '2', EditInvoice = '3';
  List<Invoice> invoicesOpen, invoicesOnOffer, invoicesSettled;
  Invoice invoice;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isInvoice;
  List<DropdownMenuItem<String>> items = List();

  @override
  void initState() {
    super.initState();

    _getCached();
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
    var item1 = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
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
      ),
    );
    var item2 = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
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
      ),
    );
    var item3 = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
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
      ),
    );

    if (invoice.offer == null) {
      return Column(
        children: <Widget>[
          item1,
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
    } else {
      return Column(
        children: <Widget>[
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
  }

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    setState(() {});
    _getInvoices();
  }

  _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoices ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    invoicesOpen = await ListAPI.getInvoicesOpenForOffers(
        supplier.documentReference, 'suppliers');

    invoicesOnOffer = await ListAPI.getInvoicesOnOffer(
        supplier.documentReference, 'suppliers');

    invoicesSettled = await ListAPI.getInvoicesSettled(
        supplier.documentReference, 'suppliers');

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _calculateTotal();
  }

  void _calculateTotal() {
    if (invoicesOpen.isNotEmpty) {
      double total = 0.00;
      invoicesOpen.forEach((inv) {
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Invoices'),
          elevation: 8.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _onInvoiceAdd,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _getInvoices,
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: 'On Offer',
            ),
            Tab(
              text: 'Open',
            ),
            Tab(
              text: 'Settled',
            ),
          ]),
        ),
        body: TabBarView(children: [
          _getOnOfferView(),
          _getOpenView(),
          _getSettledView(),
        ]),
      ),
    );
  }

  Widget _getOnOfferView() {
    return Column(
      children: <Widget>[
        new Flexible(
          child: new ListView.builder(
              itemCount: invoicesOnOffer == null ? 0 : invoicesOnOffer.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _confirm(invoicesOnOffer.elementAt(index));
                  },
                  child: InvoiceCard(
                    invoice: invoicesOnOffer.elementAt(index),
                    context: context,
                    listener: this,
                    type: OnOffer,
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getOpenView() {
    return Column(
      children: <Widget>[
        new Flexible(
          child: new ListView.builder(
              itemCount: invoicesOpen == null ? 0 : invoicesOpen.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _confirm(invoicesOpen.elementAt(index));
                  },
                  child: InvoiceCard(
                    invoice: invoicesOpen.elementAt(index),
                    context: context,
                    listener: this,
                    type: Open,
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getSettledView() {
    return Container();
  }

  @override
  onActionPressed(int action) {
    print('_InvoiceListState.onActionPressed');
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';
  void _onOffer() async {
    print('_InvoiceListState._onOffer');
    Navigator.pop(context);
    var isOffered = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
    );
    if (isOffered) {
      print('_InvoiceListState._onOffer; invoice offered, refreshing ...');
      _getInvoices();
    }
  }

  void _cancelOffer() async {
    print('_InvoiceListState._cancelOffer ..........');
    Navigator.pop(context);
    var api = new DataAPI(getURL());

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

    var result = await api.cancelOffer(cancellation);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Cancel failed',
          listener: this,
          actionLabel: 'CLOSE');
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer cancelled',
          textColor: Colors.yellow,
          backgroundColor: Colors.black);
    }
  }

  void _onInvoiceAdd() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryAcceptanceList()),
    );
  }

  void _confirm(Invoice elementAt) {}

  @override
  onCardTapped(Invoice invoice, int type) {
    print('_InvoiceListState.onCardTapped ...............');
    this.invoice = invoice;
    switch (type) {
      case OnOffer:
        print('_InvoiceListState.onCardTapped - invoice onOffer tapped');
        _viewOffer();
        break;
      case Open:
        print('_InvoiceListState.onCardTapped - invoice open tapped');
        break;
      case Settled:
        break;
    }
  }

  void _viewOffer() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Getting Offer details ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var bag = await ListAPI.getOfferById(invoice.offer.split('#').elementAt(1));
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
                height: 160.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to cancel this offer?: \n\n',
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
                FlatButton(onPressed: _ignore, child: Text('NO')),
                FlatButton(
                  onPressed: _cancelOffer,
                  child: Text('YES'),
                )
              ],
            ));
  }

  void _ignore() {
    Navigator.pop(context);
  }
}

const OnOffer = 1, Open = 2, Settled = 3;

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final BuildContext context;
  final int type;
  final CardListener listener;
  InvoiceCard(
      {@required this.invoice,
      @required this.context,
      @required this.type,
      @required this.listener});

  Color _getColor() {
    switch (type) {
      case OnOffer:
        return Colors.brown.shade50;
      case Open:
        return Colors.teal.shade50;
      case Settled:
        return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 12.0, right: 12.0, bottom: 12.0, top: 12.0),
      child: GestureDetector(
        onTap: _process,
        child: Card(
          elevation: 2.0,
          color: _getColor(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 20.0, top: 30.0),
                child: Row(
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
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: _process,
                        child: Text(
                          invoice.customerName,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 30.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Text('Amount'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.amount == null ? '0.00' : _getFormattedAmt(),
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
      ),
    );
  }

  String _getFormattedAmt() {
    return getFormattedAmount('${invoice.amount}', context);
  }

  bool isOffered() {
    if (invoice.offer == null) {
      return false;
    } else {
      return true;
    }
  }

  _process() {
    listener.onCardTapped(invoice, type);
  }
}

abstract class CardListener {
  onCardTapped(Invoice invoice, int type);
}
