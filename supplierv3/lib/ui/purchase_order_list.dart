import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  final List<PurchaseOrder> purchaseOrders;

  PurchaseOrderListPage(this.purchaseOrders);

  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  List<PurchaseOrder> purchaseOrders;
  Supplier supplier;
  bool isPurchaseOrder = false, isDeliveryAcceptance = false;
  DeliveryAcceptance acceptance;
  User user;

  @override
  void initState() {
    super.initState();
    if (widget.purchaseOrders == null) {
      _getPurchaseOrders();
    }
  }

  _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    purchaseOrders = await ListAPI.getPurchaseOrders(
        supplier.documentReference, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    purchaseOrders = widget.purchaseOrders;
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
                    'Existing POs',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                Text(
                  purchaseOrders == null ? '0' : '${purchaseOrders.length}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900),
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
                    return new InkWell(
                      onTap: () {
                        _confirm(purchaseOrders.elementAt(index));
                      },
                      child: PurchaseOrderCard(
                        purchaseOrder: purchaseOrders.elementAt(index),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  _confirm(PurchaseOrder order) {
    purchaseOrder = order;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Task Selection",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              content: Container(
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    new Text(
                        "Do you want  to create a Delivery Note for this Purchase Order?"),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'PO Number:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${order.purchaseOrderNumber}',
                              style: TextStyle(
                                color: Colors.pink.shade100,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'NO',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
                FlatButton(
                  onPressed: _onDeliveryNote,
                  child: Text(
                    'YES',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  void _refresh() {
    print('_PurchaseOrderListPageState._refresh ..................');
  }

  void _onDeliveryNote() {
    print('_PurchaseOrderListPageState._onDeliveryNote');
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return new DeliveryNotePage(purchaseOrder);
    }));
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
            builder: (context) => new PurchaseOrderListPage(purchaseOrders)),
      );
    }
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  PurchaseOrderCard({@required this.purchaseOrder});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        color: Colors.lightBlue.shade50,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.apps,
                      color: Colors.grey,
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
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Padding(
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
                      '${purchaseOrder.amount}',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
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
}
