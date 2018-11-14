import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/offers_and_bids.dart';

class SettleInvoiceBid extends StatefulWidget {
  final InvoiceBid invoiceBid;

  SettleInvoiceBid(this.invoiceBid);

  @override
  _SettleInvoiceBid createState() => _SettleInvoiceBid();
}

class _SettleInvoiceBid extends State<SettleInvoiceBid>
    implements SnackBarListener, InvoiceBidListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging fm = FirebaseMessaging();

  String webViewTitle, webViewUrl;
  Offer offer;
  OfferBag offerBag;
  PaymentKey paymentKey;
  double bottomHeight = 20.0;

  @override
  void initState() {
    super.initState();
    _getOffer();
    FCM.configureFCM(invoiceBidListener: this);
  }

  Future _getOffer() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading Offer ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    if (widget.invoiceBid != null) {
      offerBag = await ListAPI.getOfferById(
          widget.invoiceBid.offer.split('#').elementAt(1));
      if (offerBag != null) {
        offerBag.doPrint();
        offer = offerBag.offer;
        fm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + offer.offerId);
        setState(() {
          bottomHeight = 160.0;
        });
        print(
            '_SettleInvoiceBid._getOffer - subscribed to invoiceBid topic for Offer: ${offer.offerId} ');
      }
    }
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
  }

  void _showWebView() {
    //Navigator.of(context).pushNamed('/webview');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BFNWebView(
                title: webViewTitle,
                url: webViewUrl,
              )),
    );
  }

  _getPaymentKey() async {
    var payment = PeachPayment(
//      merchantReference: widget.invoiceBid.investor.split('#').elementAt(1),
      merchantReference: 'OneConnect',
      amount: widget.invoiceBid.amount,
      successURL: getFunctionsURL() + 'peachSuccess',
      cancelUrl: getFunctionsURL() + 'peachCancel',
      errorUrl: getFunctionsURL() + 'peachError',
      notifyUrl: getFunctionsURL() + 'peachNotify',
    );
    paymentKey = await Peach.getPaymentKey(payment: payment);
    if (paymentKey != null) {
      print(
          '\n\n_MyHomePageState._getPaymentKey ########### paymentKey: ${paymentKey.key} ${paymentKey.url}');
      webViewTitle = 'Bank Login';
      webViewUrl = paymentKey.url;
      _showWebView();
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Error starting bank login',
          listener: this,
          actionLabel: 'Close');
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(bottomHeight),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: offerBag == null
            ? Container()
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Invoice Bids:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${offerBag.invoiceBids.length}',
                            style: Styles.whiteBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Offer Amount:',
                          style: Styles.whiteSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${getFormattedAmount('${offerBag.offer.offerAmount}', context)}',
                          style: Styles.whiteBoldMedium,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Bids Made:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            _getTotalBidAmount(),
                            style: Styles.blackBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 16.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: Text(
                            'Offer Expiry:',
                            style: Styles.whiteSmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${getFormattedDate(offerBag.offer.endTime)}',
                            style: Styles.whiteBoldMedium,
                          ),
                        ),
                      ],
                    ),
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
          padding: const EdgeInsets.all(20.0),
          child: InvoiceBidCard(
            bid: widget.invoiceBid,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: RaisedButton(
              elevation: 16.0,
              onPressed: _getPaymentKey,
              color: Colors.pink.shade400,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Settle Invoice Bid',
                  style: Styles.whiteMedium,
                ),
              ),
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
        title: Text('Invoice Bid Settlement'),
        bottom: _getBottom(),
        elevation: 8.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getOffer,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getBody(),
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    print('_SettleInvoiceBid.onInvoiceBidMessage - bid arrived for this offer');
    offerBag.invoiceBids.insert(0, invoiceBid);
    setState(() {});
  }

  String _getTotalBidAmount() {
    var t = 0.0;
    offerBag.invoiceBids.forEach((bid) {
      t += bid.amount;
    });

    return getFormattedAmount('$t', context);
  }
}
