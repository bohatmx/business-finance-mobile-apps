import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/app_model.dart';
import 'package:supplierv3/main.dart';
import 'package:supplierv3/ui/contract_list.dart';
import 'package:supplierv3/ui/delivery_acceptance_list.dart';
import 'package:supplierv3/ui/delivery_note_list.dart';
import 'package:supplierv3/ui/invoices.dart';
import 'package:supplierv3/ui/make_offer.dart';
import 'package:supplierv3/ui/offer_list.dart';
import 'package:supplierv3/ui/purchase_order_list.dart';
import 'package:supplierv3/ui/summary_card.dart';
import 'package:scoped_model/scoped_model.dart';
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
  @override
  initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(animationController);

    _getCachedPrefs();
    fix();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future fix() async {
    print('_DashboardState.fix #######################################');
    Firestore fs = Firestore.instance;
    int count = 0;
    var qs = await fs.collection('settlements').getDocuments();
    print('_DashboardState.fix ####### settlements: ${qs.documents.length} to be updated \n\n');
    for (var doc in qs.documents) {
      var stm = InvestorInvoiceSettlement.fromJson(doc.data);
      var settlementRef = doc.reference;
      var qs2 = await fs
          .collection('invoiceOffers')
          .where('offerId', isEqualTo: stm.offer.split('#').elementAt(1))
      .getDocuments();
      if (qs2.documents.isNotEmpty) {
        var offer = Offer.fromJson(qs2.documents.first.data);
        stm.supplier = offer.supplier;
        await settlementRef.setData(stm.toJson());
        count++;
        print('_DashboardState.fix settlement updated with supplier: ${offer.supplierName} investor: ${stm.investor}');
      }
    }
    print('\n\n_DashboardState.fix ######### COMPLETE - $count settlements updated\n\n');
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
    FCM.configureFCM(
      context: context,
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
  SupplierAppModel appModel;
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
                  style: Styles.whiteBoldMedium,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  bool isRefreshPressed = false;
  void _onRefreshPressed() {
    setState(() {
      isRefreshPressed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<SupplierAppModel>(
      builder: (context, _, model) {
        appModel = model;
        if (isRefreshPressed) {
          isRefreshPressed = false;
          model.refreshModel();
        }
        if (isAddPurchaseOrder) {
          isAddPurchaseOrder = false;
          model.addPurchaseOrder(purchaseOrder);
        }
        if (isAddInvoiceAcceptance) {
          isAddInvoiceAcceptance = false;
          model.addInvoiceAcceptance(invoiceAcceptance);
        }
        if (isAddDeliveryAcceptance) {
          isAddDeliveryAcceptance = false;
          model.addDeliveryAcceptance(deliveryAcceptance);
        }

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
              leading: Icon(
                Icons.apps,
                color: Colors.white,
              ),
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
    return ScopedModelDescendant<SupplierAppModel>(
      builder: (context, _, model) {
        var tiles = List<ListTile>();
        return ListView(
          children: <Widget>[
            GestureDetector(
              onTap: _onInvoiceTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: model.invoices == null
                    ? Container()
                    : SummaryCard(
                        totalCount: model.invoices.length,
                        totalCountLabel: 'Invoices',
                        totalCountStyle: Styles.pinkBoldLarge,
                        totalValue: model.invoices == null
                            ? 0.0
                            : model.getTotalInvoiceAmount(),
                        elevation: 2.0,
                      ),
              ),
            ),
            GestureDetector(
              onTap: _onOffersTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: model == null
                    ? Container()
                    : OfferSummaryCard(
                        data: model,
                        elevation: 16.0,
                      ),
              ),
            ),
            GestureDetector(
              onTap: _onPurchaseOrdersTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: model == null
                    ? Container()
                    : SummaryCard(
                        totalCount: model.getTotalPurchaseOrders(),
                        totalCountLabel: 'Purchase Orders',
                        totalCountStyle: Styles.blueBoldLarge,
                        totalValue: model == null
                            ? 0.0
                            : model.getTotalPurchaseOrderAmount(),
                        elevation: 2.0,
                      ),
              ),
            ),
            GestureDetector(
              onTap: _onDeliveryNotesTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: model == null
                    ? Container()
                    : SummaryCard(
                        totalCount: model.deliveryNotes.length,
                        totalCountLabel: 'Delivery Notes',
                        totalCountStyle: Styles.blackBoldLarge,
                        totalValue: model == null
                            ? 0.0
                            : model.getTotalDeliveryNoteAmount(),
                        elevation: 2.0,
                      ),
              ),
            ),
            GestureDetector(
              onTap: _onPaymentsTapped,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: SummaryCard(
                  totalCount: model == null ? 0 : model.settlements.length,
                  totalCountLabel: 'Settlements',
                  totalCountStyle: Styles.greyLabelMedium,
                  totalValue: model.getTotalSettlementAmount(),
                  elevation: 2.0,
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
      },
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
      MaterialPageRoute(
          builder: (context) => DeliveryNoteList(model: appModel)),
    );
  }

  void _onPaymentsTapped() {
    print('_MainPageState._onPaymentsTapped - go to payments');
  }

  refresh() {
    print(
        '_DashboardState.refresh: ################## REFRESH called. getSummary ...');
    setState(() {
      isRefreshPressed = true;
    });
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
}

class OfferSummaryCard extends StatelessWidget {
  final SupplierAppModel data;
  final double elevation;
  OfferSummaryCard({this.data, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation == null ? 16.0 : elevation,
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Invoice Offers',
                    style: Styles.blackBoldMedium,
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Open Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${data.getTotalOpenOffers()}',
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
                    width: 120.0,
                    child: Text(
                      'Open Offer Total',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${getFormattedAmount('${data.getTotalOpenOfferAmount()}', context)}',
                      style: Styles.tealBoldMedium,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Closed Offers',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    '${data.getTotalClosedOffers()}',
                    style: Styles.greyLabelSmall,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 120.0,
                    child: Text(
                      'Cancelled Offers',
                      style: Styles.greyLabelSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '${data.getTotalCancelledOffers()}',
                      style: Styles.greyLabelSmall,
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
