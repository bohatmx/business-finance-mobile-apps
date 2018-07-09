import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/invoice_bid_list.dart';

class InvoiceBidder extends StatefulWidget {
  final Offer offer;

  InvoiceBidder(this.offer);

  @override
  _InvoiceBidderState createState() => _InvoiceBidderState();
}

class _InvoiceBidderState extends State<InvoiceBidder>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  Investor investor;
  Offer offer;
  User user;
  @override
  void initState() {
    super.initState();

    _getCached();
    _buildItems();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    user = await SharedPrefs.getUser();
    setState(() {});
  }

  List<InvoiceBid> bids;
  void _getExistingBids() async {
    bids = await ListAPI.getInvoiceBidsByOffer(offer);
  }

  @override
  Widget build(BuildContext context) {
    offer = widget.offer;
    _getExistingBids();
    prettyPrint(offer.toJson(), '_InvoiceBidderState._build .......OFFER.....');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Make Invoice Bid'),
        elevation: 8.0,
        bottom: _getBottom(),
      ),
      body: _getBody(),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(80.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Column(
          children: <Widget>[
            Text(investor == null ? '' : investor.name,
                style: getTextWhiteSmall()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Existing Bids: ',
                  style: TextStyle(color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    bids == null ? '0' : '${bids.length}',
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
          padding: const EdgeInsets.all(8.0),
          child: OfferCard(
            offer: offer,
            color: Colors.indigo.shade50,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Center(
            child: Text(
              'Invoice Bid Amount',
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Center(
          child: DropdownButton<double>(
            items: items,
            elevation: 8,
            hint: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bid Percentage',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            onChanged: _onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36.0, top: 12.0),
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
          padding: const EdgeInsets.only(left: 36.0, right: 36.0, top: 12.0),
          child: RaisedButton(
            onPressed: _onMakeBid,
            elevation: 8.0,
            color: Colors.pink,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Make Invoice Bid',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double percentage, amount;

  List<DropdownMenuItem<double>> items = List();
  void _buildItems() {
    var item00a = DropdownMenuItem<double>(
      value: 0.5,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '0.5 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item00a);
    //
    var item000 = DropdownMenuItem<double>(
      value: 1.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.indigo,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '1.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item000);
    var item00 = DropdownMenuItem<double>(
      value: 2.5,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.pink,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '2.5 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item00);

    var item0 = DropdownMenuItem<double>(
      value: 5.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.indigo,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '5 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item0);
    //
    var item1 = DropdownMenuItem<double>(
      value: 7.5,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.lime,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '7.5 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item1);
    //
    var item2 = DropdownMenuItem<double>(
      value: 10.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.indigo,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '10.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item2);
    //
    var item3 = DropdownMenuItem<double>(
      value: 15.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.pink,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '15.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item3);
    //
    var item4 = DropdownMenuItem<double>(
      value: 20.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '20.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item4);
    //
    var item5 = DropdownMenuItem<double>(
      value: 25.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.blueGrey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '25.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item5);
    //
    var item6 = DropdownMenuItem<double>(
      value: 30.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.brown,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '30.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item6);
    //
    var item7 = DropdownMenuItem<double>(
      value: 40.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.amber,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '40.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item7);
    //
    var item8 = DropdownMenuItem<double>(
      value: 50.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '50.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item8);
    //
    var item9 = DropdownMenuItem<double>(
      value: 60.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '60.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item9);
    //
    var item10 = DropdownMenuItem<double>(
      value: 70.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.teal,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '70.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item10);
    //
    var item11 = DropdownMenuItem<double>(
      value: 80.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.red,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '80.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item11);
    //
    var item12 = DropdownMenuItem<double>(
      value: 90.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.deepPurple,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '90.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item12);
    //
    var item13 = DropdownMenuItem<double>(
      value: 100.0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.apps,
            color: Colors.lime,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '100.0 %',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
    items.add(item13);
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

  void _onMakeBid() async {
    print('');
    prettyPrint(offer.toJson(), '_InvoiceBidderState._onMakeBid ............');
    InvoiceBid bid = InvoiceBid(
      participantId: investor.participantId,
      user: NameSpace + 'User#' + user.userId,
      reservePercent: '$percentage',
      date: new DateTime.now().toIso8601String(),
      offer: NameSpace + 'Offer#' + offer.offerId,
      investor: NameSpace + 'Investor#' + investor.participantId,
      investorName: investor.name,
      amount: amount,
      discountPercent: offer.discountPercent,
      startTime: offer.startTime,
      endTime: offer.endTime,
    );

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Making invoice bid ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    prettyPrint(bid.toJson(), "invoiceBid about to go : ....");
    var api = DataAPI(getURL());
    var key = await api.makeInvoiceBid(bid, offer);
    if (key == '0') {
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
    }
  }

  @override
  onActionPressed(int action) {
    //Navigator.pop(context);
    Navigator.pop(context, true);
  }
}
