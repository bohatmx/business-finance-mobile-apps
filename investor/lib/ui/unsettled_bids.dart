import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/dashboard.dart';
import 'package:investor/ui/settle_invoice_bid.dart';
import 'package:scoped_model/scoped_model.dart';

class UnsettledBids extends StatefulWidget {
  @override
  _UnsettledBidsState createState() => _UnsettledBidsState();
}

class _UnsettledBidsState extends State<UnsettledBids>
    implements Pager3Listener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Investor investor;
  List<InvoiceBid> unsettledBids, currentPage = List();

  bool isBusy, forceRefresh = false;
  int pageLimit = 4;
  @override
  void initState() {
    super.initState();

    _getCache();
  }

  _getCache() async {
    setState(() {
      isBusy = true;
    });
    investor = await SharedPrefs.getInvestor();
    unsettledBids = await Database.getInvoiceBids();
    pageLimit = await SharedPrefs.getPageLimit();

    if (unsettledBids == null || unsettledBids.isEmpty) {
      forceRefresh = true;
      await getFreshData();
    }
    setState(() {
      isBusy = false;
    });
  }

  Future getFreshData() async {
    if (forceRefresh) {
      print('_UnsettledBidsState.getFreshData forceRefresh: $forceRefresh');
    } else {
      var date = await SharedPrefs.getRefreshDate();
      var diff = date.difference(DateTime.now()).inMinutes;
      if (diff < 30) {
        print(
            '_UnsettledBidsState.getFreshData - refreshed less than 30 minutes ago');
        return null;
      }
    }

    unsettledBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(unsettledBids));
    forceRefresh = false;
    return null;
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[
          ScopedModelDescendant<InvestorAppModel>(
            builder: (context, _, model) {
              if (refreshBidsInModel) {
                print(
                    '_UnsettledBidsState._getBottom asking Model to refresh bids ........');
                model.refreshInvoiceBids();
              }
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: model.invoiceBids == null || model.invoiceBids.isEmpty
                    ? null
                    : Pager3(
                        elevation: 8.0,
                        type: PagerHelper.INVOICE_BID,
                        items: model.invoiceBids,
                        pageLimit: pageLimit,
                        itemName: 'Invoice Bids',
                        addHeader: true,
                        listener: this,
                        pagerShouldRefresh: pagerShouldRefresh,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        itemBuilder: (BuildContext context, int index) {
          return new GestureDetector(
            onTap: () {
              _checkBid(currentPage.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: InvoiceBidCard(
                  bid: currentPage.elementAt(index),
                  showItemNumber: true,
                ),
              ),
            ),
          );
        });
  }

  InvoiceBid invoiceBid;
  void _showBidDialog(InvoiceBid bid) {
    print('_OffersAndBidsState._showBidDetail ......${bid.toJson()}');
    this.invoiceBid = bid;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Settlement",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 80.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to settle this Invoice Bid?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Amount:',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Text(
                            getFormattedAmount('${bid.amount}', context),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('NO'),
                ),
                FlatButton(
                  onPressed: _startSettlement,
                  child: Text('YES'),
                ),
              ],
            ));
  }

  void _checkBid(InvoiceBid bid) async {
    print('_UnsettledBidsState._checkBid ...............');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking bid ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    bool isFound = false;
    unsettledBids = await Database.getInvoiceBids();
    unsettledBids.forEach((b) {
      if (b.invoiceBidId == bid.invoiceBidId) {
        isFound = true;
      }
    });
    _scaffoldKey.currentState.removeCurrentSnackBar();
    if (isFound) {
      _showBidDialog(bid);
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'This bid is already settled',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
  }

  _startSettlement() async {
    Navigator.pop(context);
    bool result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => SettleInvoiceBid(invoiceBid)),
    );
    print(
        '\n\n_UnsettledBidsState._startSettlement ##  refresh ... calling _onRefreshPressed');
    isFromSettlement = true;
    _onRefreshPressed();
  }

  bool isFromSettlement = false,
      pagerShouldRefresh = false,
      refreshBidsInModel = false;
  void _onRefreshPressed() async {
//    AppSnackbar.showSnackbarWithProgressIndicator(
//        scaffoldKey: _scaffoldKey,
//        message: 'Refreshing bids ...',
//        textColor: Styles.white,
//        backgroundColor: Styles.black);
//
//    if (isFromSettlement) {
//      unsettledBids = await Database.getInvoiceBids();
//      isFromSettlement = false;
//    } else {
//      unsettledBids = await ListAPI.getUnsettledInvoiceBidsByInvestor(
//          investor.documentReference);
//      await Database.saveInvoiceBids(InvoiceBids(unsettledBids));
//    }
//    try {
//      _scaffoldKey.currentState.removeCurrentSnackBar();
//    } catch (e) {}
//
//    setState(() {
//      pagerShouldRefresh = true;
//      isBusy = false;
//    });

    print(
        '\n_UnsettledBidsState._onRefreshPressed should refresh, has it? ...... pagerShouldRefresh = $pagerShouldRefresh}');

    setState(() {
      refreshBidsInModel = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Offer Settlement',
          style: Styles.whiteBoldMedium,
        ),
        elevation: 4.0,
        bottom: _getBottom(),
        backgroundColor: Colors.teal.shade400,
        actions: <Widget>[
          IconButton(
            onPressed: _onRefreshPressed,
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: _getBody(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  @override
  onInitialPage(List<Findable> items) {
    print(
        '\n_UnsettledBidsState.onInitialPage ############## items: ${items.length} first itemNumber: ${items.first.itemNumber} last itemNumber: ${items.last.itemNumber}');

    currentPage.clear();
    items.forEach((i) {
      currentPage.add(i);
    });
    setState(() {});
  }

  @override
  onNoMoreData() {
    print('_UnsettledBidsState.onNoMoreData .......................');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No more. No mas.',
        textColor: Styles.white,
        backgroundColor: Colors.indigo.shade300);
  }

  @override
  onPage(List<Findable> items) {
    print(
        '\n_UnsettledBidsState.onPage ############## items: ${items.length} first itemNumber: ${items.first.itemNumber} last itemNumber: ${items.last.itemNumber}');
    currentPage.clear();
    items.forEach((i) {
      currentPage.add(i);
    });
    setState(() {});
  }
}
