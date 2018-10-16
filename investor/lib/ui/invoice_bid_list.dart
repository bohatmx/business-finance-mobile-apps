import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

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
      endTime = DateTime.now().toUtc();
      startTime = endTime.subtract(Duration(days: 10));
    }
    bids = await ListAPI.getInvoiceBidsByInvestor(investor.participantId);
    print('_InvoiceBidListState._getOffers offers in period: ${bids.length}');
    setState(() {});
    bids.forEach((off) {
      prettyPrint(off.toJson(), 'InvoiceBid:');
    });
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
}

class OfferCard extends StatelessWidget {
  final Offer offer;
  final Color color;

  OfferCard({this.offer, this.color});
  final boldStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );
  final amtStyle = TextStyle(
    color: Colors.teal,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
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
                  Container(
                      width: 80.0,
                      child: Text(
                        'Supplier',
                        style: Styles.greyLabelSmall,
                      )),
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
                  Container(
                      width: 80.0,
                      child: Text(
                        'For',
                        style: Styles.greyLabelSmall,
                      )),
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
                  Container(
                      width: 60.0,
                      child: Text(
                        'Start',
                        style: Styles.greyLabelSmall,
                      )),
                  Text(
                      offer.startTime == null
                          ? 'Unknown yet'
                          : getFormattedDateLong(offer.startTime, context),
                      style:
                          TextStyle(fontSize: 14.0, color: Colors.deepPurple)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                          : getFormattedDateLong(offer.endTime, context),
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.pink.shade800,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 80.0,
                      child: Text(
                        'Amount',
                        style: Styles.greyLabelSmall,
                      )),
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
        ),
      ),
    );
  }
}
