import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';

class PurchaseOrderPageGovt extends StatefulWidget {
  final String url;

  PurchaseOrderPageGovt(this.url);

  @override
  _PurchaseOrderPageState createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPageGovt>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  PurchaseOrder purchaseOrder = PurchaseOrder();
  User user;
  GovtEntity govtEntity;
  Company company;
  Supplier supplier;
  String poNumber, amount;

  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
  }

  _getSupplier() async {
    supplier = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SupplierSelectorPage()),
    );
    if (supplier == null) {
      AppSnackbar.showErrorSnackbar(
          listener: this,
          scaffoldKey: _scaffoldKey,
          message: 'No supplier found',
          actionLabel: 'Close');
    }
    print('_PurchaseOrderPageState._getSupplier ${supplier.toJson()}');
    setState(() {});
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    if (user != null) {
      userName = user.firstName + ' ' + user.lastName;
    }
    govtEntity = await SharedPrefs.getGovEntity();
    if (govtEntity != null) {
      name = govtEntity.name;
    }
    company = await SharedPrefs.getCompany();
    if (company != null) {
      name = company.name;
    }
    setState(() {});
  }

  _registerPurchaseOrder() async {
    print('_PurchaseOrderPageState._registerPurchaseOrder .........');
    Navigator.pop(context);
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (govtEntity != null) {
        purchaseOrder.govtEntity =
            'com.oneconnect.biz.GovtEntity#' + govtEntity.participantId;
        purchaseOrder.govtDocumentRef = govtEntity.documentReference;
        purchaseOrder.purchaserName = govtEntity.name;
        label = 'Govt';
      }
      if (company != null) {
        purchaseOrder.company =
            'com.oneconnect.biz.Company#' + company.participantId;
        purchaseOrder.companyDocumentRef = company.documentReference;
        purchaseOrder.purchaserName = company.name;
        label = 'Company';
      }
      if (supplier != null) {
        purchaseOrder.supplierDocumentRef = supplier.documentReference;
        purchaseOrder.supplier =
            'com.oneconnect.biz.Supplier#' + supplier.participantId;
        purchaseOrder.supplierName = supplier.name;
      }
      if (user != null) {
        purchaseOrder.user = 'com.oneconnect.biz.User#' + user.userId;
      }
      print('_PurchaseOrderPageState._registerPurchaseOrder ... ${purchaseOrder
              .toJson()}');
      purchaseOrder.date = new DateTime.now().toIso8601String();
      purchaseOrder.amount = amount;
      purchaseOrder.purchaseOrderNumber = poNumber;

      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Registering purchase order',
          textColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700);
      DataAPI api = DataAPI(widget.url);
      var key = await api.registerPurchaseOrder(purchaseOrder);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (key == '0') {
        AppSnackbar.showErrorSnackbar(
            listener: this,
            scaffoldKey: _scaffoldKey,
            message: 'Error submitting purchase order',
            actionLabel: 'close');
      } else {
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Purchase Order registered',
            textColor: Colors.white,
            backgroundColor: Colors.teal.shade700);
      }
    }
  }

  _confirm() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Confirm Purchase Order"),
              content: new Text("Do you want to submit this Purchase Order?"),
              actions: <Widget>[
                FlatButton(
                  onPressed: _cancel,
                  child: Text(
                    'NO',
                    style: style,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _registerPurchaseOrder,
                    child: Text(
                      'YES',
                      style: style,
                    ),
                  ),
                ),
              ],
            ));
  }

  var style = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    fontSize: 16.0,
  );
  var style2 = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16.0,
  );
  var style3 = TextStyle(
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontSize: 12.0,
  );
  var name, userName, label = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('$label Purchase Order'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Column(
            children: <Widget>[
              Text(
                name == null ? '' : name,
                style: style2,
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  userName == null ? '' : userName,
                  style: style3,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 14.0, bottom: 10.0),
                      child: new Opacity(
                        opacity: 0.4,
                        child: Text(
                          'Purchase Order Details',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 0.0, top: 28.0),
                          child: RaisedButton(
                            onPressed: _getSupplier,
                            elevation: 2.0,
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              'Get Supplier',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Text(
                            supplier == null ? '' : supplier.name,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Purchase Order Number',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter PO number';
                        }
                      },
                      onSaved: (val) => poNumber = val,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the amount';
                        }
                      },
                      onSaved: (val) => amount = val,
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 28.0, right: 20.0, top: 30.0),
                      child: RaisedButton(
                        elevation: 8.0,
                        color: Theme.of(context).accentColor,
                        onPressed: _confirm,
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Submit Purchase Order',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _cancel() {
    print('_PurchaseOrderPageState._cancel CANCELLED confirm');
  }

  @override
  onActionPressed() {
    print('_PurchaseOrderPageState.onActionPressed .......... Yay!!');
  }
}
