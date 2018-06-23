import 'dart:convert';

import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/delivery_note_list.dart';
import 'package:govt/ui/purchase_order_list.dart';
import 'package:govt/ui/summary_card.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController animationController;
  Animation<double> animation;
  GovtEntity govtEntity;
  List<Invoice> invoices;
  List<DeliveryNote> deliveryNotes;
  List<PurchaseOrder> purchaseOrders;
  List<GovtInvoiceSettlement> govtSettlements;
  User user;
  String fullName;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  @override
  initState() {
    super.initState();
    print('_DashboardState.initState .............. to get summary');
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);
    _getCachedPrefs();
    _configMessaging();
  }

  void _configMessaging() async {
    print(
        '_DashboardState._configMessaging starting _firebaseMessaging config shit');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print(
            '_DashboardState._configMessaging  ############## Receiving FCM message ....');

        var messageType = message["messageType"];
        if (messageType == "GOVT_DELIVERY_NOTE" ||
            messageType == "DELIVERY_NOTE") {
          print(
              '_DashboardState._configMessaging; DELIVERY_NOTE message  received');
          Map map = json.decode(message["json"]);
          var note = new DeliveryNote.fromJson(map);
          assert(note != null);
          PrettyPrint.prettyPrint(
              note.toJson(), 'FCM message received DeliveryNote: ');
          _getNotes();
        }
        if (messageType == "GOVT_INVOICE" || messageType == "INVOICE") {
          print(
              '_DashboardState._configMessaging; GOVT_INVOICE message  received');
          Map map = json.decode(message["json"]);
          var invoice = new Invoice.fromJson(map);
          assert(invoice != null);
          PrettyPrint.prettyPrint(
              invoice.toJson(), 'FCM message received Invoice: ');
          _getInvoices();
        }
      },
      onLaunch: (Map<String, dynamic> message) {},
      onResume: (Map<String, dynamic> message) {},
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      var oldToken = await SharedPrefs.getFCMToken();
      if (token != oldToken) {
        await SharedPrefs.saveFCMToken(token);
        print('_MyHomePageState._configMessaging fcm token saved: $token');
      }
    }).catchError((e) {
      print('_MyHomePageState._configMessaging ERROR fcmToken ');
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    govtEntity = await SharedPrefs.getGovEntity();
    assert(govtEntity != null);
    name = govtEntity.name;
    print(
        '_DashboardState._getSummaryData ....... govt documentId: ${govtEntity.documentReference}');
    setState(() {});
    print(
        '_MainPageState._getSummaryData ......... GOVT_ENTITY -  ${govtEntity.toJson()}');
    _getSummaryData();
  }

  ///get  summaries from Firestore
  _getPOData() async {
    print('_DashboardState._getPOData ................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh PO data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    purchaseOrders = await ListAPI.getPurchaseOrders(
        govtEntity.documentReference, 'govtEntities');
    print(
        '_DashboardState._getSummaryData @@@@@@@@@@@@ purchaseOrders: ${purchaseOrders.length}');
    setState(() {
      totalPOs = purchaseOrders.length;
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  _getInvoices() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh invoice data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    print('_DashboardState._getInvoices ................');
    invoices =
        await ListAPI.getInvoices(govtEntity.documentReference, 'govtEntities');
    if (invoices.isNotEmpty) {
      lastInvoice = invoices.last;
    }
    setState(() {
      totalInvoices = invoices.length;
      print(
          '_DashboardState._getSummaryData ++++++++++++  invoices: ${invoices.length}');
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  _getNotes() async {
    print('_DashboardState._getNotes ......................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh delivery note data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    deliveryNotes = await ListAPI.getDeliveryNotes(
        govtEntity.documentReference, 'govtEntities');
    setState(() {
      totalNotes = deliveryNotes.length;
      print(
          '_DashboardState._getSummaryData ========== deliveryNotes:  ${deliveryNotes.length}');
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  _getSettlements() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh settlement data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    govtSettlements = await FirestoreListAPI.getGovtSettlements(govtEntity);

    setState(() {
      totalPayments = govtSettlements.length;
      print(
          '_DashboardState._getSummaryData ------------  payments: $totalPayments');
    });
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  _getSummaryData() async {
    print('_DashboardState._getSummaryData ..................................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    await _getPOData();
    await _getInvoices();
    await _getNotes();
    await _getSettlements();

    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  Invoice lastInvoice;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  int totalInvoices, totalPOs, totalNotes, totalPayments;
  final invoiceStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.pink,
  );
  final poStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.black,
  );
  final delNoteStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.blue,
  );
  final paymentStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 28.0,
    color: Colors.teal,
  );

  double opacity = 1.0;
  String name;
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 3.0,
          title: Text(
            'BFN - Dashboard',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
            child: new Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        name == null ? 'Organisation' : name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
                      child: Text(
                        fullName == null ? 'user' : fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _getSummaryData,
            ),
            IconButton(
              icon: Icon(Icons.category),
              onPressed: _toggleView,
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            new Opacity(
              opacity: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/fincash.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            new Opacity(
              opacity: opacity,
              child: new Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListView(
                  children: <Widget>[
                    new GestureDetector(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: totalPayments == null ? 0 : totalPayments,
                        label: 'Payments',
                        totalStyle: paymentStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onInvoiceTapped,
                      child: SummaryCard(
                        total: totalInvoices == null ? 0 : totalInvoices,
                        label: 'Invoices',
                        totalStyle: invoiceStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: totalPOs == null ? 0 : totalPOs,
                        label: 'Purchase Orders',
                        totalStyle: poStyle,
                      ),
                    ),
                    new GestureDetector(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: totalNotes == null ? 0 : totalNotes,
                        label: 'Delivery Notes',
                        totalStyle: delNoteStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleView() {
    print('_MainPageState._toggleView .... ');
    if (opacity == 0.0) {
      opacity = 1.0;
    } else {
      opacity = 0.0;
    }

    setState(() {});
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
//    Navigator.push(
//      context,
//      new MaterialPageRoute(builder: (context) => new InvoiceListPage()),
//    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new PurchaseOrderListPage(purchaseOrders)),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new DeliveryNoteList(deliveryNotes)),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }
}
