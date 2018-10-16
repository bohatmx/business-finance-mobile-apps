import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/listeners/firestore_listener.dart';

class OfferDetails extends StatefulWidget {
  final String offerId;

  OfferDetails(this.offerId);

  @override
  _OfferDetailsState createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails>
    implements InvoiceBidListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<InvoiceBid> bids = List();
  OfferBag bag;
  Offer offer;
  @override
  void initState() {
    super.initState();
    _getBids();
  }

  _getBids() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading bids ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    bag = await ListAPI.getOfferWithBids(widget.offerId);
    bids = bag.invoiceBids;
    offer = bag.offer;
    _scaffoldKey.currentState.removeCurrentSnackBar();

    setState(() {});
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(260.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  child: Text(
                    'Offer Amount',
                    style: Styles.whiteSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    offer == null
                        ? '0.00'
                        : getFormattedAmount('${offer.offerAmount}', context),
                    style: Styles.whiteBoldReallyLarge,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 0.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Offer Date',
                      style: Styles.whiteSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      offer == null
                          ? ''
                          : getFormattedDateShort('${offer.date}', context),
                      style: Styles.whiteBoldLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      offer == null
                          ? ''
                          : getFormattedDateHour('${offer.date}'),
                      style: Styles.whiteBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Invoice Discount',
                      style: Styles.whiteSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      offer == null ? '' : '${offer.discountPercent} %',
                      style: Styles.whiteBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Invoice Bids',
                    style: Styles.whiteSmall,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                    child: Text(
                      bids == null ? '0' : '${bids.length}',
                      style: Styles.whiteBoldLarge,
                    ),
                  )
                ],
              ),
            ),
            _getHeader(),
          ],
        ),
      ),
    );
  }

  Widget _getHeader() {
    var t = 0.00;
    var p = 0.00;
    if (bids != null) {
      bids.forEach((m) {
        t += m.amount;
        p += m.reservePercent;
      });
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 120.0,
                child: Text(
                  'Total Amount Bid',
                  style: Styles.whiteSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  getFormattedAmount('$t', context),
                  style: Styles.blackBoldMedium,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 12.0, right: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 140.0,
                child: Text(
                  'Total Percentage Bid',
                  style: Styles.whiteSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '$p %',
                  style: Styles.blackBoldMedium,
                ),
              ),
            ],
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
        title: Text('Offer Details'),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            onPressed: _getBids,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: bids == null ? 0 : bids.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              onTap: () {
                _acceptBid(bids.elementAt(index));
              },
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
                child: BidCard(
                  invoiceBid: bids.elementAt(index),
                ),
              ),
            );
          }),
    );
  }

  void _acceptBid(InvoiceBid bid) {
    print('_OfferDetailsState._acceptBid ${bid.toJson()}');
  }

  @override
  onInvoiceBid(InvoiceBid bid) {
    print(
        '_OfferDetailsState.onInvoiceBid ##########################\n ${bid.toJson()}');

    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);

    _getBids();
  }
}

class BidCard extends StatelessWidget {
  final InvoiceBid invoiceBid;

  BidCard({this.invoiceBid});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  getFormattedDateLong('${invoiceBid.date}', context),
                  style: Styles.blackBoldSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    getFormattedDateHour('${invoiceBid.date}'),
                    style: Styles.purpleBoldSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Investor',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${invoiceBid.investorName}',
                      style: Styles.blackBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  child: Text(
                    'Reserved',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${invoiceBid.reservePercent} %',
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Amount',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${invoiceBid.amount}', context),
                      style: Styles.pinkBoldLarge,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Trade Type',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  _getType(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getType() {
    if (invoiceBid.autoTradeOrder != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Auto Trade',
          style: Styles.blueBoldSmall,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Manual Trade',
          style: Styles.blackBoldSmall,
        ),
      );
    }
  }
}
