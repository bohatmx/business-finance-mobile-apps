import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/app_model.dart';
import 'package:investor/ui/dashboard.dart';
import 'package:investor/ui/settle_all.dart';
import 'package:investor/ui/settle_invoice_bid.dart';
import 'package:flutter/scheduler.dart';
import 'package:scoped_model/scoped_model.dart';

class UnsettledBids extends StatefulWidget {
  
  @override
  _UnsettledBidsState createState() => _UnsettledBidsState();
}

class _UnsettledBidsState extends State<UnsettledBids>
    implements PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Investor investor;
  List<InvoiceBid> currentPage = List();
  InvestorAppModel appModel;
  bool isBusy, forceRefresh = false;
  @override
  void initState() {
    super.initState();

    _getCache();
    setBasePager();
  }

  _getCache() async {
    investor = await SharedPrefs.getInvestor();
  }

  double _getHeight() {
    if (appModel.unsettledInvoiceBids.length < 2) {
      return 200.0;
    } else {
      return 280.0;
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(_getHeight()),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: PagingTotalsView(
              pageValue: _getPageValue(),
              totalValue: _getTotalValue(),
              labelStyle: Styles.blackSmall,
              pageValueStyle: Styles.blackBoldLarge,
              totalValueStyle: Styles.brownBoldMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
            child: PagerControl(
              itemName: 'Invoice Bids to Settle',
              pageLimit: appModel.pageLimit,
              elevation: 16.0,
              items: appModel.unsettledInvoiceBids.length,
              listener: this,
              color: Colors.purple.shade50,
              pageNumber: _pageNumber,
            ),
          ),
          appModel.unsettledInvoiceBids.length < 2
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 12.0),
                  child: _getButton(),
                ),
        ],
      ),
    );
  }

  Widget _getButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: _startSettleAll,
          elevation: 4.0,
          color: Colors.pink,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Settle Everything!',
              style: Styles.whiteSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left:48.0),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: _sort,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ScrollController scrollController = ScrollController();
  Widget _getBody() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
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
    var unsettledBids = await Database.getUnsettledInvoiceBids();
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
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => SettleInvoiceBid(
                invoiceBid: invoiceBid,
              )),
    );
  }

  void _startSettleAll() {
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => SettleAll()),
    );
  }

  bool isFromSettlement = false,
      pagerShouldRefresh = false,
      refreshBidsInModel = false;
  void _onRefreshPressed() async {
    print(
        '\n_UnsettledBidsState._onRefreshPressed should refresh, has it? ...... pagerShouldRefresh = $pagerShouldRefresh}');

    setState(() {
      refreshBidsInModel = true;
    });
  }

  int buildCount = 0;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<InvestorAppModel>(
      builder: (context,_,model) {
        print('_UnsettledBidsState.build ... setting model .....');
        model.doPrint();
        appModel = model;
        buildCount++;
        if (buildCount == 1) {
          setBasePager();
        }
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
      },
      
    );
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (appModel == null) return;
    print(
        '_PurchaseOrderList.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.unsettledInvoiceBids,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
    //setState(() {});
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null) return 0.00;
    var t = 0.0;
    appModel.unsettledInvoiceBids.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  int _pageNumber = 1;
  @override
  onNextPageRequired() {
    print('_InvoicesOnOfferState.onNextPageRequired');
    if (currentPage == null) {
      currentPage = List();
    } else {
      currentPage.clear();
    }
    var page = basePager.getNextPage();
    if (page == null) {
      return;
    }
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

  @override
  onPageLimit(int pageLimit) async {
    print('_InvoicesOnOfferState.onPageLimit');
    await appModel.updatePageLimit(pageLimit);
    _pageNumber = 1;
    basePager.getNextPage();
    return null;
  }

  @override
  onPreviousPageRequired() {
    print('_InvoicesOnOfferState.onPreviousPageRequired');
    if (currentPage == null) {
      currentPage = List();
    }

    var page = basePager.getPreviousPage();
    if (page == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No more. No mas.',
          textColor: Styles.white,
          backgroundColor: Theme.of(context).primaryColor);
      return;
    }
    currentPage.clear();
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

//end of paging constructs

  bool sortToggle = false;
  void _sort() {
    if (sortToggle) {
      currentPage.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      currentPage.sort((a, b) => a.amount.compareTo(b.amount));
    }
    sortToggle = !sortToggle;
    setState(() {

    });
  }
}
