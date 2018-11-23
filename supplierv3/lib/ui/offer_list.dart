import 'dart:io';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/offer_card.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:supplierv3/app_model.dart';
import 'package:supplierv3/ui/offer_details.dart';

class OfferList extends StatefulWidget {
  static _OfferListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_OfferListState>());
  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList>
    with WidgetsBindingObserver
    implements InvoiceBidListener, SnackBarListener, Pager3Listener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  Supplier supplier;
  Offer offer;
  SupplierAppModel appModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCached();
  }

  void _getCached() async {
    supplier = await SharedPrefs.getSupplier();
    assert(supplier != null);
    pageLimit = await SharedPrefs.getPageLimit();
    if (pageLimit == null) {
      pageLimit = 4;
    }
    print(
        '_OfferListState._getCached ---------- pageLimit from cache: $pageLimit');
    FCM.configureFCM(context: context, invoiceBidListener: this);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + supplier.participantId);
    //_bind();
    try {
      setState(() {});
    } catch (e) {}
  }

  _checkBids(Offer offer) async {
    this.offer = offer;

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new OfferDetails(offer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        '\n\n_OfferListState.build ################### rebuilding widget ..........\n\n');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Offers'),
        elevation: 2.0,
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(200.0),
        ),
        backgroundColor: Colors.indigo.shade200,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPressed,
          ),
        ],
      ),
      body: _getList(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  List<DropdownMenuItem<int>> items = List();
  int pageLimit;
  double pageValue;

  Widget _getList() {
    return ScopedModelDescendant<SupplierAppModel>(
        builder: (context, _, model) {
      return ListView.builder(
          itemCount: currentPage == null ? 0 : currentPage.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              onTap: () {
                _checkBids(currentPage.elementAt(index));
              },
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0),
                child: OfferCard(
                  offer: currentPage.elementAt(index),
                  number: index + 1,
                  elevation: 1.0,
                  showSupplier: false,
                  showCustomer: true,
                ),
              ),
            );
          });
    });
  }

  Widget _getBottom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 0.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScopedModelDescendant<SupplierAppModel>(
              builder: (context, _, model) {
                print(
                    '_OfferListState._getBottom check offers ${model.getTotalOpenOffers()}');
                appModel = model;
                if (isRefreshOffers) {
                  isRefreshOffers = false;
                  model.refreshOffers();
                }
                if (model.offers == null || pageLimit == null) {
                  return Container();
                }
                return Pager3(
                  elevation: 16.0,
                  itemName: 'Offers',
                  items: model.offers,
                  pageLimit: pageLimit,
                  listener: this,
                  type: PagerHelper.OFFER,
                  addHeader: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isRefreshOffers = false;
  void _refreshPressed() {
    appModel.refreshOffers();
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print(
        '\n\n_OfferListState.onInvoiceBidMessage, ${invoiceBid.investorName} amount: ${invoiceBid.amount}');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    appModel.addInvoiceBid(invoiceBid);
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Done.',
        textColor: Styles.white,
        backgroundColor: Colors.teal.shade300);
  }

  List<Offer> currentPage;
  @override
  onPage(List<Findable> items) {
    print('\n\n_OfferListState.onPage ############# items: ${items.length}');
    currentPage.clear();
    items.forEach((f) {
      currentPage.add(f as Offer);
    });
    pageValue = 0.00;
    currentPage.forEach((o) {
      pageValue += o.offerAmount;
    });
    print('_OfferListState.onPage ---- pageValue: $pageValue');
    try {
      setState(() {});
      print('_OfferListState.onPage state has been set');
    } catch (e) {
      print('\n\n************* setState() took a hit ******************');
    }
  }

  @override
  onInitialPage(List<Findable> items) {
    print(
        '\n\n_OfferListState.onInitialPage ******** items: ${items.length} ***********************\n\n');
    currentPage.clear();
    items.forEach((i) {
      currentPage.add(i as Offer);
    });
    setState(() {});
  }
}
