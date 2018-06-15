import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/purchase_order_page.dart';
import 'package:govt/util.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PurchaseOrder purchaseOrder;
  List<PurchaseOrder> purchaseOrders = List();
  List<Supplier> suppliers;

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
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: suppliers == null ? 0 : suppliers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var supp = suppliers.elementAt(index);
                            print(
                                'SupplierSelectorPage.build about to pop ${supp.name}');
                            Navigator.pop(context, supp);
                          },
                          child: new SupplierCard(suppliers.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddPurchaseOrder() async {
    print('_PurchaseOrderListPageState._onAddPurchaseOrder .......');
    purchaseOrder = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderPageGovt(Util.getURL())),
    );
    if (purchaseOrder != null) {
      purchaseOrders.add(purchaseOrder);
      setState(() {});
      AppSnackbar.showSnackbar(
        context: context,
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order submitted successfully',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  PurchaseOrderCard(this.purchaseOrder);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          Row(),
          Row(),
        ],
      ),
    );
  }
}
