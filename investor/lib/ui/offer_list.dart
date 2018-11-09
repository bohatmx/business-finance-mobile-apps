import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/offer_card.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:investor/ui/invoice_bidder.dart';
import 'package:investor/ui/refresh.dart';

class OfferList extends StatefulWidget {
  static _OfferListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_OfferListState>());
  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList>
    with WidgetsBindingObserver
    implements Pager3Listener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  List<Offer> baseList;

  List<Offer> openOffers = List();
  List<Offer> closedOffers = List();

  Investor investor;
  Offer offer;
  int currentStartKey, previousStartKey;
  OpenOfferSummary summary = OpenOfferSummary();
  List<int> keys = List();
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _buildDaysDropDownItems();
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    pageLimit = await SharedPrefs.getPageLimit();
    dashboardData = await SharedPrefs.getDashboardData();
    var list = await Database.getOffers();
    print(
        '_OfferListState._getCached ############# offers from cache: ${list.length} pageLimit: $pageLimit');
    if (baseList == null) {
      baseList = List();
    }
    baseList.clear();
    int count = 1;
    list.forEach((o) {
      if (o.isOpen) {
        o.itemNumber = count;
        baseList.add(o);
        dashboardData.totalOfferAmount += o.offerAmount;
        count++;
      }
    });
    print('_OfferListState._getCached, baseList : ${baseList.length}');
    setState(() {});
    _getOffers();
  }

  void _getOffers() async {
    print('\n\n\n_OfferListState._getOffers .......................');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  Offers ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    setState(() {
      _opacity = 0.0;
    });

    print('_OfferListState._getOffers ## ...currentStartKey: $currentStartKey');

    var res = Finder.find(
      intDate: currentStartKey,
      baseList: baseList,
      pageLimit: pageLimit,
    );
    print(res);
    openOffers.clear();
    if (res.items.isNotEmpty) {
      res.items.forEach((item) {
        openOffers.add(item as Offer);
      });
    }
    if (openOffers.isNotEmpty) {
      currentStartKey = openOffers.last.intDate;
    }
    print(
        '_OfferListState._getOffers after find, openOffers: ${openOffers.length}');
    setState(() {
      _opacity = 0.0;
    });
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
  }

  _checkBid(Offer offer) async {
    this.offer = offer;
    if (offer.isOpen == false) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is already closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking bid ...please wait',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);

    var xx = await ListAPI.getInvoiceBidByInvestorOffer(offer, investor);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (xx.isEmpty) {
      _showInvoiceBidDialog(offer);
    } else {
      prettyPrint(xx.first.toJson(),
          '########### INVOICE BID for investtor/offer found....');
      _showMoreBidsDialog();
    }
  }

  _showMoreBidsDialog() {
    if (!offer.isOpen) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is already closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Add more bids",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Text(
                'Do you want to add another bid for this offer?',
                style: Styles.blackBoldMedium,
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onInvoiceBidRequired,
                  child: Text('MAKE INVOICE BID'),
                ),
              ],
            ));
  }

  _showInvoiceBidDialog(Offer offer) {
    this.offer = offer;

    if (offer.isOpen == false) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer is closed',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Actions",
                style: Styles.blackBoldLarge,
              ),
              content: Container(
                height: 240.0,
                width: double.infinity,
                child: OfferListCard(
                  offer: offer,
                  color: Colors.grey.shade50,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text(
                    'No',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                RaisedButton(
                  elevation: 8.0,
                  onPressed: _onInvoiceBidRequired,
                  color: Colors.teal.shade600,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'MAKE INVOICE BID',
                      style: Styles.whiteSmall,
                    ),
                  ),
                ),
              ],
            ));
  }

  TextStyle white = TextStyle(color: Colors.black, fontSize: 16.0);

  List<DropdownMenuItem<int>> _buildDaysDropDownItems() {
    var item0 = DropdownMenuItem<int>(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '1 Day Under Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item0);
    var itema = DropdownMenuItem<int>(
      value: 3,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '3 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(itema);
    var item1 = DropdownMenuItem<int>(
      value: 7,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '7 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item1);
    var item2 = DropdownMenuItem<int>(
      value: 14,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.teal,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '14 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item2);

    var item3 = DropdownMenuItem<int>(
      value: 30,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.brown,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '30 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item3);
    var item4 = DropdownMenuItem<int>(
      value: 60,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '60 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item4);
    var item5 = DropdownMenuItem<int>(
      value: 90,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.deepOrange,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '90 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item5);

    var item6 = DropdownMenuItem<int>(
      value: 120,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '120 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item6);
    var item7 = DropdownMenuItem<int>(
      value: 365,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '365 Days Review',
              style: bold,
            ),
          ),
        ],
      ),
    );
    items.add(item7);

    return items;
  }

  double _getTotalValue() {
    var t = 0.00;
    openOffers.forEach((o) {
      t += o.offerAmount;
    });
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Open Invoice Offers',
          style: Styles.whiteBoldMedium,
        ),
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
      body: _getListView(),
      backgroundColor: Colors.indigo.shade50,
    );
  }

  Offer _getOffer(int index) {
    if (openOffers == null) {
      return null;
    }
    return openOffers.elementAt(index);
  }

  List<DropdownMenuItem<int>> items = List();
  int currentIndex = 0;
  DashboardData dashboardData;
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
        itemCount: openOffers == null ? 0 : openOffers.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            onTap: () {
              _checkBid(openOffers.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OfferCard(
                offer: _getOffer(index),
                number: index + 1,
                elevation: 1.0,
              ),
            ),
          );
        });
  }

  Widget _getBottom() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
          child: baseList == null
              ? Container()
              : Pager3(
                  listener: this,
                  itemName: 'Offers',
                  elevation: 8.0,
                  items: baseList,
                  addHeader: true,
                  type: PagerHelper.OFFER,
                  pageLimit: pageLimit == null ? 10 : pageLimit,
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: Opacity(
                    opacity: _opacity,
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.yellow,
                          strokeWidth: 3.0,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String text = 'OPEN';

  void _onNoPressed() {
    //print'_OfferListState._onNoPressed');
    Navigator.pop(context);
  }

  Future _onInvoiceBidRequired() async {
    prettyPrint(offer.toJson(), '_OfferListState._onYesPressed....');
    Navigator.pop(context);
    bool refresh = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceBidder(offer)),
    );
    if (refresh == null) {
      return;
    }

    if (refresh) {
      _refresh();
    }
  }

  void _refresh() async {
    await Refresh.refresh(investor);
    _getCached();
  }

  int pageLimit;

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No more. No mas.',
        textColor: Styles.white,
        backgroundColor: Colors.indigo);
  }

  @override
  onInitialPage(List<Findable> items) {
    setOffers(items);
  }

  @override
  onPage(List<Findable> items) {
    setOffers(items);
  }

  void setOffers(List<Findable> items) {
    openOffers.clear();
    items.forEach((f) {
      openOffers.add(f);
    });
    setState(() {});
  }
}

class OfferListCard extends StatelessWidget {
  final Offer offer;
  final Color color;
  final double width = 60.0;

  OfferListCard({this.offer, this.color});

  @override
  Widget build(BuildContext context) {
    //print'OfferListCard.build');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "Supplier",
              style: Styles.greyLabelSmall,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Text(
                    offer.supplierName == null
                        ? 'Unknown yet'
                        : offer.supplierName,
                    overflow: TextOverflow.clip,
                    style: Styles.blackBoldSmall),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            children: <Widget>[
              Text(
                "Customer",
                style: Styles.greyLabelSmall,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Text(
                  offer.customerName == null
                      ? 'Unknown yet'
                      : offer.customerName,
                  style: Styles.blackBoldSmall,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 40.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'Start',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                  offer.startTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.startTime),
                  style: Styles.blackBoldSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'End',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                  offer.endTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.endTime),
                  style: Styles.pinkBoldSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Container(
                  width: 60.0,
                  child: Text(
                    'Amount',
                    style: Styles.greyLabelSmall,
                  )),
              Text(
                offer.offerAmount == null
                    ? 'Unknown yet'
                    : getFormattedAmount('${offer.offerAmount}', context),
                style: Styles.tealBoldLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
