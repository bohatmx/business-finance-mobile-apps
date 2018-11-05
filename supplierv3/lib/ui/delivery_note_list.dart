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
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/pager2.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

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
        PagerListener,
        DeliveryAcceptanceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DeliveryNote> mDeliveryNotes = List(), baseList;
  FirebaseMessaging _fcm = FirebaseMessaging();
  DeliveryNote deliveryNote;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryNote, messageShown = false;
  int currentStartKey, pageLimit;
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
    baseList = await Database.getDeliveryNotes();
    dashboardData = await SharedPrefs.getDashboardData();

    FCM.configureFCM(
      deliveryAcceptanceListener: this,
    );
    _fcm.subscribeToTopic(
        FCM.TOPIC_DELIVERY_ACCEPTANCES + supplier.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);
    _fcm.subscribeToTopic(
        FCM.TOPIC_INVOICE_ACCEPTANCES + supplier.participantId);
    _getDeliveryNotes();
    setState(() {});
  }

  _getDeliveryNotes() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading delivery notes',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    var res = Finder.find(
        intDate: currentStartKey, pageLimit: pageLimit, baseList: baseList);

    if (res.items.isNotEmpty) {
      mDeliveryNotes.clear();
      res.items.forEach((item) {
        mDeliveryNotes.add(item);
      });
      currentStartKey = mDeliveryNotes.last.intDate;
      mDeliveryNotes.forEach((n) {
        print(
            '${n.intDate} ${n.date} ${n.supplierName} --> to ${n.customerName} ${n.totalAmount}');
      });
    }

    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    setState(() {});
  }

  @override
  onPrompt(int pageLimit) {
    print('_PurchaseOrderListPageState.onPrompt ...............');
  }

  @override
  onBack(int startKey, int pageNumber) {
    print('\n\n_DeliveryNoteListState.onBack -------- startKey: $startKey');
    currentStartKey = startKey;
    _getDeliveryNotes();
  }

  @override
  onNext(int pageNumber) {
    print('_PurchaseOrderListPageState.onNext .......................');
    _getDeliveryNotes();
  }

  @override
  onNoMoreData() {
    // TODO: implement onNoMoreData
  }
  int count;
  String message;
  double _getPageValue() {
    var t = 0.00;
    mDeliveryNotes.forEach((n) {
      t += n.amount;
    });
    return t;
  }

  int _getTotalPages() {
    if (baseList == null) {
      return 0;
    }
    var rem = baseList.length % pageLimit;
    var t = baseList.length ~/ pageLimit;
    if (rem > 0) {
      t++;
    }
    return t;
  }

  Widget _getBottom() {
    return PreferredSize(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: PagerHelper(
                dashboardData: dashboardData,
                type: PagerHelper.DELIVERY_NOTE,
                pageValue: _getPageValue(),
                itemName: 'Delivery Notes',
                totalPages: _getTotalPages(),
              ),
            ),
            baseList == null || baseList.length < 5
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Pager(
                      itemName: 'Delivery Notes',
                      pageLimit: pageLimit,
                      totalItems: baseList == null ? 0 : baseList.length,
                      listener: this,
                      currentStartKey: currentStartKey,
                      elevation: 16.0,
                    ),
                  ),
          ],
        ),
        preferredSize: Size.fromHeight(200.0));
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getDeliveryNotes,
          ),
        ],
      ),
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
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: mDeliveryNotes == null ? 0 : mDeliveryNotes.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                onNoteTapped(mDeliveryNotes.elementAt(index));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: DeliveryNoteCard(
                  deliveryNote: mDeliveryNotes.elementAt(index),
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
    _getDeliveryNotes();
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
      _getDeliveryNotes();
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
      _getDeliveryNotes();
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
        elevation: 1.0,
        color: Colors.brown.shade50,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 30.0, right: 30.0, bottom: 2.0, top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                child: Row(
                  children: <Widget>[
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
