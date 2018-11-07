import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager2.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class PurchaseOrderListPage extends StatefulWidget {
  @override
  _PurchaseOrderListPageState createState() => _PurchaseOrderListPageState();
}

class _PurchaseOrderListPageState extends State<PurchaseOrderListPage>
    implements
        SnackBarListener,
        POListener,
        PagerListener,
        PurchaseOrderListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PurchaseOrder> purchaseOrders = List(), baseList;
  FirebaseMessaging _fcm = FirebaseMessaging();

  PurchaseOrder purchaseOrder;
  List<Supplier> suppliers;
  Supplier supplier;
  bool isPurchaseOrder = false, isDeliveryAcceptance = false;
  DeliveryAcceptance acceptance;
  User user;
  PurchaseOrderSummary summary;
  int pageLimit;
  int lastDate;
  bool isBackPressed = false;
  int previousStartKey;
  DashboardData dashboardData;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    pageLimit = await SharedPrefs.getPageLimit();
    dashboardData = await SharedPrefs.getDashboardData();
    baseList = await Database.getPurchaseOrders();
    pageLimit = await SharedPrefs.getPageLimit();
    currentIndex = 0;
    _getPurchaseOrders();
    FCM.configureFCM(
      purchaseOrderListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    print('\n\n_PurchaseOrderListPageState._getCached SUBSCRIBED to PO topic');
    setState(() {});
  }

  _getPurchaseOrders() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading purchase orders',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    print(
        '\n\n\n\n_PurchaseOrderListPageState._getPurchaseOrders: ==========> currentStartKey before query: $currentStartKey');

    var result = Finder.find(
      intDate: currentStartKey,
      pageLimit: pageLimit,
      baseList: baseList,
    );
    purchaseOrders.clear();
    result.items.forEach((m) {
      purchaseOrders.add(m as PurchaseOrder);
    });
    if (purchaseOrders.isNotEmpty) {
      currentStartKey = purchaseOrders.last.intDate;
      print(
          '\n\n_PurchaseOrderListPageState._getPurchaseOrders ################## pos in page $pageNumber');
      purchaseOrders.forEach((po) {
        print(
            '${po.intDate} ${po.date} ${po.purchaserName} to --> ${po.supplierName} ${po.amount}');
      });
    }

    setState(() {});
    print(
        '\n\ngetPurchaseOrders #######  currentIndex: $currentIndex currentStartKey: $currentStartKey');
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

  double _getPageValue() {
    var t = 0.0;
    purchaseOrders.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(200.0),
      child: Column(
        children: <Widget>[
          PagerHelper(
            dashboardData: dashboardData,
            type: PagerHelper.PURCHASE_ORDER,
            itemName: 'Purchase Orders',
            pageValue: _getPageValue(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Pager(
              listener: this,
              itemName: 'Purchase Orders',
              pageLimit: pageLimit,
              totalItems: baseList == null ? 0 : baseList.length,
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
      body: Container(
//        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                child: _getListView(),
              ),
            ],
          ),
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
  int pageNumber = 1;

  @override
  onPrompt(int pageLimit) {
    print('_PurchaseOrderListPageState.onPrompt ...............');
    if (this.pageLimit == pageLimit) {
      return;
    }
    this.pageLimit = pageLimit;
    currentStartKey = null;
    _getPurchaseOrders();
  }

  @override
  onBack(int startKey, int pageNumber) {
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
  onNext(int pageNumber) {
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

  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Purchase Order arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }

  @override
  onNoMoreData() {
    // TODO: implement onNoMoreData
  }

  _onSwipeRight() {
    print('_PurchaseOrderListPageState._onSwipeRight');
    onBack(null, pageNumber);
  }

  _onSwipeLeft() {
    print('_PurchaseOrderListPageState._onSwipeLeft');
    onNext(pageNumber);
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
