import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';

import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/offer_card.dart';

import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/offer_details.dart';

class OfferList extends StatefulWidget {
  final SupplierApplicationModel model;

  OfferList({this.model});

  static _OfferListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_OfferListState>());
  @override
  _OfferListState createState() => _OfferListState();
}

class _OfferListState extends State<OfferList>
    with WidgetsBindingObserver
    implements SnackBarListener, PagerControlListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseMessaging _fcm = FirebaseMessaging();
  Supplier supplier;
  Offer offer;
  SupplierApplicationModel appModel;
  List<Offer> currentPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCached();
  }

  void _getCached() async {
    supplier = await SharedPrefs.getSupplier();
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICE_BIDS + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVESTOR_INVOICE_SETTLEMENTS + supplier.participantId);
    _configureFCM();
    setBasePager();
  }
  _configureFCM() async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');

    AndroidDeviceInfo androidInfo;
    IosDeviceInfo iosInfo;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    bool isRunningIOs = false;
    try {
      androidInfo = await deviceInfo.androidInfo;
      print(
          '\n\n\n################  Running on ${androidInfo.model} ################\n\n');
    } catch (e) {
      print(
          'FCM.configureFCM - error doing Android - this is NOT an Android phone!!');
    }

    try {
      iosInfo = await deviceInfo.iosInfo;
      print(
          '\n\n\n################ Running on ${iosInfo.utsname.machine} ################\n\n');
      isRunningIOs = true;
    } catch (e) {
      print('FCM.configureFCM error doing iOS - this is NOT an iPhone!!');
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n################ Message from FCM ################# ${DateTime.now().toIso8601String()}');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOs == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print('FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('FCM.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              'FCM.configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            'FCM.configureFCM ************************** messageType: $messageType');

        try {
          switch (messageType) {

            case 'INVOICE_BID':
              var m = InvoiceBid.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM INVOICE_BID MESSAGE :');
              onInvoiceBidMessage(m);
              break;

            case 'INVESTOR_INVOICE_SETTLEMENT':
              Map map = json.decode(mJSON);
              prettyPrint(
                  map, '\n\n########## FCM INVESTOR_INVOICE_SETTLEMENT :');
              onInvestorInvoiceSettlement(
                  InvestorInvoiceSettlement.fromJson(map));
              break;
          }
        } catch (e) {
          print(
              'FCM.configureFCM - Houston, we have a problem with null listener somewhere');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print('configureMessaging onLaunch *********** ');
        prettyPrint(message, 'message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print('configureMessaging onResume *********** ');
        prettyPrint(message, 'message delivered on RESUME!');
      },
    );

    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _fcm.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }
  _checkBids(Offer offer) async {
    this.offer = offer;

    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new OfferDetails(offer)),
    );
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print(
        '\n\n_OfferListState.build ################### rebuilding widget ..........\n\n');
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Invoice Offers'),
        elevation: 2.0,
        bottom: PreferredSize(
          child: _getBottom(),
          preferredSize: Size.fromHeight(200.0),
        ),
        backgroundColor: Colors.indigo.shade200,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPressed,
          ),
        ],
      ),
      body: _getList(),
      backgroundColor: Colors.brown.shade100,
    );
  }

  Widget _getList() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });

    return ListView.builder(
        itemCount: currentPage == null ? 0 : currentPage.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return new InkWell(
            onTap: () {
              _checkBids(currentPage.elementAt(index));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0),
              child: OfferCard(
                offer: currentPage.elementAt(index),
                number: index + 1,
                elevation: 1.0,
                showSupplier: false,
                showCustomer: true,
              ),
            ),
          );
        });
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(200.0),
      child: widget.model == null
          ? Container()
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: PagingTotalsView(
                    pageValue: _getPageValue(),
                    totalValue: _getTotalValue(),
                    labelStyle: Styles.blackSmall,
                    pageValueStyle: Styles.blackBoldLarge,
                    totalValueStyle: Styles.brownBoldMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 12.0),
                  child: PagerControl(
                    itemName: 'Invoice Offers',
                    pageLimit: widget.model.pageLimit,
                    elevation: 16.0,
                    items: widget.model.offers.length,
                    listener: this,
                    color: Colors.pink.shade50,
                    pageNumber: _pageNumber,
                  ),
                ),
              ],
            ),
    );
  }

  bool isRefreshOffers = false;
  void _refreshPressed() {
    appModel.refreshOffers();
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) async{
    print(
        '\n\n_OfferListState.onInvoiceBidMessage, ${invoiceBid.investorName} amount: ${invoiceBid.amount}');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    await supplierModelBloc.refreshModel();
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (widget.model == null) return;
    print(
        '_PurchaseOrderList.setBasePager appModel.pageLimit: ${widget.model.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: widget.model.offers,
        pageLimit: widget.model.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
    setState(() {});
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.offerAmount;
    });
    return t;
  }

  double _getTotalValue() {
    if (widget.model == null) return 0.00;
    var t = 0.0;
    widget.model.purchaseOrders.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  int _pageNumber = 1;
  @override
  onNextPageRequired() {
    print('_InvoicesOnOfferState.onNextPageRequired');
    if (currentPage == null) {
      currentPage = List();
    } else {
      currentPage.clear();
    }
    var page = basePager.getNextPage();
    if (page == null) {
      return;
    }
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

  @override
  onPageLimit(int pageLimit) async {
    print('_InvoicesOnOfferState.onPageLimit');
    await widget.model.updatePageLimit(pageLimit);
    _pageNumber = 1;
    basePager.getNextPage();
    return null;
  }

  @override
  onPreviousPageRequired() {
    print('_InvoicesOnOfferState.onPreviousPageRequired');
    if (currentPage == null) {
      currentPage = List();
    }

    var page = basePager.getPreviousPage();
    if (page == null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No more. No mas.',
          textColor: Styles.white,
          backgroundColor: Styles.brown);
      return;
    }
    currentPage.clear();
    page.forEach((f) {
      currentPage.add(f);
    });

    setState(() {
      _pageNumber = basePager.pageNumber;
    });
  }

  void onInvestorInvoiceSettlement(InvestorInvoiceSettlement investorInvoiceSettlement) async{
    print('_OfferListState.onInvestorInvoiceSettlement');
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Settlement arrived',
        textColor: Styles.white,
        backgroundColor: Styles.black);

    await supplierModelBloc.refreshModel();
  }

  //end of paging constructs
}
