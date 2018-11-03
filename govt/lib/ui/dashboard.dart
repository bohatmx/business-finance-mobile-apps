import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/sounds.dart';
import 'package:govt/ui/acceptance.dart';
import 'package:govt/ui/delivery_note_list.dart';
import 'package:govt/ui/invoice_list.dart';
import 'package:govt/ui/purchase_order_list.dart';
import 'package:govt/ui/summary_card.dart';
import 'package:govt/ui/theme_util.dart';

class Dashboard extends StatefulWidget {
  final String message;

  Dashboard(this.message);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin
    implements
        SnackBarListener,
        DeliveryNoteListener,
        InvoiceListener,
        GeneralMessageListener {
  static const Payments = 1,
      Invoices = 2,
      actionPurchaseOrders = 3,
      DeliveryNotes = 4,
      DeliveryAcceptances = 5;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  AnimationController animationController;
  Animation<double> animation;
  GovtEntity govtEntity;
//  List<Invoice> invoices;
//  List<DeliveryNote> deliveryNotes;
//  List<PurchaseOrder> purchaseOrders;
//  List<GovtInvoiceSettlement> govtSettlements;
  User user;
  String fullName;
  int messageReceived;
  String message;
  bool listenersStarted = false;

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
    //startFix();
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
    dashboardData = await SharedPrefs.getDashboardData();
    if (dashboardData != null) {
      setState(() {});
    }
    assert(govtEntity != null);
    name = govtEntity.name;

    FCM.configureFCM(
      deliveryNoteListener: this,
      invoiceListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);

    _getSummaryData();
  }

  int index = 0;

  Firestore fs = Firestore.instance;

  void startFix() async {}

  DashboardData dashboardData;
  _getSummaryData() async {
    print('_DashboardState._getSummaryData ..................................');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    dashboardData =
        await ListAPI.getCustomerDashboardData(govtEntity.documentReference);
    setState(() {});
    SharedPrefs.saveDashboardData(dashboardData);
    Sounds.playChime();

    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    _getDetailData();
  }

  void _getDetailData() async {
    print(
        '\n\n_DashboardState._getDetailData ###################################');
    var m =
        await ListAPI.getCustomerPurchaseOrders(govtEntity.documentReference);
    await Database.savePurchaseOrders(PurchaseOrders(m));
    int count = 1;
    m.forEach((x) {
      print(
          ' ${x.date} - ${x.intDate} ## $count ${x.purchaserName} for ${x.supplierName}');
      count++;
    });
  }

  int totalInvoices, totalPOs, totalNotes, totalPayments;

  double opacity = 1.0;
  String name;

  @override
  Widget build(BuildContext context) {
    message = widget.message;
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 16.0,
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
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
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
                    new InkWell(
                      onTap: _onPaymentsTapped,
                      child: SummaryCard(
                        total: dashboardData == null ? 0 : 0,
                        label: 'Payments',
                        totalStyle: Styles.blueBoldLarge,
                      ),
                    ),
                    new InkWell(
                      onTap: _onInvoicesTapped,
                      child: SummaryCard(
                        total:
                            dashboardData == null ? 0 : dashboardData.invoices,
                        label: 'Invoices',
                        totalStyle: Styles.pinkBoldLarge,
                      ),
                    ),
                    new InkWell(
                      onTap: _onPurchaseOrdersTapped,
                      child: SummaryCard(
                        total: dashboardData == null
                            ? 0
                            : dashboardData.purchaseOrders,
                        label: 'Purchase Orders',
                        totalStyle: Styles.tealBoldLarge,
                      ),
                    ),
                    new InkWell(
                      onTap: _onDeliveryNotesTapped,
                      child: SummaryCard(
                        total: dashboardData == null
                            ? 0
                            : dashboardData.deliveryNotes,
                        label: 'Delivery Notes',
                        totalStyle: Styles.blackBoldLarge,
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

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new WalletPage(
              name: govtEntity.name,
              participantId: govtEntity.participantId,
              type: GovtEntityType)),
    );
  }

  void _onInvoicesTapped() {
    print('_MainPageState._onInvoicesTapped ... go  to list of invoices');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new InvoiceList()),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new PurchaseOrderListPage()),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryNoteList()),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  @override
  onActionPressed(int action) {
    print('_DashboardState.onActionPressed action: $action');

    switch (action) {
      case DeliveryNoteConstant:
        _onDeliveryNotesTapped();
        break;
      case InvoiceConstant:
        _onInvoicesTapped();
        break;
    }
  }

  @override
  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    prettyPrint(deliveryNote.toJson(), '#### Delivery Note Arrived');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note arrived',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'Notes',
        listener: this,
        action: DeliveryNoteConstant,
        icon: Icons.create);

    _getSummaryData();
    setState(() {});
  }

  @override
  onInvoiceMessage(Invoice invoice) async {
    prettyPrint(invoice.toJson(), '#### Invoice Arrived');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice arrived',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'Invoices',
        listener: this,
        action: InvoiceConstant,
        icon: Icons.collections_bookmark);

    _getSummaryData();

    if (govtEntity.allowAutoAccept != null) {
      if (govtEntity.allowAutoAccept) {
        var res = await Accept.sendInvoiceAcceptance(invoice, user);
        if (res != '0') {
          AppSnackbar.showSnackbar(
              scaffoldKey: _scaffoldKey,
              message: 'Invoice accepted',
              textColor: Styles.lightGreen,
              backgroundColor: Styles.black);
        }
      }
    }
  }

  @override
  onGeneralMessage(Map map) {
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'General message arrived',
        textColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        actionLabel: 'Close',
        listener: this,
        action: InvoiceConstant,
        icon: Icons.collections_bookmark);
  }
}
