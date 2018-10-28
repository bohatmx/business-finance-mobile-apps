import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
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

class _OfferListState extends State<OfferList>
    with WidgetsBindingObserver
    implements PagerListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  List<Offer> offers = List();

  List<Offer> openOffers = List();
  List<Offer> closedOffers = List();

  Investor investor;
  Offer offer;
  int currentStartKey, previousStartKey;
  OpenOfferSummary summary = OpenOfferSummary();
  List<int> keys = List();
  KeyItems keyItems = KeyItems();
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _buildDaysDropDownItems();

    _getCached();
    _getPageLimit();
    _getOffers(false);
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    setState(() {});
  }

  void _getPageLimit() async {
    setState(() {});
  }

  void _getOffers(bool isBackPressed) async {
    print('\n\n\n_OfferListState._getOffers .......................');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  Offers ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    setState(() {
      _opacity = 1.0;
    });

    if (numberOfOffers == null) {
      numberOfOffers = await SharedPrefs.getPageLimit();
    }
    print('_OfferListState._getOffers ## ...currentStartKey: $currentStartKey');
    summary = await ListAPI.getOpenOffersWithPaging(
        lastDate: currentStartKey, pageLimit: numberOfOffers);
    if (!isBackPressed) {
      var item = KeyItem(currentIndex, currentStartKey);
      keyItems.addItem(item);
      keyItems.doPrint();
      print(
          '\n\n_getOffers #######  currentIndex: $currentIndex currentStartKey: $currentStartKey');
      keys.add(currentStartKey);
    }
    openOffers = summary.offers;
    if (openOffers != null) {
      if (openOffers.isNotEmpty) {
        previousStartKey = currentStartKey;
        openOffers.forEach((o) {
          currentStartKey = o.intDate;
        });
      }
    } else {
      print('_OfferListState._getOffers ... ERROR');
    }
    setState(() {
      _opacity = 0.0;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Open Invoice Offers',
          style: Styles.whiteSmall,
        ),
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(160.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: openOffers == null ? 0 : openOffers.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              onTap: () {
                _checkBid(openOffers.elementAt(index));
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
    if (openOffers == null) {
      return null;
    }
    return openOffers.elementAt(index);
  }

  List<DropdownMenuItem<int>> items = List();
  int currentIndex = 0;

  Widget _getBottom() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0, left: 8.0, right: 8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: Text(
              investor == null ? '' : investor.name,
              style: getTitleTextWhite(),
            ),
          ),
          Pager(this),
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
                Text(
                  'Invoice Offers',
                  style: getTextWhiteSmall(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    openOffers == null ? '0' : '${openOffers.length}',
                    style: getTitleTextWhite(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String text = 'OPEN';
  int numberOfOffers;

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
    //print
//        '_OfferListState._onInvoiceBidRequired back from Bidder, refresh: $refresh');
    if (refresh) {
      _getOffers(false);
    }
  }

  void _refresh() {
    _getOffers(false);
  }

  @override
  onEvent(int action, int numberOfOffers) {
    this.numberOfOffers = numberOfOffers;
    print(
        '\n\nonEvent ********** currentIndex: $currentIndex currentStartKey: $currentStartKey');
    switch (action) {
      case Pager.Back:
        currentIndex--;
        if (currentIndex < 0) {
          currentStartKey = null;
        } else {
          if (currentIndex < keyItems.items.length) {
            currentStartKey = keyItems.items.elementAt(currentIndex).startKey;
          } else {
            currentStartKey = null;
          }
        }
        print(
            'onEvent; -------------- BACK pressed: currentStartKey: $currentStartKey');
        _getOffers(true);
        break;
      case Pager.Next:
        currentIndex++;
        if (currentIndex < keyItems.items.length) {
          currentStartKey = keyItems.items.elementAt(currentIndex).startKey;
        }
        print(
            'onEvent; +++++++++++ NEXT pressed: currentStartKey: $currentStartKey');
        _getOffers(false);
        break;
    }
  }

  @override
  onPrompt() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Press Back or Next icon',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);
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
    double width = 60.0;
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
                    width: width,
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
                    Flexible(
                      child: Container(
                        child: Text(
                          offer.supplierName == null ? '' : offer.supplierName,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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
                    Flexible(
                      child: Container(
                        child: Text(
                          offer.customerName == null ? '' : offer.customerName,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal),
                        ),
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
}

abstract class PagerListener {
  onEvent(int action, int numberOfOffers);
  onPrompt();
}

class Pager extends StatefulWidget {
  final PagerListener listener;
  static const Back = 1, Next = 2;
  Pager(this.listener);

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  static const numbers = [2, 10, 20, 30, 40, 50, 60, 70, 80, 100];
  final List<DropdownMenuItem<int>> items = List();
  void _buildItems() {
    numbers.forEach((num) {
      var item = DropdownMenuItem<int>(
        value: num,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Text('$num'),
          ],
        ),
      );
      items.add(item);
    });
  }

  void _forwardPressed() {
    print('Pager._forwardPressed');
    widget.listener.onEvent(Pager.Next, number);
  }

  void _rewindPressed() {
    print('Pager._rewindPressed');
    widget.listener.onEvent(Pager.Back, number);
  }

  int number = 10;
  void _onNumber(int value) async {
    print('Pager._onNumber value: $value');
    SharedPrefs.savePageLimit(value);
    setState(() {
      number = value;
    });
    widget.listener.onPrompt();
  }

  @override
  void initState() {
    super.initState();
    _buildItems();
    _setPageLimit();
  }

  void _setPageLimit() async {
    number = await SharedPrefs.getPageLimit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  DropdownButton<int>(
                    items: items,
                    hint: Text('Offers'),
                    onChanged: _onNumber,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                    child: Text(
                      '$number',
                      style: Styles.pinkBoldSmall,
                    ),
                  ),
                  InkWell(
                      onTap: _rewindPressed,
                      child: Text('Back', style: Styles.blackBoldSmall)),
                  IconButton(
                    icon: Icon(
                      Icons.fast_rewind,
                      color: Colors.indigo,
                      size: 36.0,
                    ),
                    onPressed: _rewindPressed,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: InkWell(
                        onTap: _forwardPressed,
                        child: Text('Next', style: Styles.blackBoldSmall)),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.fast_forward,
                      color: Colors.teal,
                      size: 36.0,
                    ),
                    onPressed: _forwardPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeyItem {
  final int index;
  final int startKey;

  KeyItem(this.index, this.startKey);
}

class KeyItems {
  final List<KeyItem> items = List();

  void addItem(KeyItem item) {
//    items.add(item);
    var isFound = false;
    items.forEach((i) {
      if (i.startKey == item.startKey) {
        isFound = true;
      }
    });
    if (!isFound) {
      items.add(item);
    }
  }

  doPrint() {
    print('\n\n################################################');
    items.forEach((i) {
      print('keyItem:index: ${i.index} startKey: ${i.startKey}');
    });
    print('################################################\n\n');
  }
}
