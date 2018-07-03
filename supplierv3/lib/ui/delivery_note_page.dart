import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
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
  User _user;
  String userName;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    _user = await SharedPrefs.getUser();
    userName = _user.firstName + ' ' + _user.lastName;
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
  @override
  Widget build(BuildContext context) {
    _purchaseOrder = widget.purchaseOrder;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Delivery Note',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: new Column(
            children: <Widget>[
              Text(
                _purchaseOrder.supplierName,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 20.0),
              ),
              new Container(
                child: new Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
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
          child: new Padding(
            padding: const EdgeInsets.only(top: 32.0, bottom: 16.0, left: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Delivery To:',
                  style: styleLabels,
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    _purchaseOrder.purchaserName,
                    style: styleBlue,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 28.0, bottom: 20.0),
                  child: new Row(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Purchase Order:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _purchaseOrder.purchaseOrderNumber,
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: new Row(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'PO Date:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _getFormattedDate(),
                        style: styleBlack,
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: new Row(
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Amount:',
                          style: styleLabels,
                        ),
                      ),
                      Text(
                        _getFormattedAmount(),
                        style: styleTeal,
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: RaisedButton(
                    elevation: 8.0,
                    color: Colors.red.shade300,
                    onPressed: _onSubmit,
                    child: Text(
                      'Submit Delivery Note',
                      style: TextStyle(color: Colors.white),
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
    DataAPI api = new DataAPI(getURL());
    var note = DeliveryNote(
      purchaseOrder: NameSpacePO + _purchaseOrder.purchaseOrderId,
      supplier: _purchaseOrder.supplier,
      supplierName: _purchaseOrder.supplierName,
      user: NameSpaceUser + _user.userId,
      date: new DateTime.now().toIso8601String(),
      purchaseOrderNumber: _purchaseOrder.purchaseOrderNumber,
      customerName: _purchaseOrder.purchaserName,
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
          listener: this,
          icon: Icons.done);
    }
  }

  @override
  onActionPressed(int action) {
    print('_DeliveryNotePageState.onActionPressed ............');
    Navigator.pop(context);
  }
}
