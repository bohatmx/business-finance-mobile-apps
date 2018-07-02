import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/invoice_bidder.dart';

class InvoiceBidList extends StatefulWidget {
  @override
  _InvoiceBidListState createState() => _InvoiceBidListState();
}

class _InvoiceBidListState extends State<InvoiceBidList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  List<InvoiceBid> bids = List();
  Investor investor;
  Offer offer;
  @override
  void initState() {
    super.initState();

    _getBids();
    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    setState(() {});
  }

  void _getBids() async {
    print('_InvoiceBidListState._getOffers');
    if (endTime == null) {
      endTime = DateTime.now();
      startTime = endTime.subtract(Duration(days: 10));
    }
    bids = await ListAPI.getInvoiceBidsByInvestor(investor.participantId);
    print('_InvoiceBidListState._getOffers offers in period: ${bids.length}');
    setState(() {});
    bids.forEach((off) {
      prettyPrint(off.toJson(), 'InvoiceBid:');
    });
  }

  _showMenuDialog(Offer offer) {
    this.offer = offer;
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
                height: 300.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        '${offer.supplierName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                            bottom: 20.0,
                          ),
                          child: Text(
                            'Amount:',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 12.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Text(
                            '$offer.offerAmount}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                    _buildItems(),
                  ],
                ),
              ),
            ));
  }

  Widget _buildItems() {
    var item1 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onInvoiceBid,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.attach_money,
                color: Colors.green.shade800,
              ),
            ),
            Text('Make Invoice Bid'),
          ],
        ),
      ),
    );
    var item2 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _cancelBid,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.cancel,
                color: Colors.red.shade800,
              ),
            ),
            Text('Cancel Invoice Bid'),
          ],
        ),
      ),
    );
    var item3 = Card(
      elevation: 4.0,
      child: InkWell(
        onTap: _onOfferDetails,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.description,
                color: Colors.blue.shade800,
              ),
            ),
            Text('Check Invoice Details'),
          ],
        ),
      ),
    );

    return Column(
      children: <Widget>[
        item1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Bids'),
        bottom: PreferredSize(
            child: _getBottom(), preferredSize: Size.fromHeight(50.0)),
      ),
      body: Column(),
    );
  }

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
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Open Invoice Bids',
                  style: getTextWhiteSmall(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    bids == null ? '' : '${bids.length}',
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

  void _onInvoiceBid() {
    print('_InvoiceBidListState._onInvoiceBid');
    Navigator.pop(context);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceBidder(offer)),
    );
  }

  void _cancelBid() {
    print('_InvoiceBidListState._cancelBid');
  }

  void _onOfferDetails() {
    print('_InvoiceBidListState._onOfferDetails');
  }
}

class OfferCard extends StatelessWidget {
  final Offer offer;
  final Color color;

  OfferCard({this.offer, this.color});
  var boldStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  var amtStyle = TextStyle(
    color: Colors.teal,
    fontSize: 24.0,
    fontWeight: FontWeight.w900,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 70.0, child: Text('Supplier')),
                  Text(
                      offer.supplierName == null
                          ? 'Unknown yet'
                          : offer.supplierName,
                      style: boldStyle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 70.0, child: Text('Customer')),
                  Text(
                      offer.customerName == null
                          ? 'Unknown yet'
                          : offer.customerName,
                      style: boldStyle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 70.0, child: Text('Start')),
                  Text(
                      offer.startTime == null
                          ? 'Unknown yet'
                          : getFormattedLongestDate(offer.startTime),
                      style:
                          TextStyle(fontSize: 14.0, color: Colors.deepPurple)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 70.0, child: Text('End')),
                  Text(
                      offer.endTime == null
                          ? 'Unknown yet'
                          : getFormattedLongestDate(offer.endTime),
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
                        : '${offer.offerAmount}',
                    style: amtStyle,
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
