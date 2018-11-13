import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/offers_and_bids.dart';

class SettleInvoiceBid extends StatefulWidget {
  final InvoiceBid invoiceBid;

  SettleInvoiceBid(this.invoiceBid);

  @override
  _SettleInvoiceBid createState() => _SettleInvoiceBid();
}

class _SettleInvoiceBid extends State<SettleInvoiceBid>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String webViewTitle, webViewUrl;
  Offer offer;
  OfferBag offerBag;
  PaymentKey paymentKey;

  @override
  void initState() {
    super.initState();
    _getOffer();
  }

  Future _getOffer() async {
    if (widget.invoiceBid != null) {
      offerBag = await ListAPI.getOfferById(
          widget.invoiceBid.offer.split('#').elementAt(1));
      if (offerBag != null) {
        offerBag.doPrint();
        offer = offerBag.offer;
      }
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
      preferredSize: Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[],
      ),
    );
  }

  Widget _getBody() {
    return Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: InvoiceBidCard(
              bid: widget.invoiceBid,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: RaisedButton(
                elevation: 16.0,
                onPressed: _getPaymentKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Settle',
                    style: Styles.whiteSmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Bid Settlement'),
        bottom: _getBottom(),
      ),
      body: _getBody(),
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }
}
