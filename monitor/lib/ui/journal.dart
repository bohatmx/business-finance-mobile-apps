import 'dart:collection';

import 'package:businesslibrary/api/auto_trade.dart';
import 'package:businesslibrary/api/file_util.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class JournalPage extends StatefulWidget {
  final List<InvoiceBid> bids;
  final List<ExecutionUnit> units;

  JournalPage({this.bids, this.units});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double totalBidAmount = 0.00;
  double totalInvalidAmount = 0.00;
  int totalBids = 0;
  int totalInvalids = 0;
  List<InvoiceBid> bids;
  List<ExecutionUnit> units;
  @override
  initState() {
    super.initState();
    // _getData();
  }

  _getData() async {
    bids = await FileUtil.getInvoiceBids();
    units = await FileUtil.getExecutionUnits();

    _calcInvalids();
    setState(() {});
  }

  Widget _getBidView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text('Total Amount'),
              ),
              Text(
                totalBidAmount == null
                    ? '0.00'
                    : getFormattedAmount('$totalBidAmount', context),
                style: Styles.purpleBoldLarge,
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
                '${bids.length}',
                style: Styles.blackBoldMedium,
              ),
            ],
          ),
        ),
        new Flexible(
          child: new ListView.builder(
              itemCount: bids == null ? 0 : bids.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    _showBidDetail(bids.elementAt(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                    child: InvoiceBidCard(
                      bid: bids.elementAt(index),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _getInvalidView() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 0.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('Total Amount'),
                ),
                Text(
                  totalInvalidAmount == null
                      ? '0.00'
                      : getFormattedAmount('$totalInvalidAmount', context),
                  style: Styles.pinkBoldLarge,
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
                  '${units.length}',
                  style: Styles.blueBoldMedium,
                ),
              ],
            ),
          ),
          new Flexible(
            child: new ListView.builder(
                itemCount: units == null ? 0 : units.length,
                itemBuilder: (BuildContext context, int index) {
                  return new GestureDetector(
                    onTap: () {
                      _showInvalidDetail(units.elementAt(index));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                      child: ExecUnitCard(
                        unit: units.elementAt(index),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _calcInvalids() {
    var map = HashMap<String, Offer>();
    units.forEach((m) {
      map['${m.offer.offerId}'] = m.offer;
    });
    totalInvalidAmount = 0.00;
    totalBidAmount = 0.00;

    map.forEach((key, off) {
      totalInvalidAmount += off.offerAmount;
    });
    bids.forEach((m) {
      totalBidAmount += m.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    bids = widget.bids;
    units = widget.units;
    _calcInvalids();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Trade Session Monitor',
            style: Styles.whiteBoldMedium,
          ),
          elevation: 16.0,
          bottom: TabBar(tabs: [
            Tab(
              text: 'Bids Executed',
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
            Tab(
              text: 'Invalid Trades',
              icon: Icon(
                Icons.clear,
                color: Colors.red.shade900,
              ),
            ),
          ]),
        ),
        body: TabBarView(children: [
          _getBidView(),
          _getInvalidView(),
        ]),
      ),
    );
  }

  void _showBidDetail(InvoiceBid elementAt) {}

  void _showInvalidDetail(ExecutionUnit elementAt) {}
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
                      style: Styles.blueBoldSmall),
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
                  Text('Investor', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(bid.investorName,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 20.0,
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
                      style: Styles.tealBoldMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExecUnitCard extends StatelessWidget {
  final ExecutionUnit unit;

  ExecUnitCard({this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(' Date', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      unit.date == null
                          ? getFormattedDateShort(
                              DateTime.now().toIso8601String(), context)
                          : getFormattedDateShort('${unit.date}', context),
                      style: Styles.blueMedium),
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
                        unit.date == null
                            ? '0.00'
                            : getFormattedDateHour('${unit.date}'),
                        style: Styles.purpleBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: <Widget>[
                  Text('Investor', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(unit.profile.name,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 20.0)),
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
                      unit.offer.offerAmount == null
                          ? '0.00'
                          : getFormattedAmount(
                              '${unit.offer.offerAmount}', context),
                      style: Styles.blackBoldMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
