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
  List<Offer> offers = List();
  Supplier supplier;
  Offer offer;
  DashboardData dashboardData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCached();
  }

  void _getCached() async {
    supplier = await SharedPrefs.getSupplier();
    assert(supplier != null);
    dashboardData = await SharedPrefs.getDashboardData();
    _getOffers();
  }

  double totalValue = 0.00;
  void _getOffers() async {
    print('_OfferListState._getOffers .......................');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  Offers ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);

    offers = await Database.getOffers();
    totalValue = 0.0;

    offers.forEach((o) {
      totalValue += o.offerAmount;
    });
    dashboardData.totalOfferAmount = totalValue;
    setState(() {});
    _scaffoldKey.currentState.hideCurrentSnackBar();
    var cnt = 0;
    FCM.configureFCM(invoiceBidListener: this);
    offers.forEach((offer) {
      if (offer.isOpen) {
        _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + offer.offerId);
        cnt++;
      }
    });
    print('_OfferListState._getOffers - subscribed to invoiceBids: $cnt');
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Offers'),
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(200.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
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
  ScrollController scrollController = ScrollController();
  Widget _getList() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            onTap: () {
              _checkBids(currentPage.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0),
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
  }

  Widget _getBottom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 0.0),
      child: Column(
        children: <Widget>[
          offers.isEmpty
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Pager3(
                    elevation: 16.0,
                    itemName: 'Offers',
                    items: offers,
                    pageLimit: pageLimit,
                    listener: this,
                    type: PagerHelper.OFFER,
                    addHeader: true,
                  ),
                ),
        ],
      ),
    );
  }

  void _refresh() {
    _getOffers();
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  List<InvoiceBid> bids = List();

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    bids.add(invoiceBid);
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.white,
        backgroundColor: Styles.black);
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Done.',
        textColor: Styles.white,
        backgroundColor: Colors.teal.shade300);
  }

  List<Offer> currentPage = List();
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
        '\n\n\n_OfferListState.onInitialPage *******************************\n\n');
    currentPage.clear();
    items.forEach((i) {
      currentPage.add(i as Offer);
    });
  }
}
