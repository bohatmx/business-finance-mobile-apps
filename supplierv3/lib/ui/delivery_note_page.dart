import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryNotePage extends StatefulWidget {
  final PurchaseOrder purchaseOrder;

  DeliveryNotePage(this.purchaseOrder);

  @override
  _DeliveryNotePageState createState() => _DeliveryNotePageState();
}

class _DeliveryNotePageState extends State<DeliveryNotePage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PurchaseOrder _purchaseOrder;
  List<PurchaseOrder> _purchaseOrders;
  User _user;
  String userName;
  Supplier supplier;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    _user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    userName = _user.firstName + ' ' + _user.lastName;

    _getPurchaseOrders();
  }

  _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading  purchase orders',
        textColor: Colors.lightBlue,
        backgroundColor: Colors.black);
    _purchaseOrders = await ListAPI.getPurchaseOrders(
        supplier.documentReference, 'suppliers');
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    setState(() {});
  }

  var styleLabels = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  var styleBlack = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  var styleBlue = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w900,
    color: Colors.blue.shade700,
  );
  var styleTeal = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.w900,
    color: Colors.teal.shade700,
  );

  List<DropdownMenuItem<PurchaseOrder>> items = List();
  Widget _getPOList() {
    if (_purchaseOrders == null) {
      return Container();
    }
    ;
    items.clear();
    _purchaseOrders.forEach((po) {
      var item6 = DropdownMenuItem<PurchaseOrder>(
        value: po,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.blue,
              ),
            ),
            Text('${po.purchaseOrderNumber} - ${po.amount}'),
          ],
        ),
      );
      items.add(item6);
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<PurchaseOrder>(
        items: items,
        onChanged: _onPOpicked,
        elevation: 8,
        hint: Text(
          'Purchase Orders',
          style: TextStyle(fontSize: 20.0, color: Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.purchaseOrder != null) {
      _purchaseOrder = widget.purchaseOrder;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Create Delivery Note',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: new Column(
            children: <Widget>[
              Text(
                _purchaseOrder == null ? '' : _purchaseOrder.supplierName,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              new Container(
                child: new Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, top: 10.0),
                  child: Text(
                    userName == null ? '' : userName,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 14.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 20.0),
            child: ListView(
              children: <Widget>[
                _getPOList(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text(
                    _purchaseOrder == null ? '' : _purchaseOrder.purchaserName,
                    style: styleBlack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Purchase Order:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null
                            ? ''
                            : _purchaseOrder.purchaseOrderNumber,
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'PO Date:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null ? '' : _getFormattedDate(),
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'PO Amount:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder == null ? '0.00' : _getFormattedAmount(),
                        style: styleTeal,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: TextField(
                    onChanged: _onAmountChanged,
                    maxLength: 20,
                    style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Delivery Note Amount',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 20.0)),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Delivery Note VAT',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        vat == null ? '0.00' : getFormattedAmount(vat, context),
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    right: 20.0,
                  ),
                  child: RaisedButton(
                    elevation: 8.0,
                    color: Colors.purple.shade500,
                    onPressed: _onSubmit,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Submit Delivery Note',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    DateTime d = DateTime.parse(_purchaseOrder.date);
    var format = new DateFormat.yMMMd();
    return format.format(d);
  }

  String _getFormattedAmount() {
    final oCcy = new NumberFormat("#,##0.00", "en_ZA");
    double m = _purchaseOrder.amount;
    return oCcy.format(m);
  }

  static const NameSpaceDelNote = 'resource:com.oneconnect.biz.DeliveryNote#';
  static const NameSpaceUser = 'resource:com.oneconnect.biz.User#';
  static const NameSpacePO = 'resource:com.oneconnect.biz.PurchaseOrder#';
  void _onSubmit() async {
    print('_DeliveryNotePageState._onSubmit');
    if (amount == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Missing amount',
          listener: this,
          actionLabel: 'Fix');
      return;
    }
    DataAPI api = new DataAPI(getURL());
    var note = DeliveryNote(
      purchaseOrder: NameSpacePO + _purchaseOrder.purchaseOrderId,
      supplier: _purchaseOrder.supplier,
      supplierName: _purchaseOrder.supplierName,
      user: NameSpaceUser + _user.userId,
      date: new DateTime.now().toIso8601String(),
      purchaseOrderNumber: _purchaseOrder.purchaseOrderNumber,
      customerName: _purchaseOrder.purchaserName,
      amount: double.parse(amount),
      vat: double.parse(vat),
      totalAmount: double.parse(totalAmount),
    );
    if (_purchaseOrder.govtEntity != null) {
      note.govtEntity = _purchaseOrder.govtEntity;
    }
    if (_purchaseOrder.company != null) {
      note.company = _purchaseOrder.company;
    }
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Delivery Note ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    String key = await api.registerDeliveryNote(note);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    print('_DeliveryNotePageState._onSubmit ........ back. key: $key');
    if (key == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Note submission failed',
          listener: this,
          actionLabel: 'Close');
    } else {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Note submitted',
          textColor: Colors.white,
          backgroundColor: Colors.teal.shade800,
          actionLabel: 'DONE',
          action: 0,
          listener: this,
          icon: Icons.done);
      isDone = true;
    }
  }

  bool isDone = false;
  @override
  onActionPressed(int action) {
    print('_DeliveryNotePageState.onActionPressed ............');
    Navigator.pop(context, isDone);
  }

  void _onPOpicked(PurchaseOrder value) {
    print('_DeliveryNotePageState._onPOpicked: ');
    prettyPrint(value.toJson(), '_DeliveryNotePageState._onPOpicked: ');
    _purchaseOrder = value;
    setState(() {});
  }

  String amount, vat, totalAmount;

  void _onAmountChanged(String value) {
    print('_DeliveryNotePageState._amtChanged: $value');
    amount = value;
    //todo - internatioonalize
    double amt = double.parse(amount);
    double xvat = amt * 0.15;
    double tot = amt + xvat;
    vat = xvat.toString();
    totalAmount = tot.toString();
    setState(() {});
    print(
        '_DeliveryNotePageState._onAmountChanged vat: $vat tottal: $totalAmount');
  }
}
