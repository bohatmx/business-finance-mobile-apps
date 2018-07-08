import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class MakeOfferPage extends StatefulWidget {
  final Invoice invoice;

  MakeOfferPage(this.invoice);

  @override
  _MakeOfferPageState createState() => _MakeOfferPageState();
}

class _MakeOfferPageState extends State<MakeOfferPage>
    implements SnackBarListener {
  static const NameSpace = 'resource:com.oneconnect.biz.';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Invoice invoice;
  Supplier supplier;
  PurchaseOrder purchaseOrder;
  User user;
  String discount;
  DateTime startTime = DateTime.now(),
      initialDate = DateTime.now().add(Duration(seconds: 365)),
      endTime = DateTime.now().add(Duration(days: 365));
  int days;
  List<DropdownMenuItem<String>> items = List();
  List<String> discountStrings = List();
  String supplierAmount, investorAmount;
  @override
  initState() {
    super.initState();
    _setItems();
    _getSupplier();
  }

  _getSupplier() async {
    supplier = await SharedPrefs.getSupplier();
    user = await SharedPrefs.getUser();
  }

  void _setItems() {
    print('_MakeOfferPageState._setItems ................');

    var item = DropdownMenuItem<String>(
      value: '5.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.grey,
            ),
          ),
          Text('5.0 %'),
        ],
      ),
    );
    items.add(item);

    var item1 = DropdownMenuItem<String>(
      value: '7.5',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.indigo.shade300,
            ),
          ),
          Text('7.5 %'),
        ],
      ),
    );
    items.add(item1);

    var item2 = DropdownMenuItem<String>(
      value: '10',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.indigo.shade300,
            ),
          ),
          Text('10.0 %'),
        ],
      ),
    );
    items.add(item2);

    var item3 = DropdownMenuItem<String>(
      value: '12.5',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.blue,
            ),
          ),
          Text('12.5 %'),
        ],
      ),
    );
    items.add(item3);

    var item4 = DropdownMenuItem<String>(
      value: '15.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.blue,
            ),
          ),
          Text('15.0 %'),
        ],
      ),
    );
    items.add(item4);

    var item5 = DropdownMenuItem<String>(
      value: '17.5',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.blue,
            ),
          ),
          Text('17.5 %'),
        ],
      ),
    );
    items.add(item5);

    var item6 = DropdownMenuItem<String>(
      value: '20.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.blue,
            ),
          ),
          Text('20.0 %'),
        ],
      ),
    );
    items.add(item6);

    var item7 = DropdownMenuItem<String>(
      value: '25.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.purple,
            ),
          ),
          Text('25.0 %'),
        ],
      ),
    );
    items.add(item7);

    var item8 = DropdownMenuItem<String>(
      value: '30.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.purple,
            ),
          ),
          Text('30.0 %'),
        ],
      ),
    );
    items.add(item8);

    var item9 = DropdownMenuItem<String>(
      value: '35.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('35.0 %'),
        ],
      ),
    );
    items.add(item9);

    var item10 = DropdownMenuItem<String>(
      value: '40.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('40.0 %'),
        ],
      ),
    );
    items.add(item10);

    var item11 = DropdownMenuItem<String>(
      value: '50.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('50.0 %'),
        ],
      ),
    );
    items.add(item11);

    var item12 = DropdownMenuItem<String>(
      value: '60.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('60.0 %'),
        ],
      ),
    );
    items.add(item12);
  }

  _getStartTime() async {
    startTime = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );
    _calculateDays();
    setState(() {});
  }

  var style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  _getEndTime() async {
    endTime = await showDatePicker(
      context: context,
      firstDate: new DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );
    _calculateDays();
    setState(() {});
  }

  _calculateDays() {
    if (startTime != null && endTime != null) {
      var dur = endTime.difference(startTime);
      days = dur.inDays;
      setState(() {});
    }
  }

  _calculateExpected() {
    if (discount != null) {
      double offerDiscount = double.parse(discount);
      double investorDiscount = offerDiscount;

      double offerAmt = invoice.amount;
      double supplierAmt = (offerAmt * (100.0 - investorDiscount)) / 100;
      print('MakeOffer._calculateExpected amt: '
          ' $offerAmt offerDiscount: $offerDiscount investorDiscount: '
          '$investorDiscount supplierAmt: $supplierAmt investorAmt: ${offerAmt - supplierAmt} check: ${supplierAmt + (offerAmt - supplierAmt)}\n\n');

      setState(() {
        investorAmount = '${offerAmt - supplierAmt}';
        supplierAmount = '$supplierAmt';
      });
    }
  }

  _submitOffer() async {
    print(
        'MakeOfferPage._submitOffer ########### invoice: ${invoice.invoiceNumber} --------------\n\n');
    var disc = double.parse(discount);
    var offerAmt = (invoice.amount * disc) / 100.0;
    Offer offer = new Offer(
        supplier: NameSpace + 'Supplier#' + supplier.participantId,
        invoice: NameSpace + 'Invoice#' + invoice.invoiceId,
        user: NameSpace + 'User#' + user.userId,
        purchaseOrder: invoice.purchaseOrder,
        offerAmount: offerAmt,
        invoiceAmount: invoice.amount,
        discountPercent: disc,
        startTime: new DateTime.now().toIso8601String(),
        endTime:
            new DateTime.now().add(new Duration(days: 14)).toIso8601String(),
        date: new DateTime.now().toIso8601String(),
        participantId: supplier.participantId,
        privateSectorType: supplier.privateSectorType);

    print(
        '_MakeOfferPageState._submitOffer about to open snackbar ===================>');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Invoice Offer',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    DataAPI dataAPI = DataAPI(getURL());
    var key = await dataAPI.makeOffer(offer);
    if (key == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Offer failed',
          listener: this,
          actionLabel: 'Close');
    } else {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Ivoice Offer suubmitted OK',
          textColor: Colors.white,
          backgroundColor: Colors.teal.shade800,
          actionLabel: "DONE",
          listener: this,
          action: 0,
          icon: Icons.done);
    }
  }

  @override
  Widget build(BuildContext context) {
    invoice = widget.invoice;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Make Invoice Offer'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, left: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        invoice.customerName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w900),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.done,
                            color: Colors.white,
                          ),
                          onPressed: _submitOffer,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            preferredSize: Size.fromHeight(40.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Invoice Offer Details',
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w900),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Container(
                      width: 110.0,
                      child: RaisedButton(
                        onPressed: _getStartTime,
                        elevation: 4.0,
                        color: Colors.blue,
                        child: Text(
                          'Start Date',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      startTime == null
                          ? ''
                          : getFormattedDate(startTime.toIso8601String()),
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 28.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 110.0,
                      child: RaisedButton(
                        onPressed: _getEndTime,
                        color: Colors.pink,
                        child: Text(
                          'End Date',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        endTime == null
                            ? ''
                            : getFormattedDate(endTime.toIso8601String()),
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 80.0, top: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      days == null ? '0' : '$days',
                      style: TextStyle(
                          fontSize: 60.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 8.0),
                      child: Text(
                        'Days',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Number')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        invoice.invoiceNumber,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Amount')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '${invoice.amount}',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: Row(
                  children: <Widget>[
                    Container(width: 120.0, child: Text('Invoice Date')),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        getFormattedDate(invoice.date),
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 20.0),
                      child: DropdownButton<String>(
                        items: items,
                        onChanged: _onDiscountTapped,
                        elevation: 16,
                        hint: Text(
                          'Select Discount',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      discount == null ? '' : discount,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 36.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '%',
                        style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 140.0, child: Text('Expected Amount')),
                    ),
                    Text(
                      supplierAmount == null
                          ? '0.00'
                          : getFormattedAmount(supplierAmount, context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 140.0, child: Text('Investor(s) Amount')),
                    ),
                    Text(
                      investorAmount == null
                          ? '0.00'
                          : getFormattedAmount(investorAmount, context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDiscountTapped(String value) {
    print('_MakeOfferPageState._onDiscountTapped value: $value');
    discount = value;
    _calculateExpected();
  }

  @override
  onActionPressed(int action) {
    print('_MakeOfferPageState.onActionPressed');
    Navigator.pop(context);
  }
}
