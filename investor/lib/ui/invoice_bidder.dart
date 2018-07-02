import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class InvoiceBidder extends StatefulWidget {
  final Offer offer;

  InvoiceBidder(this.offer);

  @override
  _InvoiceBidderState createState() => _InvoiceBidderState();
}

class _InvoiceBidderState extends State<InvoiceBidder> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime startTime, endTime;
  Investor investor;
  Offer offer;
  @override
  void initState() {
    super.initState();

    _getCached();
  }

  void _getCached() async {
    investor = await SharedPrefs.getInvestor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    offer = widget.offer;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Make Invoice Bid'),
        elevation: 8.0,
        bottom: _getBottom(),
      ),
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Column(
          children: <Widget>[
            Text(investor == null ? '' : investor.name,
                style: getTextWhiteSmall()),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                offer == null ? '' : offer.supplierName,
                style: getTitleTextWhite(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
