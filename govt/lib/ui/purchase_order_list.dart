import 'package:flutter/material.dart';
import 'package:govt/ui/purchase_order.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Purchase Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Row(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddPurchaseOrder,
          ),
        ],
      ),
    );
  }

  void _onAddPurchaseOrder() async {
    print('_PurchaseOrderListPageState._onAddPurchaseOrder .......');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new PurchaseOrderPage()),
    );
  }
}
