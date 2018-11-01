import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager2.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements SnackBarListener, POListener, Pager2Listener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PurchaseOrder> purchaseOrders;

  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  Supplier supplier;
  bool isPurchaseOrder = false, isDeliveryAcceptance = false;
  DeliveryAcceptance acceptance;
  User user;
  PurchaseOrderSummary summary;
  int pageLimit = 2;
  int lastDate;
  bool isBackPressed = false;
  int previousStartKey;
  DashboardData dashboardData;

  @override
  void initState() {
    super.initState();
    _getCached();
//    _fix();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    pageLimit = await SharedPrefs.getPageLimit();
    dashboardData = await SharedPrefs.getDashboardData();
    currentIndex = 0;
    setState(() {});
    onNext(pageLimit, 1);
  }

  _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    print(
        '\n\n\n\n_PurchaseOrderListPageState._getPurchaseOrders: ==========> currentStartKey before query: $currentStartKey');
    try {
      summary = await ListAPI.getSupplierPurchaseOrdersWithPaging(
          pageLimit: pageLimit,
          startKey: currentStartKey,
          documentId: supplier.documentReference);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Problem with query',
          listener: this,
          actionLabel: 'close');
      return;
    }
    print(
        '\n\n_PurchaseOrderListPageState._getPurchaseOrders ${summary.purchaseOrders.length} purchase orders');
    print(
        '\n\ngetPurchaseOrders #######  currentIndex: $currentIndex currentStartKey: $currentStartKey');
    purchaseOrders = summary.purchaseOrders;
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (purchaseOrders.isNotEmpty) {
      currentStartKey = purchaseOrders.last.intDate;
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No purchase orders found',
          listener: this,
          actionLabel: 'close');
    }
    setState(() {});
  }

  var totalPages = 0;
  int _getTotalPages() {
    var rem = dashboardData.purchaseOrders % pageLimit;
    print('_PurchaseOrderListPageState._getTotalPages remainder: $rem');
    try {
      if (rem > 0) {
        totalPages = int.parse('${dashboardData.purchaseOrders ~/ pageLimit}');
        totalPages++;
      } else {
        totalPages = int.parse('${dashboardData.purchaseOrders ~/ pageLimit}');
      }
    } catch (e) {
      print('########### cannot make total .........))))))))))');
    }
    return totalPages;
  }

  String _getPageValue() {
    var t = 0.0;
    purchaseOrders.forEach((po) {
      t += po.amount;
    });
    return getFormattedAmount('$t', context);
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Total Value:',
                  style: Styles.whiteSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    dashboardData == null
                        ? '0.00'
                        : '${getFormattedAmount('${dashboardData.totalPurchaseOrderAmount}', context)}',
                    style: Styles.brownBoldMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Page Value:',
                  style: Styles.whiteSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    purchaseOrders == null ? '0.00' : _getPageValue(),
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Page",
                  style: Styles.whiteSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$pageNumber',
                    style: Styles.blackBoldSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'of',
                    style: Styles.whiteSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 40.0),
                  child: Text(
                    dashboardData == null ? '00' : '${_getTotalPages()}',
                    style: Styles.blackBoldSmall,
                  ),
                ),
                Text(
                  dashboardData == null
                      ? '0'
                      : '${dashboardData.purchaseOrders}',
                  style: Styles.blackBoldSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Purchase Orders',
                    style: Styles.whiteSmall,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Pager2(
              listener: this,
              itemName: 'POrders',
              currentStartKey: currentStartKey,
            ),
          ),
        ],
      ),
    );
  }

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Purchase Orders'),
        bottom: _getBottom(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Flexible(
              child: _getListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });

    return ListView.builder(
        itemCount: purchaseOrders == null ? 0 : purchaseOrders.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return PurchaseOrderCard(
            purchaseOrder: purchaseOrders.elementAt(index),
            listener: this,
            elevation: elevation,
          );
        });
  }

  double elevation = 2.0;
  void _refresh() {
    print('_PurchaseOrderListPageState._refresh ..................');
    _getPurchaseOrders();
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

  int currentIndex = 0;
  int currentStartKey;
  KeyItems keyItems = KeyItems();
  int pageNumber = 1;

  @override
  onPrompt() {
    print('_PurchaseOrderListPageState.onPrompt ...............');
  }

  @override
  onBack(int pageLimit, int startKey, int pageNumber) {
    print(
        '\n\n\n\n_PurchaseOrderListPageState.onBack ..............................');
    this.pageLimit = pageLimit;
    this.pageNumber = pageNumber;
    currentStartKey = startKey;
    currentIndex--;
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    setState(() {});
    _getPurchaseOrders();
  }

  @override
  onNext(int pageLimit, int pageNumber) {
    print('_PurchaseOrderListPageState.onNext .......................');
    this.pageLimit = pageLimit;
    this.pageNumber = pageNumber;
    currentIndex++;
    if (currentIndex > pageLimit) {
      currentIndex = 0;
    }
    setState(() {});
    _getPurchaseOrders();
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
                      color: getRandomColor(),
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
              padding: const EdgeInsets.only(left: 40.0, bottom: 8.0),
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
            Padding(
              padding: const EdgeInsets.only(left: 40.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    getFormattedDateLongWithTime(
                        '${purchaseOrder.date}', context),
                    style: Styles.blueBoldSmall,
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
