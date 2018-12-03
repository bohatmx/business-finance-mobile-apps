import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/main.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoices.dart';
import 'package:supplierv3/ui/make_offer.dart';
import 'package:supplierv3/ui/offer_list.dart';
import 'package:supplierv3/ui/purchase_order_list.dart';
import 'package:supplierv3/ui/summary_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        PurchaseOrderListener,
        DeliveryAcceptanceListener,
        InvoiceAcceptanceListener,
        InvoiceBidListener,
        GeneralMessageListener {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
  FirebaseMessaging _fcm = FirebaseMessaging();
  String message;
  AnimationController animationController;
  Animation<double> animation;
  Supplier supplier;
  User user;
  String fullName;
  DeliveryAcceptance acceptance;
  FCM _fm = FCM();
  @override
  initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);

    _getCachedPrefs();
    appModel = supplierModelBloc.appModel;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future _getCachedPrefs() async {
    supplier = await SharedPrefs.getSupplier();
    if (supplier == null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new StartPage()),
      );
      return;
    }
    user = await SharedPrefs.getUser();
    fullName = user.firstName + ' ' + user.lastName;
    assert(supplier != null);
    name = supplier.name;
    setState(() {});
    //
    _fm.configureFCM(
      purchaseOrderListener: this,
      deliveryAcceptanceListener: this,
      invoiceAcceptanceListener: this,
      invoiceBidListener: this,
      generalMessageListener: this,
    );
    _subscribeToFCMTopics();
  }

  _subscribeToFCMTopics() async {
    _fcm.subscribeToTopic(FCM.TOPIC_PURCHASE_ORDERS + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + supplier.participantId);
    print(
        '\n\n_DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - POs, Delivery acceptance, Invoice acceptance');
  }

  _showBottomSheet(InvoiceBid bid) {
    if (_scaffoldKey.currentState == null) return;
    _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return AnimatedContainer(
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        height: 350.0,
        color: Colors.brown.shade200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Trading Result',
                    style: Styles.purpleBoldMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InvoiceBidCard(
                bid: bid,
              ),
            ),
          ],
        ),
      );
    });
  }

  Invoice lastInvoice;
  PurchaseOrder lastPO;
  DeliveryNote lastNote;

  double opacity = 1.0;
  String name;
  SupplierApplicationModel appModel;
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  name == null ? 'Org' : name,
                  style: Styles.whiteBoldSmall,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onRefreshPressed() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading fresh data',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    await supplierModelBloc.refreshModel();
    _scaffoldKey.currentState.removeCurrentSnackBar();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SupplierApplicationModel>(
      initialData: supplierModelBloc.appModel,
      stream: supplierModelBloc.appModelStream,
      builder: (context, snapshot) {
        appModel = snapshot.data;
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 3.0,
              title: Text(
                'BFN',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              leading: IconButton(
                  icon: Icon(
                    Icons.apps,
                    color: Colors.white,
                  ),
                  onPressed: _toggleTheme),
              bottom: _getBottom(),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.library_books),
                  onPressed: _goToContracts,
                ),
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
                Opacity(
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/fincash.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _getListView(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BottomNavigationBar(
                onTap: _onNavTap,
                currentIndex: _index,
                iconSize: 20.0,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.boxOpen),
                      title: Text('Offers')),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.shoppingCart),
                      title: Text('Purchase Orders')),
                  BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.truck),
                      title: Text('Deliveries')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _index = 0;
  Widget _getListView() {
    var tiles = List<ListTile>();
    return appModel == null
        ? Container()
        : ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _onInvoiceTapped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: appModel.invoices == null
                      ? Container()
                      : SummaryCard(
                          totalCount: appModel.invoices.length,
                          totalCountLabel: 'Invoices',
                          totalCountStyle: Styles.pinkBoldMedium,
                          totalValueStyle: Styles.greyLabelMedium,
                          totalValueLabel: 'Invoiced Total',
                          totalValue: appModel.invoices == null
                              ? 0.0
                              : appModel.getTotalInvoiceAmount(),
                          elevation: 2.0,
                        ),
                ),
              ),
              GestureDetector(
                onTap: _onOffersTapped,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: appModel == null
                      ? Container()
                      : OfferSummaryCard(
                          appModel: appModel,
                          elevation: 28.0,

                          offerTotalStyle: Styles.blackBoldLarge,
                        ),
                ),
              ),

              tiles == null
                  ? Container()
                  : Column(
                      children: tiles,
                    ),
            ],
          );
  }

  _onOffersTapped() {
    print('_DashboardState._onOffersTapped ...............');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfferList(
                model: appModel,
              ),
        ));
  }

  void _goToWalletPage() {
    print('_MainPageState._goToWalletPage .... ');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WalletPage(
              name: supplier.name,
              participantId: supplier.participantId,
              type: SupplierType)),
    );
  }

  void _onInvoiceTapped() {
    print('_MainPageState._onInvoiceTapped ... go  to list of invoices');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InvoicesOnOffer(model: appModel)),
    );
  }

  void _onPurchaseOrdersTapped() {
    print('_MainPageState._onPurchaseOrdersTapped  go to list of pos');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PurchaseOrderListPage(
                model: appModel,
              )),
    );
  }

  void _onDeliveryNotesTapped() {
    print('_MainPageState._onDeliveryNotesTapped go to  delivery notes');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeliveryNoteList()),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  @override
  onActionPressed(int action) {
    print(
        '_DashboardState.onActionPressed ..................  action: $action');

    switch (action) {
      case PurchaseOrderConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PurchaseOrderListPage()),
        );
        break;
      case DeliveryAcceptanceConstant:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeliveryAcceptanceList()),
        );
        break;
      case InvoiceAcceptedConstant:
        _startOffer();
        break;
      case CompanySettlementConstant:
        break;
      case InvestorSettlement:
        break;
      case InvoiceBidConstant:
        break;
      case WalletConstant:
        break;
      case GovtSettlement:
        break;
    }
  }

  void _startOffer() async {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Loading invoice ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    var inv = await ListAPI.getSupplierInvoiceByNumber(
        invoiceAcceptance.invoiceNumber, supplier.documentReference);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MakeOfferPage(inv)),
    );
  }

  void _goToContracts() {
    print('_DashboardState._goToContracts .......');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContractList()),
    );
  }

  static const CompanySettlementConstant = 1,
      DeliveryAcceptanceConstant = 2,
      GovtSettlement = 3,
      PurchaseOrderConstant = 4,
      InvoiceBidConstant = 5,
      InvestorSettlement = 6,
      WalletConstant = 7,
      InvoiceAcceptedConstant = 8;

  PurchaseOrder purchaseOrder;

  DeliveryAcceptance deliveryAcceptance;

  InvoiceAcceptance invoiceAcceptance;

  InvoiceBid invoiceBid;
  bool isAddInvoiceAcceptance = false, isAddDeliveryAcceptance = false;
  @override
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) {
    deliveryAcceptance = acceptance;
    _showSnack('Delivery Acceptance arrived', Colors.green);

    setState(() {
      isAddDeliveryAcceptance = true;
    });
  }

  @override
  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance) {
    invoiceAcceptance = acceptance;
    _showSnack('Invoice Acceptance arrived', Colors.yellow);
    setState(() {
      isAddInvoiceAcceptance = true;
    });
  }

  bool isAddInvoiceBid = false;
  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) async {
    this.invoiceBid = invoiceBid;
    print(
        '\n\n\n_DashboardState.onInvoiceBidMessage ################ INVOICE BID incoming! ${invoiceBid.investorName}');
    _showBottomSheet(invoiceBid);
    setState(() {
      isAddInvoiceBid = true;
    });
  }

  bool isAddPurchaseOrder = false;
  @override
  onPurchaseOrderMessage(PurchaseOrder purchaseOrder) {
    _showSnack('Purchase Order arrived', Colors.lime);
    this.purchaseOrder = purchaseOrder;
    setState(() {
      isAddPurchaseOrder = true;
    });
  }

  @override
  onGeneralMessage(Map map) {
    _showSnack(map['message'], Colors.white);
  }

  void _showSnack(String message, Color color) {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        textColor: color,
        backgroundColor: Colors.black);
  }

  void _onNavTap(int value) {
    print('_DashboardState._onNavTap ########################## $value');
    _index = value;
    switch (value) {
      case 0:
        _onOffersTapped();
        break;
      case 1:
        _onPurchaseOrdersTapped();
        break;
      case 2:
        _onDeliveryNotesTapped();
        break;
    }
    setState(() {});
  }

  void _toggleTheme() {
    bloc.changeToRandomTheme();
  }
}

class OfferSummaryCard extends StatelessWidget {
  final SupplierApplicationModel appModel;
  final double elevation;
  final TextStyle offerTotalStyle;
  final Color color;
  OfferSummaryCard({this.appModel, this.elevation, this.offerTotalStyle, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 16.0 : elevation,
      color: color == null? Theme.of(context).cardColor : color,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Invoice Offers',
                    style: Styles.greyLabelMedium,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 80.0,
                  child: Text(
                    'Open Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${appModel.getTotalOpenOffers()}',
                    style: Styles.blackBoldMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 80.0,
                    child: Text(
                      'Offer Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${appModel.getTotalOpenOfferAmount()}', context)}',
                      style: offerTotalStyle == null
                          ? Styles.tealBoldMedium
                          : offerTotalStyle,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top:20.0, bottom: 12.0),
              child: Row(
                children: <Widget>[
                  Text('Offer Settlements', style: Styles.greyLabelMedium,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text(
                      'Settlements',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${appModel.settlements.length}',
                      style: Styles.tealBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text(
                      'Settled Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${appModel.getTotalSettlementAmount()}', context)}',
                      style: Styles.tealBoldLarge,
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
}
