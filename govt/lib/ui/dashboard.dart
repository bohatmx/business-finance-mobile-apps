import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/main.dart';
import 'package:govt/ui/acceptance.dart';
import 'package:govt/ui/delivery_note_list.dart';
import 'package:govt/ui/invoice_list.dart';
import 'package:govt/ui/purchase_order_list.dart';
import 'package:govt/ui/refresh.dart';
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
  static const actionPayments = 1,
      actionInvoices = 2,
      actionPurchaseOrders = 3,
      actionDeliveryNotes = 4,
      actionDeliveryAcceptances = 5;
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
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _getCachedPrefs() async {
    govtEntity = await SharedPrefs.getGovEntity();
    if (govtEntity == null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => StartPage()),
      );
      return;
    }
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;

    dashboardData = await SharedPrefs.getDashboardData();
    if (dashboardData != null) {
      setState(() {});
    } else {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Loading fresh data',
          textColor: Colors.white,
          backgroundColor: Colors.black);
      dashboardData =
          await ListAPI.getCustomerDashboardData(govtEntity.documentReference);
      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState.hideCurrentSnackBar();
      }
      setState(() {});
    }
    assert(govtEntity != null);
    _prepareFCM();
    _getSummaryData(false);
  }

  void _prepareFCM() {
    FCM.configureFCM(
      context: context,
      deliveryNoteListener: this,
      invoiceListener: this,
      generalMessageListener: this,
    );

    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
  }

  Firestore fs = Firestore.instance;
  DashboardData dashboardData;

  _getSummaryData(bool showSnack) async {
    print('_DashboardState._getSummaryData ..................................');

    if (showSnack) {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Loading fresh data',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
    await Refresh.refresh(govtEntity);
    dashboardData = await SharedPrefs.getDashboardData();
    setState(() {});

    print('_DashboardState._getSummaryData REFRESH COMPLETE .......');
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  govtEntity == null ? 'Customer Name' : govtEntity.name,
                  style: Styles.whiteBoldMedium,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onRefreshPressed() {
    _getSummaryData(true);
  }

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
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          leading: Container(),
          bottom: _getBottom(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _onRefreshPressed,
            ),
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: _goToWalletPage,
            ),
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: Stack(
          children: <Widget>[
//            new Opacity(
//              opacity: 0.5,
//              child: Container(
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: AssetImage('assets/fincash.jpg'),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//            ),
            _getListView(),
          ],
        ),
      ),
    );
  }

  Widget _getListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ListView(
        children: <Widget>[
          new InkWell(
            onTap: _onInvoicesTapped,
            child: SummaryCard(
              total: dashboardData == null ? 0 : dashboardData.invoices,
              label: 'Invoices',
              totalStyle: Styles.pinkBoldLarge,
              totalValue: dashboardData == null
                  ? 0.0
                  : dashboardData.totalInvoiceAmount,
              totalValueStyle: Styles.blackBoldMedium,
              elevation: 16.0,
            ),
          ),
          new InkWell(
            onTap: _onPurchaseOrdersTapped,
            child: SummaryCard(
              total: dashboardData == null ? 0 : dashboardData.purchaseOrders,
              label: 'Purchase Orders',
              totalStyle: Styles.tealBoldLarge,
              totalValue: dashboardData == null
                  ? 0.0
                  : dashboardData.totalPurchaseOrderAmount,
              elevation: 2.0,
            ),
          ),
          new InkWell(
            onTap: _onDeliveryNotesTapped,
            child: SummaryCard(
              total: dashboardData == null ? 0 : dashboardData.deliveryNotes,
              label: 'Delivery Notes',
              totalStyle: Styles.blackBoldLarge,
              totalValue: dashboardData == null
                  ? 0.0
                  : dashboardData.totalDeliveryNoteAmount,
              elevation: 2.0,
            ),
          ),
          new InkWell(
            onTap: _onPaymentsTapped,
            child: SummaryCard(
              total: dashboardData == null ? 0 : 0,
              label: 'Payments',
              totalStyle: Styles.blueBoldLarge,
              elevation: 2.0,
            ),
          ),
        ],
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

    _getSummaryData(true);
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

    _getSummaryData(true);

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

class DashboardCard extends StatelessWidget {
  final String countTitle, totalTitle;
  final int count;
  final double total;
  final Color countColor, totalColor, cardColor;

  DashboardCard(this.countTitle, this.totalTitle, this.count, this.total,
      this.countColor, this.totalColor, this.cardColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.0,
      child: Card(
        elevation: 2.0,
        child: Column(
          children: <Widget>[
            Text(''),
          ],
        ),
      ),
    );
  }
}
