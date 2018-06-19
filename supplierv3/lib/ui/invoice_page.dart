import 'package:businesslibrary/data/purchase_order.dart';
import 'package:flutter/material.dart';

class InvoicePage extends StatefulWidget {
  final PurchaseOrder purchaseOrder;

  InvoicePage(this.purchaseOrder);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

///
class _InvoicePageState extends State<InvoicePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PurchaseOrder purchaseOrder;

  @override
  Widget build(BuildContext context) {
    purchaseOrder = widget.purchaseOrder;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Invoice',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: new Column(
            children: <Widget>[
              Text(
                purchaseOrder.purchaserName,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              new Container(
                child: Text(
                  purchaseOrder.amount,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
