import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/purchase_order_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  List<PurchaseOrder> purchaseOrders;
  GovtEntity entity;

  @override
  void initState() {
    super.initState();
    _getPOData();
  }

  _getPOData() async {
    print('_PurchaseOrderListPageState._getPOData ................');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    entity = await SharedPrefs.getGovEntity();
    purchaseOrders = await ListAPI.getPurchaseOrders(
        entity.documentReference, 'govtEntities');
    _scaffoldKey.currentState.removeCurrentSnackBar();
    print(
        '_DashboardState._getSummaryData @@@@@@@@@@@@ purchaseOrders: ${purchaseOrders.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Purchase Orders',
          style: Styles.blackBoldMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: new Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(entity == null ? '' : entity.name,
                      style: Styles.whiteBoldMedium),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    purchaseOrders == null ? '0' : '${purchaseOrders.length}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddPurchaseOrder,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getPOData,
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
                        onTap: _onPurchaseOrderTapped,
                        child: new PurchaseOrderCard(
                            purchaseOrders.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddPurchaseOrder() async {
    print('_PurchaseOrderListPageState._onAddPurchaseOrder .......');
    purchaseOrder = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderPageGovt(getURL())),
    );
    if (purchaseOrder != null) {
      purchaseOrders.add(purchaseOrder);
      setState(() {});
      AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order submitted successfully',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void _onPurchaseOrderTapped() {}
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  PurchaseOrderCard(this.purchaseOrder);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: Card(
        elevation: 4.0,
        color: Colors.brown.shade50,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.apps,
                      color: getRandomColor(),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      purchaseOrder.supplierName == null
                          ? 'Unknown Supplier'
                          : purchaseOrder.supplierName,
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
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 20.0, top: 4.0),
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      purchaseOrder.purchaseOrderNumber,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      getFormattedAmount('${purchaseOrder.amount}', context),
                      style: TextStyle(
                          fontSize: 18.0,
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

  void _uploadPOdoc() {}
}
