import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager2.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:govt/ui/purchase_order_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements InvoiceListener, DeliveryNoteListener, PagerListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  List<PurchaseOrder> purchaseOrders = List(), baseList;
  GovtEntity entity;
  PurchaseOrderSummary poSummary;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  _getCached() async {
    entity = await SharedPrefs.getGovEntity();
    dashboardData = await SharedPrefs.getDashboardData();
    pageLimit = await SharedPrefs.getPageLimit();
    if (dashboardData != null) {
      setState(() {});
    }
    FCM.configureFCM(
      deliveryNoteListener: this,
      invoiceListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + entity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + entity.participantId);

    _getPurchaseOrders();
  }

  _getPurchaseOrders() async {
    print('_PurchaseOrderListPageState._getPOData ................');

    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    baseList = await Database.getPurchaseOrders();
    if (baseList == null) {
      baseList =
          await ListAPI.getCustomerPurchaseOrders(entity.documentReference);
      await Database.savePurchaseOrders(PurchaseOrders(baseList));
      _findOrders(currentStartKey);
    } else {
      _findOrders(currentStartKey);
    }
    print(
        '_PurchaseOrderListPageState._getPurchaseOrders %%%%%%%% baseList has: ${baseList.length} purchase orders');

    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }

    setState(() {});
  }

  void _findOrders(int intDate) {
    purchaseOrders.clear();
    var result = Finder.find(
      intDate: intDate,
      pageLimit: pageLimit,
      baseList: baseList,
    );
    result.items.forEach((item) {
      if (item is PurchaseOrder) {
        purchaseOrders.add(item);
      }
    });
    currentStartKey = result.startKey;
    setState(() {});
  }

  int currentStartKey;
  DashboardData dashboardData;
  double pageValue = 0.0;
  int totalPages = 0, pageNumber = 1;
  int pageLimit = Pager.DefaultPageLimit;

  int _getTotalPages() {
    if (poSummary == null) {
      totalPages = 0;
      return totalPages;
    }
    var rem = poSummary.totalPurchaseOrders % pageLimit;
    totalPages = poSummary.totalPurchaseOrders ~/ pageLimit;
    if (rem > 0) {
      totalPages++;
    }
    return totalPages;
  }

  double _getPageVaulue() {
    if (poSummary == null) {
      pageValue = 0.00;
      return pageValue;
    }
    pageValue = 0.0;
    purchaseOrders.forEach((po) {
      pageValue += po.amount;
    });
    return pageValue;
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(240.0),
      child: Column(
        children: <Widget>[
          PagerHelper(
            dashboardData: dashboardData,
            pageValue: _getPageVaulue(),
            totalPages: _getTotalPages(),
            pageNumber: pageNumber,
            itemName: 'Purchase Orders',
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Pager(
              currentStartKey: currentStartKey,
              listener: this,
              itemName: 'Purchase Orders',
              totalItems: dashboardData.purchaseOrders,
            ),
          ),
        ],
      ),
    );
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
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddPurchaseOrder,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getPurchaseOrders,
          ),
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController controller1 = ScrollController();
  Widget _buildList() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });

    return ListView.builder(
        itemCount: purchaseOrders == null ? 0 : purchaseOrders.length,
        controller: controller1,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
              onTap: _onPurchaseOrderTapped,
              child: new PurchaseOrderCard(purchaseOrders.elementAt(index)));
        });
  }

  void _onAddPurchaseOrder() async {
    print('_PurchaseOrderListPageState._onAddPurchaseOrder .......');
    purchaseOrder = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderPageGovt(getURL())),
    );
    if (purchaseOrder != null) {
      _getPurchaseOrders();
      AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order submitted successfully',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void _onPurchaseOrderTapped() {}
  @override
  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    prettyPrint(deliveryNote.toJson(), '### Delivery Note Arrived');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note Arrived',
        textColor: Styles.lightBlue,
        backgroundColor: Styles.black);
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    prettyPrint(invoice.toJson(), '### Invoice Arrived');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }

  List<PurchaseOrder> lastList;
  @override
  onBack(int pageLimit, int startKey, int pageNumber) {
    print(
        '\n\n\n_PurchaseOrderListPageState.onBack ###### this.pageNumber ${this.pageNumber} pageNumber: $pageNumber startKey: $startKey');

    _findOrders(startKey);
    setState(() {});
  }

  @override
  onNext(int pageLimit, int pageNumber) {
    print(
        '_PurchaseOrderListPageState.onNext pageLimit $pageLimit pageNumber: ####### currentStartKey $pageNumber $currentStartKey');
    _findOrders(currentStartKey);
    setState(() {});
  }

  @override
  onPrompt(int pageLimit) {
    print('\n\n########### _PurchaseOrderListPageState.onPrompt');
    this.pageLimit = pageLimit;
    currentStartKey = null;
    _getPurchaseOrders();
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Have not.',
        textColor: Styles.white,
        backgroundColor: Colors.brown.shade300);
  }
}

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder purchaseOrder;

  PurchaseOrderCard(this.purchaseOrder);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: Card(
        elevation: 3.0,
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
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 40.0, bottom: 8.0, top: 4.0),
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
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 20.0, top: 4.0),
              child: Row(
                children: <Widget>[
                  Text(
                    getFormattedDateLongWithTime(purchaseOrder.date, context),
                    style: Styles.blueSmall,
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
