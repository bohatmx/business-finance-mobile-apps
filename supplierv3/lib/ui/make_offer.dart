import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/file_util.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class MakeOfferPage extends StatefulWidget {
  final Invoice invoice;

  MakeOfferPage(this.invoice);
  static _MakeOfferPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_MakeOfferPageState>());

  @override
  _MakeOfferPageState createState() => _MakeOfferPageState();
}

class _MakeOfferPageState extends State<MakeOfferPage>
    implements SnackBarListener {
  static const NameSpace = 'resource:com.oneconnect.biz.';
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Invoice invoice;
  Supplier supplier;
  PurchaseOrder purchaseOrder;
  User user;
  String percentage;
  DateTime startTime = DateTime.now(),
      initialDate = DateTime.now().add(Duration(seconds: 365)),
      endTime = DateTime.now().add(Duration(days: 14));
  int days;
  List<DropdownMenuItem<String>> items = List();
  List<String> discountStrings = List();
  String supplierAmount, investorAmount;
  Wallet wallet;
  Sector sector;
  List<Sector> sectors = List();
  @override
  initState() {
    super.initState();
    _setItems();
    _getSupplier();
    _calculateDays();
    _getSectors();
  }

  _getSectors() async {
    sectors = await FileUtil.getSector();
    setState(() {});
    if (sectors == null) {
      sectors = await ListAPI.getSectors();
      if (sectors.isNotEmpty) {
        await FileUtil.saveSectors(Sectors(sectors));
        setState(() {});
      }
    }
  }

  List<DropdownMenuItem<Sector>> sectorItems = List();
  Widget _buildDropDown() {
    if (sectors == null || sectors.isEmpty) {
      return Container();
    }
    sectors.forEach((s) {
      var item = DropdownMenuItem<Sector>(
        value: s,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.blue,
              ),
            ),
            Text('${s.sectorName}'),
          ],
        ),
      );
      sectorItems.add(item);
    });
    return DropdownButton(
        items: sectorItems,
        hint: Text(
          'Select Customer Sector',
          style: Styles.whiteBoldMedium,
        ),
        onChanged: _onSector);
  }

  _getSupplier() async {
    supplier = await SharedPrefs.getSupplier();
    user = await SharedPrefs.getUser();
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
    if (percentage != null) {
      double offerPercentage = double.parse(percentage);
      offerPercentage = 100.0 - offerPercentage;

      double offerAmt = invoice.totalAmount * (offerPercentage / 100);

      setState(() {
        investorAmount = '$offerAmt';
      });
    }
  }

  bool submitting = false;
  _submitOffer() async {
    print(
        'MakeOfferPage._submitOffer ########### invoice: ${invoice.invoiceNumber} --------------\n\n');
    if (submitting) {
      return;
    }
    if (sector == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select Customer Sector',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (percentage == null || percentage == 0) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select Offer Percentage',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    submitting = true;
    var disc = double.parse(percentage);

    var offerAmt = (invoice.totalAmount * (100.0 - disc)) / 100.0;
    wallet = await SharedPrefs.getWallet();
    Offer offer = new Offer(
        supplier: NameSpace + 'Supplier#' + supplier.participantId,
        invoice: NameSpace + 'Invoice#' + invoice.invoiceId,
        user: NameSpace + 'User#' + user.userId,
        purchaseOrder: invoice.purchaseOrder,
        offerAmount: offerAmt,
        invoiceAmount: invoice.totalAmount,
        discountPercent: disc,
        startTime: new DateTime.now().toIso8601String(),
        endTime:
            new DateTime.now().add(new Duration(days: days)).toIso8601String(),
        date: new DateTime.now().toIso8601String(),
        participantId: supplier.participantId,
        customerName: invoice.customerName,
        wallet: NameSpace + 'Wallet#${wallet.stellarPublicKey}',
        supplierDocumentRef: supplier.documentReference,
        supplierName: supplier.name,
        invoiceDocumentRef: invoice.documentReference,
        sector: NameSpace + 'Sector#${sector.sectorId}',
        sectorName: sector.sectorName);

    print(
        '_MakeOfferPageState._submitOffer about to open snackbar ===================>');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Invoice Offer',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var x = await ListAPI.findOfferByInvoice(offer.invoice);
    if (x != null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Offer already exists',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    DataAPI dataAPI = DataAPI(getURL());
    var key = await dataAPI.makeOffer(offer);
    if (key == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Invoice Offer failed',
          listener: this,
          actionLabel: 'Close');
      submitting = false;
    } else {
      needRefresh = true;
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Ivoice Offer suubmitted OK',
          textColor: Colors.white,
          backgroundColor: Colors.teal.shade800,
          actionLabel: "DONE",
          listener: this,
          action: OfferSubmitted,
          icon: Icons.done);
    }
  }

  static const OfferSubmitted = 1;
  bool needRefresh = false;
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
                _buildDropDown(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    sector == null ? '' : sector.sectorName,
                    style: Styles.whiteBoldLarge,
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(80.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: ListView(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, bottom: 8.0, top: 8.0),
                child: Text(
                  invoice.customerName,
                  style: Styles.greyLabelMedium,
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
                        elevation: 4.0,
                        color: Colors.teal.shade800,
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
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.purple.shade700),
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
                        getFormattedAmount('${invoice.totalAmount}', context),
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
                padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                      child: DropdownButton<String>(
                        items: items,
                        onChanged: _onDiscountTapped,
                        elevation: 16,
                        hint: Text(
                          'Invoice Discount',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      percentage == null ? '' : percentage,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 28.0,
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
                      child:
                          Container(width: 80.0, child: Text('Offer Amount')),
                    ),
                    Text(
                      investorAmount == null
                          ? '0.00'
                          : getFormattedAmount(investorAmount, context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 28.0, bottom: 28.0),
                  child: Opacity(
                    opacity: submitting == true ? 0.0 : 1.0,
                    child: RaisedButton(
                      elevation: 8.0,
                      onPressed: _submitOffer,
                      color: Colors.indigo.shade300,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit Offer',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ),
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
    percentage = value;
    _calculateExpected();
  }

  @override
  onActionPressed(int action) {
    print('_MakeOfferPageState.onActionPressed');
    Navigator.pop(context, needRefresh);
  }

  void _onSector(Sector value) {
    sector = value;
    setState(() {});
  }

  void _setItems() {
    print('_MakeOfferPageState._setItems ................');

    var item6 = DropdownMenuItem<String>(
      value: '1.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.blue,
            ),
          ),
          Text('1.0 %'),
        ],
      ),
    );
    items.add(item6);

    var item7 = DropdownMenuItem<String>(
      value: '2.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.purple,
            ),
          ),
          Text('2.0 %'),
        ],
      ),
    );
    items.add(item7);

    var item8 = DropdownMenuItem<String>(
      value: '3.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.purple,
            ),
          ),
          Text('3.0 %'),
        ],
      ),
    );
    items.add(item8);

    var item9 = DropdownMenuItem<String>(
      value: '4.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('4.0 %'),
        ],
      ),
    );
    items.add(item9);

    var item10 = DropdownMenuItem<String>(
      value: '5.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('5.0 %'),
        ],
      ),
    );
    items.add(item10);

    var item11 = DropdownMenuItem<String>(
      value: '6.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('6.0 %'),
        ],
      ),
    );
    items.add(item11);

    var item12 = DropdownMenuItem<String>(
      value: '7.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('7.0 %'),
        ],
      ),
    );
    items.add(item12);

    var item13 = DropdownMenuItem<String>(
      value: '8.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('8.0 %'),
        ],
      ),
    );
    items.add(item13);

    var item14 = DropdownMenuItem<String>(
      value: '9.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('9.0 %'),
        ],
      ),
    );
    items.add(item14);
    var item15 = DropdownMenuItem<String>(
      value: '10.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('10.0 %'),
        ],
      ),
    );
    items.add(item15);
    var item16 = DropdownMenuItem<String>(
      value: '11.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('11.0 %'),
        ],
      ),
    );
    items.add(item16);
    var item17 = DropdownMenuItem<String>(
      value: '12.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('12.0 %'),
        ],
      ),
    );
    items.add(item17);
    var item18 = DropdownMenuItem<String>(
      value: '13.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('13.0 %'),
        ],
      ),
    );
    items.add(item18);
    var item19 = DropdownMenuItem<String>(
      value: '14.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('14.0 %'),
        ],
      ),
    );
    items.add(item19);
    var x1 = DropdownMenuItem<String>(
      value: '15.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('15.0 %'),
        ],
      ),
    );
    items.add(x1);
    var x2 = DropdownMenuItem<String>(
      value: '16.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('16.0 %'),
        ],
      ),
    );
    items.add(x2);
    var x3 = DropdownMenuItem<String>(
      value: '17.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('17.0 %'),
        ],
      ),
    );
    items.add(x3);
    var x4 = DropdownMenuItem<String>(
      value: '18.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('18.0 %'),
        ],
      ),
    );
    items.add(x4);
    var x5 = DropdownMenuItem<String>(
      value: '19.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('19.0 %'),
        ],
      ),
    );
    items.add(x5);
    var x6 = DropdownMenuItem<String>(
      value: '20.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('20.0 %'),
        ],
      ),
    );
    items.add(x6);
    var x7 = DropdownMenuItem<String>(
      value: '21.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('21.0 %'),
        ],
      ),
    );
    items.add(x7);
    var x8 = DropdownMenuItem<String>(
      value: '22.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('22.0 %'),
        ],
      ),
    );
    items.add(x8);
    var x9 = DropdownMenuItem<String>(
      value: '23.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('23.0 %'),
        ],
      ),
    );
    items.add(x9);
    var z1 = DropdownMenuItem<String>(
      value: '24.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('24.0 %'),
        ],
      ),
    );
    items.add(z1);
    var z2 = DropdownMenuItem<String>(
      value: '25.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('25.0 %'),
        ],
      ),
    );
    items.add(z2);
    var z3 = DropdownMenuItem<String>(
      value: '26.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('26.0 %'),
        ],
      ),
    );
    items.add(z3);
    var z4 = DropdownMenuItem<String>(
      value: '27.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('27.0 %'),
        ],
      ),
    );
    items.add(z4);
    var z5 = DropdownMenuItem<String>(
      value: '28.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('28.0 %'),
        ],
      ),
    );
    items.add(z5);
    var z6 = DropdownMenuItem<String>(
      value: '29.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('29.0 %'),
        ],
      ),
    );
    items.add(z6);
    var z7 = DropdownMenuItem<String>(
      value: '30.0',
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.apps,
              color: Colors.red,
            ),
          ),
          Text('30.0 %'),
        ],
      ),
    );
    items.add(z7);
  }
}
