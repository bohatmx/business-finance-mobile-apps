import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/invoice_bidder.dart';

class OfferList extends StatefulWidget {
  static _OfferListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_OfferListState>());
  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  List<Offer> offers = List();

  List<Offer> openOffers = List();
  List<Offer> closedOffers = List();

  Investor investor;
  Offer offer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _buildDaysDropDownItems();
    _getOffers();
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    setState(() {});
  }

  void _getOffers() async {
    print('_OfferListState._getOffers .......................');
    endTime = DateTime.now();
    startTime = endTime.subtract(Duration(days: _days));

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  Offers ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    offers = await ListAPI.getOffersByPeriod(startTime, endTime);
    openOffers.clear();
    closedOffers.clear();

    offers.forEach((p) {
      if (p.isOpen == true) {
        openOffers.add(p);
      } else {
        closedOffers.add(p);
      }
    });
    print(
        '_OfferListState._getOffers offers in period: ${offers.length}  over $_days days');
    text = 'OPEN';
    switchOpen = true;
    setState(() {});
    _scaffoldKey.currentState.hideCurrentSnackBar();
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
        message: 'Checking bid ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    var xx = await ListAPI.getInvoiceBidByInvestorOffer(offer, investor);
    if (xx.isEmpty) {
      _showDetailsDialog(offer);
    } else {
      prettyPrint(
          xx.first.toJson(), '########### INVOICE BID for investtor/offer');
      _showMoreBidsDialog();
    }
//    _scaffoldKey.currentState.hideCurrentSnackBar();
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

  _showDetailsDialog(Offer offer) {
    this.offer = offer;
    prettyPrint(offer.toJson(), 'Offer selected %%%%%%%%:');
    if (offer.isOpen == false) {
      print(
          '_OfferListState._showDetailsDialog offer.isOpen == false ... ignore ===============> ');
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
                "Offer Actions",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 200.0,
                child: OfferListCard(
                  offer: offer,
                  color: Colors.grey.shade50,
                ),
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

  int _getCount() {
    if (switchOpen) {
      return openOffers.length;
    } else {
      return closedOffers.length;
    }
  }

//  Widget _buildItems() {
//    var item1 = Card(
//      elevation: 4.0,
//      child: InkWell(
//        onTap: _onInvoiceBid,
//        child: Row(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Icon(
//                Icons.attach_money,
//                color: Colors.green.shade800,
//              ),
//            ),
//            Text('Make Invoice Bid'),
//          ],
//        ),
//      ),
//    );
//    var item2 = Card(
//      elevation: 4.0,
//      child: InkWell(
//        onTap: _cancelBid,
//        child: Row(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Icon(
//                Icons.cancel,
//                color: Colors.red.shade800,
//              ),
//            ),
//            Text('Cancel Invoice Bid'),
//          ],
//        ),
//      ),
//    );
//    var item3 = Card(
//      elevation: 4.0,
//      child: InkWell(
//        onTap: _onOfferDetails,
//        child: Row(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Icon(
//                Icons.description,
//                color: Colors.blue.shade800,
//              ),
//            ),
//            Text('Check Invoice Details'),
//          ],
//        ),
//      ),
//    );
//
//    return Column(
//      children: <Widget>[
//        item1,
//        item2,
//        item3,
//        Padding(
//          padding: const EdgeInsets.only(top: 16.0),
//          child: FlatButton(
//            onPressed: () {
//              Navigator.pop(context);
//            },
//            child: Text(
//              'Cancel',
//              style: TextStyle(color: Colors.blue, fontSize: 20.0),
//            ),
//          ),
//        ),
//      ],
//    );
//  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Offers'),
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(140.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: _getCount(),
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              onTap: () {
                if (switchOpen) {
                  _checkBid(openOffers.elementAt(index));
                } else {
                  _checkBid(closedOffers.elementAt(index));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: OfferPanel(
                  offer: _getOffer(index),
                  number: index + 1,
                ),
              ),
            );
          }),
      backgroundColor: Colors.indigo.shade50,
    );
  }

  Offer _getOffer(int index) {
    if (switchOpen) {
      return openOffers.elementAt(index);
    } else {
      return closedOffers.elementAt(index);
    }
  }

  String _getTotal() {
    if (switchOpen) {
      return '${openOffers.length}';
    } else {
      return '${closedOffers.length}';
    }
  }

  List<DropdownMenuItem<int>> items = List();
  int _days = 60;
  Widget _getBottom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 20.0),
      child: Column(
        children: <Widget>[
          Text(
            investor == null ? '' : investor.name,
            style: getTitleTextWhite(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Invoice Offers',
                  style: getTextWhiteSmall(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    _getTotal(),
                    style: getTitleTextWhite(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                DropdownButton<int>(
                  items: items,
                  value: _days,
                  onChanged: _daysSelected,
                  hint: Text(
                    'Period in Review',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Text(text),
                    ),
                    Switch(value: switchOpen, onChanged: _onSwitchChanged),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String text = 'OPEN';
  bool switchOpen = true;
  void _onNoPressed() {
    print('_OfferListState._onNoPressed');
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
    print(
        '_OfferListState._onInvoiceBidRequired back from Bidder, refresh: $refresh');
    if (refresh) {
      _getOffers();
    }
  }

  void _refresh() {
    _getOffers();
  }

  void _daysSelected(int value) {
    print('############# _OfferListState._daysSelected : $value');
    _days = value;
    _getOffers();
  }

  void _onSwitchChanged(bool value) {
    print('_OfferListState._onSwitchChanged $value');
    if (value) {
      text = 'OPEN';
      switchOpen = true;
    } else {
      text = 'CLOSED';
      switchOpen = false;
    }
    setState(() {});
  }
}

class OfferListCard extends StatelessWidget {
  final Offer offer;
  final Color color;

  OfferListCard({this.offer, this.color});
  final boldStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  final amtStyle = TextStyle(
    color: Colors.teal,
    fontSize: 18.0,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) {
    print('OfferListCard.build');
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
                offer.supplierName == null ? 'Unknown yet' : offer.supplierName,
                style: boldStyle),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(width: 30.0, child: Text('For')),
              Text(
                  offer.customerName == null
                      ? 'Unknown yet'
                      : offer.customerName,
                  style: boldStyle),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 20.0),
          child: Row(
            children: <Widget>[
              Container(width: 40.0, child: Text('Start')),
              Text(
                  offer.startTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.startTime),
                  style: TextStyle(fontSize: 14.0, color: Colors.deepPurple)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(width: 40.0, child: Text('End')),
              Text(
                  offer.endTime == null
                      ? 'Unknown yet'
                      : getFormattedDate(offer.endTime),
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(width: 70.0, child: Text('Amount')),
              Text(
                offer.offerAmount == null
                    ? 'Unknown yet'
                    : getFormattedAmount('${offer.offerAmount}', context),
                style: amtStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OfferPanel extends StatelessWidget {
  final Offer offer;
  final int number;
  Color color, amountColor;
  double elevation = 4.0;

  OfferPanel({this.offer, this.number});

  TextStyle getTextStyle() {
    if (offer.dateClosed == null) {
      return TextStyle(
          color: Colors.teal, fontSize: 20.0, fontWeight: FontWeight.bold);
    } else {
      return TextStyle(
          color: Colors.pink, fontSize: 14.0, fontWeight: FontWeight.normal);
    }
  }

  Widget getStatus() {
    if (offer.isOpen) {
      color = Colors.white;
      return Text(
        'Open',
        style: Styles.blackBoldSmall,
      );
    } else {
      color = Colors.grey.shade600;
      return Text(
        'Closed',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offer.isOpen) {
      color = Colors.white;
      amountColor = Colors.teal.shade700;
      elevation = 4.0;
    } else {
      color = Colors.grey.shade300;
      amountColor = Colors.blueGrey.shade300;
      elevation = 2.0;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Card(
        elevation: elevation,
        color: color == null ? Colors.white : color,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 60.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: getStatus(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                      getFormattedDateHour(offer.date),
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${offer.offerAmount}', context),
                      style: TextStyle(
                          color: amountColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Supplier',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      offer.supplierName == null ? '' : offer.supplierName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 4.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Customer',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      offer.customerName == null ? '' : offer.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal),
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
