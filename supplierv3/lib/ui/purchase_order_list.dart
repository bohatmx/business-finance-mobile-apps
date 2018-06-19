import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  final List<PurchaseOrder> purchaseOrders;

  PurchaseOrderListPage(this.purchaseOrders);

  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  List<PurchaseOrder> purchaseOrders;

  @override
  void initState() {
    super.initState();
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
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount:
                        purchaseOrders == null ? 0 : purchaseOrders.length,
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
      ),
    );
  }

  _confirm(PurchaseOrder order) {
    purchaseOrder = order;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Task Selection"),
              content: new Text(
                  "What  do you want to do with this purchase order?\n\n${order.purchaseOrderNumber}"),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onDeliveryNote,
                  child: Text(
                    'Delivery Note',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _onInvoice,
                    child: Text(
                      'Invoice',
                      style: TextStyle(color: Colors.pink),
                    ),
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

  void _onInvoice() {
    print('_PurchaseOrderListPageState._onInvoice');
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return new InvoicePage(purchaseOrder);
    }));
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
        child: Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.apps),
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
                      purchaseOrder.amount,
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

abstract class PurchaseOrderListener {
  onPurchaseOrderTapped(PurchaseOrder order);
}
