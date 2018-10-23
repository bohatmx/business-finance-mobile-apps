import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/invoice_bid_list.dart';
import 'package:investor/ui/invoice_due_diligence.dart';

class InvoiceBidder extends StatefulWidget {
  final Offer offer;

  InvoiceBidder(this.offer);

  @override
  _InvoiceBidderState createState() => _InvoiceBidderState();
}

class _InvoiceBidderState extends State<InvoiceBidder>
    implements SnackBarListener, FCMListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  DateTime startTime, endTime;
  Investor investor;
  Offer offer;
  User user;
  Wallet wallet;
  @override
  void initState() {
    super.initState();
    print(
        '_InvoiceBidderState.initState ==================================>>>');
    _getCached();
    _getExistingBids();
    configureMessaging(this);
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    user = await SharedPrefs.getUser();
    wallet = await SharedPrefs.getWallet();
    setState(() {});
  }

  List<InvoiceBid> bids;
  void _getExistingBids() async {
    prettyPrint(offer.toJson(),
        '_InvoiceBidderState._getExistingBids ...... for this OFFER.....');
    bids = await ListAPI.getInvoiceBidsByOffer(offer.offerId);
    _calculateTotal();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (offer == null) {
      offer = widget.offer;
      _getExistingBids();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Make Invoice Bid'),
        elevation: 8.0,
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _getExistingBids),
        ],
      ),
      body: _getBody(),
    );
  }

  double totalAmtBid = 0.00;
  double totalPercBid = 0.00;

  _calculateTotal() {
    totalAmtBid = 0.00;
    totalPercBid = 0.00;
    bids.forEach((m) {
      totalAmtBid += m.amount;
      totalPercBid += m.reservePercent;
    });
    _buildPercChoices();
    setState(() {});
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(150.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Bids for Offer: ',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                      child: Text(
                        bids == null ? '0' : '${bids.length}',
                        style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Perc:',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.0),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 10.0),
                            child: Text(
                              totalPercBid == null ? '0 %' : '$totalPercBid %',
                              style: TextStyle(
                                  color: Colors.indigo.shade800,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Total Amount Bid: ',
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    totalAmtBid == null
                        ? '0.00'
                        : '${getFormattedAmount('$totalAmtBid', context)}',
                    style: TextStyle(
                        color: Colors.indigo.shade800,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: OfferCard(
            offer: offer,
            color: Colors.indigo.shade50,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Invoice Due Diligence',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.pink,
                  ),
                  onPressed: _onSearch,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: DropdownButton<double>(
            items: items,
            elevation: 8,
            hint: Text(
              'Bid Percentage',
              style: TextStyle(fontSize: 16.0),
            ),
            onChanged: _onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36.0, top: 0.0),
          child: Row(
            children: <Widget>[
              Text(
                percentage == null ? '0.0 %' : '$percentage %',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  amount == null
                      ? '0.00'
                      : getFormattedAmount('$amount', context),
                  style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade300),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 4.0),
          child: RaisedButton(
            onPressed: _onSubmitBid,
            elevation: 8.0,
            color: Colors.pink,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Make Invoice Bid',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double percentage, amount;

  List<DropdownMenuItem<double>> items = List();
  void _buildPercChoices() {
    items.clear();
    var maxPerc = 100.0 - totalPercBid;
    print('_InvoiceBidderState._buildPercChoices maxPerc: $maxPerc');
    double count = 0.0;
    double val = 0.0;
    if (maxPerc > 0) {
      for (var i = 0; i < 9; i++) {
        val += 0.1;
        var m = DropdownMenuItem<double>(
          value: double.parse(val.toStringAsFixed(1)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${val.toStringAsFixed(1)} %',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
        );
        items.add(m);
      }
    }

    while (maxPerc > 0) {
      maxPerc -= 1.0;
      count++;
      var m = DropdownMenuItem<double>(
        value: count,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$count %',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
            ),
          ],
        ),
      );
      items.add(m);
    }
  }

  void _onChanged(double value) {
    percentage = value;
    print('_InvoiceBidderState._onChanged: percentage: $percentage');

    setState(() {
      amount = (percentage / 100.00) * offer.offerAmount;
    });
    print('_InvoiceBidderState._onChanged, amount: $amount');
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';

  void _onSubmitBid() async {
    var bids = await ListAPI.getInvoiceBidsByOffer(offer.offerId);
    var t = 0.00;
    bids.forEach((m) {
      t += m.reservePercent;
    });
    print(
        '_OffersAndBidsState._showOfferDialog ------------ percentage bids on offer: $t %');

    ///check if offer is 100 % reserved
    if (t >= 100.0) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Offer has been filled. Cannot be bid on',
        listener: this,
        actionLabel: '',
      );
      return;
    }

    ///check if bid goes over 100 %
    if ((t + percentage) > 100.0) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Cannot make bid. Percentage required is too much',
        listener: this,
        actionLabel: '',
      );
      return;
    }

    ///check if bid percentage is not more than remaining portion unreserved
    if (percentage > (100.0 - t)) {
      AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Cannot make bid. Percentage required is not availale',
        listener: this,
        actionLabel: '',
      );
      return;
    }
    //todo - check investor limits if profile exists
    //todo - check invoice limits if profile exists

    //todo - check investor account balance

    prettyPrint(offer.toJson(),
        '_InvoiceBidderState._onMakeBid ...........everything checks out. Making a bid:');
    InvoiceBid bid = InvoiceBid(
        user: NameSpace + 'User#' + user.userId,
        reservePercent: percentage,
        date: getUTCDate(),
        offer: NameSpace + 'Offer#' + offer.offerId,
        investor: NameSpace + 'Investor#' + investor.participantId,
        investorName: investor.name,
        amount: amount,
        discountPercent: offer.discountPercent,
        startTime: offer.startTime,
        endTime: offer.endTime,
        wallet: NameSpace + 'Wallet#${wallet.stellarPublicKey}',
        isSettled: false,
        supplierId: offer.supplierDocumentRef);

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Making invoice bid ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    try {
      var resultBid = await DataAPI3.makeInvoiceBid(bid);
      if (resultBid == null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice Bid failed',
            listener: this,
            actionLabel: 'CLOSE');
      } else {
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice Bid successful',
            textColor: Colors.white,
            backgroundColor: Colors.black,
            actionLabel: 'OK',
            listener: this,
            icon: Icons.done_all,
            action: 0);

        _getExistingBids();
      }
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Bid failed',
          listener: this,
          actionLabel: 'CLOSE');
    }
  }

  @override
  onActionPressed(int action) {
    //Navigator.pop(context);
    Navigator.pop(context, true);
  }

  void _onSearch() {
    print('_InvoiceBidderState._onSearch ================= ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new InvoiceDueDiligence(offer)),
    );
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print('_InvoiceBidderState.onInvoiceBidMessage invoiceBid arrived');

    if (invoiceBid.offer ==
        'resource:com.oneconnect.biz.Offer#${offer.offerId}') {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message:
              'Invoice bid made on this offer by someone else\nbid perc: ${invoiceBid.reservePercent} amt: ${invoiceBid.amount}',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      _getExistingBids();
    }
  }
}
