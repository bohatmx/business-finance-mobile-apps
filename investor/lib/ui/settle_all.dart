import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:businesslibrary/util/webview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:investor/app_model.dart';
import 'package:investor/ui/dashboard.dart';
import 'package:scoped_model/scoped_model.dart';

class SettleAll extends StatefulWidget {
  final InvestorAppModel model;

  SettleAll({this.model});

  @override
  _SettleAllState createState() => _SettleAllState();
}

class _SettleAllState extends State<SettleAll> implements SnackBarListener, PeachNotifyListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<InvoiceBid> bids = List();
  double totalBidAmount = 0.00;
  double avgDiscount = 0.0;
  PaymentKey paymentKey;
  String webViewTitle, webViewUrl;
  bool isBusy = false;
  Investor investor;
  User user;
  @override
  void initState() {
    super.initState();
    _getCache();
  }

  void _getCache() async {
    investor = await SharedPrefs.getInvestor();
    user = await SharedPrefs.getUser();

    FCM.configureFCM(peachNotifyListener: this);
    FirebaseMessaging fm = FirebaseMessaging();
    fm.subscribeToTopic(FCM.TOPIC_PEACH_NOTIFY);
  }

  void _showWebView() async {
    setState(() {
      _opacity = 0.0;
    });
    try {
      int result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BFNWebView(
                title: webViewTitle,
                url: webViewUrl,
              ),
        ),
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
          setState(() {
            _opacity = 1.0;
          });
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
      setState(() {
        _opacity = 1.0;
      });
    }
  }

  _getPaymentKey() async {
    //Navigator.pop(context);
    var payment = PeachPayment(
//      merchantReference: bid.investor.split('#').elementAt(1),
      merchantReference: 'OneConnect',
      amount: totalBidAmount,
      successURL: getFunctionsURL() + 'peachSuccess',
      cancelUrl: getFunctionsURL() + 'peachCancel',
      errorUrl: getFunctionsURL() + 'peachError',
      notifyUrl: getFunctionsURL() + 'peachNotify',
    );
    try {
      paymentKey = await Peach.getPaymentKey(payment: payment);
      if (paymentKey != null) {
        print(
            '\n\n_SettleAllState._getPaymentKey ########### paymentKey: ${paymentKey.key} ${paymentKey.url}');
        webViewTitle = 'Bank Login';
        webViewUrl = paymentKey.url;
        isBusy = false;
        _showWebView();
      } else {
        isBusy = false;
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Error starting bank login',
            listener: this,
            actionLabel: 'Close');
      }
    } catch (e) {
      isBusy = false;
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: '$e',
          listener: this,
          actionLabel: 'Close');
    }
  }

  void _calculate() {
    if (bids == null) return;
    totalBidAmount = 0.0;
    var totPerc = 0.0;
    bids.forEach((b) {
      totalBidAmount += b.amount;
      totPerc += b.discountPercent;
    });
    avgDiscount = totPerc / bids.length;
    print(
        '_SettleAllState._calculate totalBidAmount: $totalBidAmount avgDiscount: $avgDiscount');
  }

  double _opacity = 1.0;

  bool refreshModel = false;
  Future _writeSettlement(PeachNotification notif) async {
    print('_SettleInvoiceBid._writeSettlement .............................');
    AppSnackbar.showSnackbarWithProgressIndicator(
      scaffoldKey: _scaffoldKey,
      message: 'Registering payments on BFN',
      textColor: Styles.white,
      backgroundColor: Colors.black,
    );
    int count = 0;
    var w = await SharedPrefs.getWallet();
    for (var bid in bids) {
      var m = InvestorInvoiceSettlement(
          amount: bid.amount,
          investor: bid.investor,
          user: NameSpace + 'User#${user.userId}',
          peachPaymentKey: paymentKey.key,
          offer: bid.offer,
          supplier: bid.supplier,
          customer: bid.customer,
          customerName: bid.customerName,
          supplierName: bid.supplierName,
          investorName: investor.name,
          peachTransactionId: notif.callpay_transaction_id,
          date: getUTCDate(),
          invoiceBid: NameSpace + 'InvoiceBid#${bid.invoiceBidId}');
      if (w != null) {
        m.wallet = NameSpace + 'Wallet#${w.stellarPublicKey}';
      }
      try {
        await DataAPI3.makeInvestorInvoiceSettlement(m);
        count++;
        print('\n\n###### SETTLEMENT registered on BFN and Firestore: RESULT: #$count');
        await widget.model.processSettledBid(bid);
        print(
            '\n_SettleAllState._writeSettlement - registered $count payments. removeBidFromCache');
        AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message:
              'Payment registered, amount: ${getFormattedAmount('${bid.amount}', context)} #: $count',
          textColor: Styles.white,
          backgroundColor: Colors.teal,
        );
      } catch (e) {
        print('\n\n_SettleAllState._writeSettlement : ERROR: \n $e');
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Error registering payment',
            listener: this,
            actionLabel: 'Close');
      }
    }
  }

  void _confirmDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Invoice Bid Settlement",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 80.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to settle all these ${bids.length} Invoice Bids?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Amount:',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 12.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ),
                          child: Text(
                            getFormattedAmount('$totalBidAmount', context),
                            style: Styles.tealBoldMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('NO'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _getPaymentKey();
                  },
                  child: Text('YES'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ScopedModelDescendant<InvestorAppModel>(
        builder: (context, _, model) {
          if (model.unsettledInvoiceBids != null) {
            print('\n_SettleAllState.build bids: ${model.unsettledInvoiceBids.length}');
          }
          if (refreshModel) {
            model.refreshModel();
          }
          bids = model.unsettledInvoiceBids;
          _calculate();
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Settle All Bids'),
              leading: IconButton(icon: Icon(Icons.apps, color: Colors.white,), onPressed: null),
              bottom: _getBottom(),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.help, color: Colors.white,), onPressed: null),
              ],
            ),
            body: _getBody(),
            backgroundColor: Colors.brown.shade100,
          );
        },
      ),
    );
  }

  String text =
      'The totals below represent the total amount of invoice bids made by you or by the BFN Network. A single payment will be made for all outstanding bids.';
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Consolidated Invoice Bids',
                  style: Styles.whiteBoldMedium,
                ),
                Opacity(
                  opacity: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Container(
                      height: 16.0,
                      width: 16.0,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Payment',
                          style: Styles.blackBoldLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            child: Container(
                                child: Text(
                          text,
                          style: Styles.blackBoldSmall,
                          overflow: TextOverflow.clip,
                        )))
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        child: Text(
                          'Total Bids:',
                          style: Styles.greyLabelSmall,
                        ),
                      ),
                      Text(
                        bids == null
                            ? ''
                            : '${getFormattedNumber(bids.length, context)}',
                        style: Styles.blackBoldMedium,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120.0,
                          child: Text(
                            'Avg Discount:',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Text(
                          avgDiscount == null
                              ? '0.0%'
                              : '${avgDiscount.toStringAsFixed(2)} %',
                          style: Styles.purpleBoldMedium,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 80.0,
                          child: Text(
                            'Amount:',
                            style: Styles.greyLabelSmall,
                          ),
                        ),
                        Text(
                          '${getFormattedAmount('$totalBidAmount', context)}',
                          style: Styles.tealBoldLarge,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: Opacity(
                      opacity: _opacity,
                      child: RaisedButton(
                        elevation: 8.0,
                        color: Colors.pink,
                        onPressed: _confirmDialog,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Settle All Bids',
                            style: Styles.whiteSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: Styles.greyLabelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }

  @override
  onPeachNotify(PeachNotification notification) {

    _writeSettlement(notification);
    return null;
  }
}
