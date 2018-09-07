import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/offerCancellation.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/listeners/firestore_listener.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/make_offer.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList>
    implements
        SnackBarListener,
        CardListener,
        InvoiceBidListener,
        InvoiceAcceptanceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  static const MakeOffer = '1', CancelOffer = '2', EditInvoice = '3';
  List<Invoice> invoicesOpen = List(),
      invoicesOnOffer = List(),
      invoicesSettled = List();
  Invoice invoice;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isInvoice;
  List<DropdownMenuItem<String>> items = List();
  List<Invoice> invoices;

  @override
  void initState() {
    super.initState();

    _getCached();
  }

  _listenForBids() async {
    invoicesOnOffer.forEach((i) {
      listenForInvoiceBid(i.offer.split('#').elementAt(1), this);
    });

    listenForInvoiceAcceptance(supplier.documentReference, this);
  }

  _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    setState(() {});
    _getInvoices();
  }

  bool haveListened = false;
  _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoices ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    totalOnOffer = '0.00';
    totalOpen = '0.00';
    totalSettled = '0.00';
    invoicesOpen = await ListAPI.getInvoicesOpenForOffers(
        supplier.documentReference, 'suppliers');
    invoicesOpen.sort((a, b) => b.date.compareTo(a.date));
    _calculateOpen();

    invoicesOnOffer = await ListAPI.getInvoicesOnOffer(
        supplier.documentReference, 'suppliers');
    invoicesOnOffer.sort((a, b) => b.date.compareTo(a.date));
    if (!haveListened) {
      _listenForBids();
      haveListened = true;
    }
    _calculateOnOffer();

    invoicesSettled = await ListAPI.getInvoicesSettled(
        supplier.documentReference, 'suppliers');
    invoicesSettled.sort((a, b) => b.date.compareTo(a.date));
    _calculateSettled();

    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
  }

  void _calculateOpen() {
    if (invoicesOpen.isNotEmpty) {
      double total = 0.00;
      invoicesOpen.forEach((inv) {
        double amt = inv.totalAmount;
        total += amt;
      });

      totalOpen = getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  void _calculateOnOffer() {
    if (invoicesOnOffer.isNotEmpty) {
      double total = 0.00;
      invoicesOnOffer.forEach((inv) {
        double amt = inv.totalAmount;
        total += amt;
      });

      totalOnOffer = getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  void _calculateSettled() {
    print('_InvoiceListState._calculateSettled');
    if (invoicesSettled.isNotEmpty) {
      double total = 0.00;
      invoicesSettled.forEach((inv) {
        double amt = inv.totalAmount;
        total += amt;
      });

      totalSettled = getFormattedAmount('$total', context);
      print('totalSettled: $totalSettled');
    }
    setState(() {});
  }

  String totalOpen = '0.00', totalOnOffer = '0.00', totalSettled = '0.00';
  @override
  Widget build(BuildContext context) {
    print('_InvoiceListState.build');
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Invoice Manager'),
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
              text: invoicesOpen == null
                  ? 'Open - 0'
                  : 'Open - ${invoicesOpen.length}',
            ),
            Tab(
              text: invoicesOnOffer == null
                  ? 'On Offer - 0'
                  : 'On Offer - ${invoicesOnOffer.length}',
            ),
            Tab(
              text: invoicesSettled == null
                  ? 'Settled - 0'
                  : 'Settled - ${invoicesSettled.length}',
            ),
          ]),
        ),
        body: TabBarView(children: [
          _getOpenView(),
          _getOnOfferView(),
          _getSettledView(),
        ]),
      ),
    );
  }

  Widget _getOnOfferView() {
    _calculateOnOffer();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 10.0,
                ),
                child: Text('Total Value'),
              ),
              Text(
                totalOnOffer == null ? '0.00' : totalOnOffer,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    color: Colors.purple),
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: invoicesOnOffer == null ? 0 : invoicesOnOffer.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _confirm(invoicesOnOffer.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InvoiceCard(
                      invoice: invoicesOnOffer.elementAt(index),
                      context: context,
                      listener: this,
                      type: OnOffer,
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getOpenView() {
    _calculateOpen();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 20.0),
                child: Text('Total Value'),
              ),
              Text(
                totalOpen == null ? '0.00' : totalOpen,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    color: Colors.purple.shade200),
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: invoicesOpen == null ? 0 : invoicesOpen.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _confirm(invoicesOpen.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InvoiceCard(
                      invoice: invoicesOpen.elementAt(index),
                      context: context,
                      listener: this,
                      type: Open,
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getSettledView() {
    _calculateSettled();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Value'),
              ),
              Text(
                totalSettled == null ? '0.00' : totalSettled,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: invoicesSettled == null ? 0 : invoicesSettled.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _confirm(invoicesSettled.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InvoiceCard(
                      invoice: invoicesSettled.elementAt(index),
                      context: context,
                      listener: this,
                      type: Open,
                    ),
                  ),
                );
              }),
        ),
      ],
    );
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
      _getInvoices();
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
      new MaterialPageRoute(
          builder: (context) =>
              new DeliveryNoteList('Tap a Delivery Note to create Invoice')),
    );
  }

  void _confirm(Invoice elementAt) {}

  @override
  onCardTapped(Invoice invoice, int type) async {
    print('_InvoiceListState.onCardTapped ...............');
    this.invoice = invoice;
    switch (type) {
      case OnOffer:
        print('_InvoiceListState.onCardTapped - invoice onOffer tapped');
        _viewOffer();
        break;
      case Open:
        print('_InvoiceListState.onCardTapped - invoice open tapped');
        await _goMakeOffer(invoice);
        break;
      case Settled:
        break;
    }
  }

  Future _goMakeOffer(Invoice invoice) async {
    //check for acceptance

    if (invoice.invoiceAcceptance == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'The invoice has not been accepted yet',
          textColor: Styles.yellow,
          backgroundColor: Styles.black);
      return;
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    var offX = await ListAPI.getOfferByInvoice(invoice.invoiceId);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (offX == null) {
      bool refresh = await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new MakeOfferPage(invoice)),
      );
      if (refresh != null && refresh) {
        _getInvoices();
        _listenForBids();
      }
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
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

  @override
  onInvoiceBid(InvoiceBid bid) {
    prettyPrint(bid.toJson(), 'invoice bid arrived: #########################');

    DateTime now = DateTime.now();
    DateTime biddate = DateTime.parse(bid.date);
    Duration difference = now.difference(biddate);
    if (difference.inHours > 12) {
      print(
          '_InvoiceListState.onInvoiceBid -  IGNORED: older than 12 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    var amt = getFormattedAmount('${bid.amount}', context);

    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message:
            'Last Invoice Bid arrived\n${bid.investorName}\n$amt  ${getFormattedDateHour(bid.date)}',
        textColor: Colors.green,
        backgroundColor: Colors.black,
        actionLabel: 'VIEW',
        listener: this,
        icon: Icons.done_all,
        action: 3);
  }

  @override
  onInvoiceAcceptance(InvoiceAcceptance ia) {
    prettyPrint(ia.toJson(), '_InvoiceListState.onInvoiceAcceptance');
    DateTime now = DateTime.now();
    DateTime biddate = DateTime.parse(ia.date);
    Duration difference = now.difference(biddate);
    if (difference.inHours > 1) {
      print(
          '_InvoiceListState.onInvoiceAcceptance -  IGNORED: older than 12 hours  --------bid done  ${difference.inHours} hours ago.');
      return;
    }
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice accepted: ${getFormattedDateHour(ia.date)}',
        textColor: Colors.lightGreen,
        backgroundColor: Colors.black);
    _getInvoices();
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
          elevation: 4.0,
          color: _getColor(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 20.0, top: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.description,
                        color: Colors.purple,
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
                    const EdgeInsets.only(left: 30.0, bottom: 0.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Text('Amount'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.amount == null ? '0.00' : _getFormattedAmt(),
                        style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
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
                    Text('Invoice Number'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.invoiceNumber == null
                            ? ''
                            : invoice.invoiceNumber,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
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
