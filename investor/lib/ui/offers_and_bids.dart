import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/invoice_bidder.dart';
import 'package:investor/ui/offer_list.dart';

class OffersAndBids extends StatefulWidget {
  @override
  _OffersAndBidsState createState() => _OffersAndBidsState();
}

class _OffersAndBidsState extends State<OffersAndBids> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Offer> openOffers = List();
  List<InvoiceBid> unsettledBids = List();
  List<InvoiceBid> settledBids = List();
  Investor investor;
  InvestorProfile profile;

  List<DropdownMenuItem<int>> items = List();

  @override
  initState() {
    super.initState();
    items = buildDaysDropDownItems();
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    profile = await SharedPrefs.getInvestorProfile();

    _getData();
  }

  void _getData() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading data ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    openOffers = await ListAPI.getOpenOffers();
    var s = await ListAPI.getInvoiceBidsByInvestor(investor.documentReference);
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }

    settledBids.clear();
    unsettledBids.clear();
    totalSettled = 0.00;
    totalUnsettled = 0.00;
    s.forEach((m) {
      if (m.isSettled) {
        settledBids.add(m);
        totalSettled += m.amount;
      } else {
        unsettledBids.add(m);
        totalUnsettled += m.amount;
      }
    });
    totalOpenOffers = 0.00;
    openOffers.forEach((f) {
      totalOpenOffers += f.offerAmount;
    });
    setState(() {});
  }

  double totalUnsettled = 0.00;
  double totalSettled = 0.00;
  double totalOpenOffers = 0.00;
  int days = 30;

  Widget _createUnsettledBids() {
    print(
        '\n\n_OfferListsState._createUnsettledBids ####################################\n\n');
    return Column(
      children: <Widget>[
//        Row(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(left: 28.0, top: 8.0),
//              child: DropdownButton<int>(
//                items: items,
//                elevation: 8,
//                hint: Text(
//                  'Period in Days',
//                  style: Styles.blueMedium,
//                ),
//                onChanged: _onDropDownChanged,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 8.0),
//              child: Text(
//                '$days',
//                style: Styles.blackBoldReallyLarge,
//              ),
//            ),
//          ],
//        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total'),
              ),
              Text(
                totalUnsettled == null
                    ? '0.00'
                    : getFormattedAmount('$totalUnsettled', context),
                style: Styles.pinkBoldReallyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0, top: 4.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Bids'),
              ),
              Text(
                '${unsettledBids.length}',
                style: Styles.blackBoldMedium,
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: unsettledBids == null ? 0 : unsettledBids.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _showBidDialog(unsettledBids.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                    child: InvoiceBidCard(
                      bid: unsettledBids.elementAt(index),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _createOpenOffers() {
    print(
        '\n\n_OfferListsState._createOpenOffers ####################################\n\n');
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total'),
              ),
              Text(
                totalOpenOffers == null
                    ? '0.00'
                    : getFormattedAmount('$totalOpenOffers', context),
                style: Styles.purpleBoldReallyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 4.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Bids'),
              ),
              Text(
                '${openOffers.length}',
                style: Styles.blackBoldMedium,
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: openOffers == null ? 0 : openOffers.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _showOfferDialog(openOffers.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                    child: OfferPanel(
                      offer: openOffers.elementAt(index),
                      number: index + 1,
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _createSettledBids() {
    print(
        '\n\n_OfferListsState._createSettledBids ####################################\n\n');
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total'),
              ),
              Text(
                totalSettled == null
                    ? '0.00'
                    : getFormattedAmount('$totalSettled', context),
                style: Styles.purpleBoldReallyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 4.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Bids'),
              ),
              Text(
                '${settledBids.length}',
                style: Styles.blackBoldMedium,
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: settledBids == null ? 0 : settledBids.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _showBidDialog(settledBids.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                    child: InvoiceBidCard(
                      bid: settledBids.elementAt(index),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Offers and Bids',
            style: Styles.whiteMedium,
          ),
          elevation: 16.0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: Column(
              children: <Widget>[
                Text(
                  investor == null ? '' : '${investor.name}',
                  style: Styles.whiteBoldMedium,
                ),
                TabBar(tabs: [
                  Tab(
                    text: 'Open Bids',
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    text: 'Open Offers',
                    icon: Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    text: 'Settled Bids',
                    icon: Icon(
                      Icons.done_all,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _getData,
            ),
          ],
        ),
        body: TabBarView(children: [
          _createUnsettledBids(),
          _createOpenOffers(),
          _createSettledBids(),
        ]),
      ),
    );
  }

  void _showBidDialog(InvoiceBid bid) {
    print('_OffersAndBidsState._showBidDetail ......${bid.toJson()}');
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
                  onPressed: _ignore,
                  child: Text('NO'),
                ),
                FlatButton(
                  onPressed: _startSettlement,
                  child: Text('YES'),
                ),
              ],
            ));
  }

  Offer offer;

  void _showOfferDialog(Offer offer) async {
    print('_OffersAndBidsState._showOfferDialog ======= \n\n${offer.toJson()}');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking auto trade running',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);

    var isRunning = await ListAPI.checkLatestAutoTradeStart();
    _scaffoldKey.currentState.removeCurrentSnackBar();

    if (isRunning) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Auto trade running. Try again in a few minutes',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    var bids = await ListAPI.getInvoiceBidsByOffer(offer.offerId);
    var t = 0.00;
    bids.forEach((m) {
      t += m.reservePercent;
    });
    print(
        '_OffersAndBidsState._showOfferDialog ------------ percentage bids on offer: $t');
    if (t >= 100.0) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer has been filled. Cannot be bid on',
          textColor: Styles.lightBlue,
          backgroundColor: Styles.black);
      await DataAPI3.closeOffer(offer.offerId);
      _getData();
      return;
    }
    this.offer = offer;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Offer",
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
                        'Do you want to make a Bid on this Offer?',
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
                            getFormattedAmount('${offer.offerAmount}', context),
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
                  onPressed: _ignore,
                  child: Text('NO'),
                ),
                FlatButton(
                  onPressed: _startBid,
                  child: Text('YES'),
                ),
              ],
            ));
  }

  _ignore() {
    Navigator.pop(context);
  }

  _startSettlement() {
    Navigator.pop(context);
  }

  _startBid() async {
    print(
        '\n\n_OffersAndBidsState._startBid ..............................\n\n${offer.toJson()}\n\n');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking auto trade running',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);
    var isRunning = await ListAPI.checkLatestAutoTradeStart();
    _scaffoldKey.currentState.removeCurrentSnackBar();

    if (!isRunning) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvoiceBidder(offer)),
      );
    } else {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Trading system busy. Try in a few minutes',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
  }
}

class InvoiceBidCard extends StatelessWidget {
  final InvoiceBid bid;

  InvoiceBidCard({this.bid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Bid Date', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      bid.date == null
                          ? '0.00'
                          : getFormattedDateLong('${bid.date}', context),
                      style: Styles.blackBoldSmall),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Text('Bid Time', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.date == null
                            ? '0.00'
                            : getFormattedDateHour('${bid.date}'),
                        style: Styles.purpleBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  Text('Type', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.autoTradeOrder == null
                            ? 'Manual Trade'
                            : 'Automatic Trade',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text('Amount', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      bid.amount == null
                          ? '0.00'
                          : getFormattedAmount('${bid.amount}', context),
                      style: Styles.tealBoldLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
