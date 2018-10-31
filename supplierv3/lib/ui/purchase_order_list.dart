import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements SnackBarListener, POListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PurchaseOrder> purchaseOrders;

  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  Supplier supplier;
  bool isPurchaseOrder = false, isDeliveryAcceptance = false;
  DeliveryAcceptance acceptance;
  User user;

  @override
  void initState() {
    super.initState();
    _getPurchaseOrders();
  }

  _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    purchaseOrders =
        await ListAPI.getSupplierPurchaseOrders(supplier.documentReference);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Purchase Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: new Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Existing Purchase Orders',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    purchaseOrders == null ? '0' : '${purchaseOrders.length}',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: purchaseOrders == null ? 0 : purchaseOrders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PurchaseOrderCard(
                      purchaseOrder: purchaseOrders.elementAt(index),
                      listener: this,
                      elevation: elevation,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  double elevation = 2.0;
  void _refresh() {
    print('_PurchaseOrderListPageState._refresh ..................');
  }

  @override
  onActionPressed(int action) {
    print('_PurchaseOrderListPageState.onActionPressed ...........');
    if (isDeliveryAcceptance) {
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new NewInvoicePage(acceptance)),
      );
    }
    if (isPurchaseOrder) {
      purchaseOrders.insert(0, purchaseOrder);
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new PurchaseOrderListPage()),
      );
    }
  }

  @override
  onCreateDeliveryNote(PurchaseOrder po) {
    print('_PurchaseOrderListPageState._onDeliveryNote');
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return new DeliveryNotePage(po);
    }));
  }

  @override
  onDocumentUpload(PurchaseOrder po) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Upload Under Constructtion',
        textColor: Colors.white,
        backgroundColor: Colors.black);
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;
  final POListener listener;
  final double elevation;

  PurchaseOrderCard(
      {@required this.purchaseOrder,
      @required this.listener,
      @required this.elevation});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.apps,
                      color: Colors.purple.shade200,
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      purchaseOrder.purchaserName == null
                          ? 'Unknown Purchaser'
                          : purchaseOrder.purchaserName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      purchaseOrder.purchaseOrderNumber,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${purchaseOrder.amount}', context),
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
            _getActions(),
          ],
        ),
      ),
    );
  }

  Widget _getActions() {
    assert(purchaseOrder != null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 12.0),
      child: Row(
        children: <Widget>[
          FlatButton(
            onPressed: _uploadPOdoc,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.cloud_upload),
                ),
                Text(
                  'Upload PO',
                  style: TextStyle(fontSize: 14.0, color: Colors.purple),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: _createNote,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.create),
                    ),
                    Text(
                      'Delivery Note',
                      style: TextStyle(fontSize: 14.0, color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _uploadPOdoc() {
    listener.onDocumentUpload(purchaseOrder);
  }

  void _createNote() {
    listener.onCreateDeliveryNote(purchaseOrder);
  }
}

abstract class POListener {
  onDocumentUpload(PurchaseOrder po);
  onCreateDeliveryNote(PurchaseOrder po);
}
