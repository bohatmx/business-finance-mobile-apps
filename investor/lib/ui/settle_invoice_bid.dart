import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
  bool isBusy = false;
  User user;
  Investor investor;

  @override
  void initState() {
    super.initState();
    _getCache();
    _getOffer();
    FCM.configureFCM(context: context, invoiceBidListener: this);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_NOTIFY);
  }

  void _getCache() async {
    user = await SharedPrefs.getUser();
    investor = await SharedPrefs.getInvestor();
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
          _opacity = 1.0;
          isChecking = false;
        });
        print(
            '_SettleInvoiceBid._getOffer - subscribed to invoiceBid topic for Offer: ${offer.offerId} ');
      }
    }
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
  }

  void _showWebView() async {
    if (isBusy) {
      print('_SettleInvoiceBid._showWebView isBusy $isBusy');
      return;
    }
    isBusy = true;
    try {
      int result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BFNWebView(
                  title: webViewTitle,
                  url: webViewUrl,
                )),
      );
      switch (result) {
        case PeachSuccess:
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Payment successful\nWait for payment registration',
              textColor: Styles.white,
              backgroundColor: Colors.indigo.shade300,
              actionLabel: 'Wait',
              listener: this,
              icon: Icons.done_all,
              action: 2);
          setState(() {
            _opacity = 0.0;
          });
          _writeSettlement();
          break;
        case PeachCancel:
          isBusy = false;
          AppSnackbar.showSnackbarWithAction(
              scaffoldKey: _scaffoldKey,
              message: 'Payment cancelled',
              textColor: Styles.white,
              backgroundColor: Colors.blueGrey.shade500,
              actionLabel: 'OK',
              listener: this,
              icon: Icons.clear,
              action: PeachCancel);
          break;
        case PeachError:
          isBusy = false;
          AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'There was an error making the payment',
            actionLabel: 'Close',
            listener: this,
          );
          break;
      }
    } catch (e) {
      print(e);
      print('_SettleInvoiceBid._showWebView --- webview FUCKED!');
    }
  }

  _getPaymentKey() async {
    if (isBusy) {
      return;
    }
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

  bool isChecking;
  double _opacity = 0.0;
  static const int Exit = 1;
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
          padding: const EdgeInsets.only(left: 20.0),
          child: isChecking == null
              ? Text(
                  'Checking Bid. Please wait ...',
                  style: Styles.blackBoldMedium,
                )
              : Container(),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Opacity(
              opacity: _opacity,
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
    print('_SettleInvoiceBid.onActionPressed action: $action');
    switch (action) {
      case PeachSuccess:
        Navigator.pop(context);
        break;
      case PeachCancel:
        break;
      case PeachError:
        break;
      case Exit:
        _scaffoldKey.currentState.removeCurrentSnackBar();
        print('_SettleInvoiceBid.onActionPressed about to pop .....');
        Navigator.pop(context, true);
        print('_SettleInvoiceBid.onActionPressed about to pop AGAIN?.....');
        Navigator.pop(context, true);
        break;
      case 2:
        break;
      default:
        break;
    }
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

  Future _writeSettlement() async {
    print('_SettleInvoiceBid._writeSettlement .............................');
    var m = InvestorInvoiceSettlement(
        amount: widget.invoiceBid.amount,
        investor: widget.invoiceBid.investor,
        user: NameSpace + 'User#${user.userId}',
        peachPaymentKey: paymentKey.key,
        offer: widget.invoiceBid.offer,
        date: getUTCDate(),
        invoiceBid: NameSpace + 'InvoiceBid#${widget.invoiceBid.invoiceBidId}');

    try {
      var result = await DataAPI3.makeInvestorInvoiceSettlement(m);
      print(
          '\n\n_SettleInvoiceBid.onPeachNotify ####### SETTLEMENT registered on BFN and Firestore: ${result.toJson()}');
      await _removeBidFromCache();
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Payment registered',
          textColor: Styles.white,
          backgroundColor: Colors.teal,
          actionLabel: 'Done',
          listener: this,
          icon: Icons.done,
          action: Exit);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Error registering payment',
          listener: this,
          actionLabel: 'Close');
    }
  }

  Future _removeBidFromCache() async {
    var bids = await Database.getInvoiceBids();
    List<InvoiceBid> list = List();
    bids.forEach((b) {
      if (b.invoiceBidId != widget.invoiceBid.invoiceBidId) {
        list.add(b);
      }
    });
    print(
        '_SettleInvoiceBid._removeBidFromCache bids in cache: ${list.length}');
    await Database.saveInvoiceBids(InvoiceBids(list));
    return null;
  }
}
