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
import 'package:businesslibrary/util/pager.dart';
import 'package:businesslibrary/util/pager_helper.dart';
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
        Pager3Listener,
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

    FCM.configureFCM(
      purchaseOrderListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    print('\n\n_PurchaseOrderListPageState._getCached SUBSCRIBED to PO topic');
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
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
            child: baseList == null
                ? Container()
                : Pager3(
                    addHeader: true,
                    type: PagerHelper.PURCHASE_ORDER,
                    itemName: 'Purchase Orders',
                    elevation: 8.0,
                    pageLimit: pageLimit,
                    items: baseList,
                    listener: this,
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
        backgroundColor: Colors.pink.shade200,
      ),
      backgroundColor: Colors.pink.shade50,
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
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No more. No mas.',
        textColor: Styles.white,
        backgroundColor: Styles.teal);
  }

  @override
  onInitialPage(List<Findable> items) {
    purchaseOrders.clear();
    items.forEach((f) {
      if (f is PurchaseOrder) {
        purchaseOrders.add(f);
      }
    });
    setState(() {});
  }

  @override
  onPage(List<Findable> items) {
    purchaseOrders.clear();
    items.forEach((f) {
      if (f is PurchaseOrder) {
        purchaseOrders.add(f);
      }
    });
    setState(() {});
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
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, top: 10.0, bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${purchaseOrder.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          getFormattedDateLongWithTime(
                              '${purchaseOrder.date}', context),
                          style: Styles.blackSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      purchaseOrder.purchaserName == null
                          ? 'Unknown Purchaser'
                          : purchaseOrder.purchaserName,
                      style: Styles.blackBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
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
                    padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                    child: Text(
                      getFormattedAmount('${purchaseOrder.amount}', context),
                      style: Styles.tealBoldLarge,
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
                  style: Styles.greyLabelSmall,
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
                      style: Styles.greyLabelSmall,
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
