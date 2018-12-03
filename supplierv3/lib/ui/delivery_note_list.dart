import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/supplier_bloc.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';
import 'package:supplierv3/ui/summary_helper.dart';

class DeliveryNoteList extends StatefulWidget {
  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements
        SnackBarListener,
        DeliveryNoteCardListener,
        InvoiceBidListener,
        InvoiceAcceptanceListener,
        PagerControlListener,
        DeliveryAcceptanceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DeliveryNote> currentPage = List(), baseList;
  FirebaseMessaging _fcm = FirebaseMessaging();
  DeliveryNote deliveryNote;
  SupplierApplicationModel appModel;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryNote, messageShown = false;
  int currentStartKey, pageLimit;
  DashboardData dashboardData;
  FCM _fm = FCM();

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    pageLimit = await SharedPrefs.getPageLimit();
    baseList = await Database.getDeliveryNotes();
    dashboardData = await SharedPrefs.getDashboardData();

    _fm.configureFCM(
      deliveryAcceptanceListener: this,
    );
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + supplier.participantId);

    setState(() {});
  }

  int count;
  String message;

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(220.0),
      child: appModel == null
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
                    itemName: 'Delivery Notes',
                    pageLimit: appModel.pageLimit,
                    elevation: 16.0,
                    items: appModel.offers.length,
                    listener: this,
                    color: Colors.brown.shade100,
                    pageNumber: _pageNumber,
                  ),
                ),
              ],
            ),
    );
  }

  int mCount = 0;
  @override
  Widget build(BuildContext context) {
    appModel = supplierModelBloc.appModel;
    mCount++;
    if (mCount == 1) {
      setBasePager();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes'),
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addDeliveryNote,
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: new Column(
        children: <Widget>[
          Flexible(
            child: _getListView(),
          ),
        ],
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  Widget _getListView() {
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
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                onNoteTapped(currentPage.elementAt(index));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: DeliveryNoteCard(
                  deliveryNote: currentPage.elementAt(index),
                  listener: this,
                ),
              ),
            ),
          );
        });
  }

  @override
  onActionPressed(int action) {
    print('_DeliveryNoteListState.onActionPressed');
  }

  DeliveryAcceptance deliveryAcceptance;
  @override
  onNoteTapped(DeliveryNote note) async {
    prettyPrint(note.toJson(),
        '_DeliveryNoteListState.onAcceptanceTapped ############ \n\n\n');
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking Delivery Note ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    //todo - find acceptance and invoice for this note
    deliveryAcceptance = await ListAPI.getDeliveryAcceptanceForNote(
        note.deliveryNoteId, supplier.documentReference, 'suppliers');
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
    Invoice inv;
    if (deliveryAcceptance == null) {
      print('_DeliveryNoteListState.onNoteTapped accept is null');
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Note has not been accepted yet',
          textColor: Colors.white,
          backgroundColor: Colors.black);
    } else {
      print(
          '_DeliveryNoteListState.onNoteTapped: this note is accepted. checking invoice');
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Checking Invoice ...',
          textColor: Colors.yellow,
          backgroundColor: Colors.black);
      inv = await ListAPI.getInvoiceByDeliveryNote(
          deliveryAcceptance.deliveryNote.split('#').elementAt(1),
          supplier.documentReference);
      if (_scaffoldKey.currentState != null) {
        _scaffoldKey.currentState.removeCurrentSnackBar();
      }
      if (inv == null) {
        _showDialog();
      } else {
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice is already created ${inv.invoiceNumber}',
            textColor: Colors.green,
            backgroundColor: Colors.black);
        return;
      }
    }
  }

  void _addDeliveryNote() async {
    print('_DeliveryNoteListState._addDeliveryNote');

    var res = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new DeliveryNotePage(null)),
    );
    if (res != null && res) {
      await Refresh.refresh(supplier);
    }
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Create Invoice",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Do you want to create an Invoice from this accepted Delivery Note?',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ),
                    Text(
                      deliveryAcceptance.purchaseOrderNumber,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.purple,
                          fontSize: 20.0),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'NO',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                FlatButton(
                  onPressed: _startInvoice,
                  child: Text(
                    'YES',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  void _startInvoice() async {
    print('_DeliveryNoteListState._startInvoice');
    Navigator.pop(context);
    var res = await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new NewInvoicePage(deliveryAcceptance)),
    );
    if (res != null && res) {
      await Refresh.refresh(supplier);
    }
  }

  @override
  onDeliveryAcceptanceMessage(DeliveryAcceptance acceptance) {
    prettyPrint(acceptance.toJson(), "## Acceptance arrived: ");
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery acceptance arrived',
        textColor: Colors.yellow,
        action: 5,
        listener: this,
        actionLabel: 'OK',
        icon: Icons.done_all,
        backgroundColor: Colors.black);
  }

  @override
  onInvoiceAcceptanceMessage(InvoiceAcceptance acceptance) {
    prettyPrint(acceptance.toJson(), "## Invoice acceptance arrived:");
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Acceptance arrived',
        textColor: Colors.yellow,
        action: 5,
        listener: this,
        actionLabel: 'OK',
        icon: Icons.done_all,
        backgroundColor: Colors.black);
  }

  @override
  onInvoiceBidMessage(InvoiceBid invoiceBid) {
    prettyPrint(invoiceBid.toJson(), '## Invoice Bid arrived');
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Bid arrived',
        textColor: Colors.yellow,
        action: 5,
        listener: this,
        actionLabel: 'OK',
        icon: Icons.done_all,
        backgroundColor: Colors.black);
  }

  //paging constructs
  BasePager basePager;
  void setBasePager() {
    if (appModel == null) return;
    print(
        '_DeliveryNoteListState.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
    if (basePager == null) {
      basePager = BasePager(
        items: appModel.deliveryNotes,
        pageLimit: appModel.pageLimit,
      );
    }

    if (currentPage == null) currentPage = List();
    var page = basePager.getFirstPage();
    page.forEach((f) {
      currentPage.add(f);
    });
  }

  double _getPageValue() {
    if (currentPage == null) return 0.00;
    var t = 0.0;
    currentPage.forEach((po) {
      t += po.amount;
    });
    return t;
  }

  double _getTotalValue() {
    if (appModel == null) return 0.00;
    var t = 0.0;
    appModel.deliveryNotes.forEach((po) {
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
    await appModel.updatePageLimit(pageLimit);
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

//end of paging constructs
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteCardListener listener;

  DeliveryNoteCard({this.deliveryNote, this.listener});

  @override
  Widget build(BuildContext context) {
    if (deliveryNote.date == null) {
      return Text('Delivery Note has no Date');
    }
    String getDate() {
      if (deliveryNote.date == null) {
        return 'NULL';
      } else {
        return getFormattedDateLongWithTime(deliveryNote.date, context);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 2.0,
        color: Colors.brown.shade50,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: 2.0, top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '${deliveryNote.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                    ),
                    Text(
                      '${getDate()}',
                      style: Styles.blueSmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: Text(
                        deliveryNote.customerName,
                        overflow: TextOverflow.clip,
                        style: Styles.blackBoldMedium,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 20.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'PO Number',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          deliveryNote.purchaseOrderNumber,
                          style: Styles.blackSmall,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note Amount',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                        ),
                        child: Text(
                          deliveryNote.amount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.amount}', context),
                          style: Styles.blackSmall,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 100.0,
                      child: Text(
                        'Note VAT',
                        style: Styles.blackSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                      ),
                      child: Text(
                        deliveryNote.vat == null
                            ? '0.00'
                            : getFormattedAmount(
                                '${deliveryNote.vat}', context),
                        style: Styles.blackSmall,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note Total',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                        ),
                        child: Text(
                          deliveryNote.totalAmount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.totalAmount}', context),
                          style: Styles.tealBoldMedium,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class DeliveryNoteCardListener {
  onNoteTapped(DeliveryNote note);
}
//resource:com.oneconnect.biz.InvoiceAcceptance#0eeb2f40-9620-11e8-d32e-ad5f0634b32e
//resource:com.oneconnect.biz.InvoiceAcceptance#1077f9f0-9620-11e8-bee8-59eeeaadb5be
