import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
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
import 'package:govt/ui/refresh.dart';

class DeliveryNoteList extends StatefulWidget {
  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements
        SnackBarListener,
        DeliveryNoteListener,
        InvoiceListener,
        Pager3Listener,
        DeliveryNoteCardListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  List<Supplier> suppliers;
  List<DeliveryNote> deliveryNotes = List();
  User user;
  GovtEntity govtEntity;
  List<DeliveryNote> baseList;
  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    govtEntity = await SharedPrefs.getGovEntity();
    dashboardData = await SharedPrefs.getDashboardData();
    baseList = await Database.getDeliveryNotes();
    pageLimit = await SharedPrefs.getPageLimit();
    FCM.configureFCM(
      context: context,
      deliveryNoteListener: this,
      invoiceListener: this,
    );
    _fcm.subscribeToTopic(FCM.TOPIC_DELIVERY_NOTES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_INVOICES + govtEntity.participantId);
    _fcm.subscribeToTopic(FCM.TOPIC_GENERAL_MESSAGE);

    setState(() {});
    _refresh(false);
  }

  void _onRefreshPressed() {
    _refresh(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes', style: Styles.whiteBoldMedium),
        bottom: _getBottom(),
        backgroundColor: Colors.indigo.shade200,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _onRefreshPressed),
        ],
      ),
      body: Container(
        color: Colors.brown.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _refresh(bool showSnack) async {
    if (showSnack) {
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Refreshing data ...',
          textColor: Styles.white,
          backgroundColor: Styles.black);
    }
    await Refresh.refresh(govtEntity);
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
    }
    baseList = await Database.getDeliveryNotes();
    setState(() {});
  }

  DashboardData dashboardData;
  Widget _getBottom() {
    return PreferredSize(
      preferredSize: new Size.fromHeight(200.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          baseList == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 8.0, right: 8.0),
                  child: Pager3(
                    addHeader: true,
                    listener: this,
                    type: PagerHelper.DELIVERY_NOTE,
                    pageLimit: pageLimit == null ? 4 : pageLimit,
                    itemName: 'Delivery Notes',
                    items: baseList,
                    elevation: 16.0,
                  ),
                ),
        ],
      ),
    );
  }

  ScrollController controller1 = ScrollController();
  Widget _buildList() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.minScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
    return ListView.builder(
        itemCount: deliveryNotes == null ? 0 : deliveryNotes.length,
        controller: controller1,
        itemBuilder: (BuildContext context, int index) {
          return new Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: new DeliveryNoteCard(
                deliveryNote: deliveryNotes.elementAt(index), listener: this),
          );
        });
  }

  DeliveryNote deliveryNote;
  @override
  onActionPressed(int action) {
    print('_DeliveryNoteListState.onActionPressed');
    Navigator.pop(context);
  }

  static const Namespace = 'resource:com.oneconnect.biz.';
  void _acceptDelivery() async {
    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Delivery Acceptance ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    DeliveryAcceptance acceptance = DeliveryAcceptance(
      date: getUTCDate(),
      supplier: deliveryNote.supplier,
      supplierDocumentRef: deliveryNote.supplierDocumentRef,
      companyDocumentRef: deliveryNote.companyDocumentRef,
      govtDocumentRef: deliveryNote.govtDocumentRef,
      purchaseOrder: deliveryNote.purchaseOrder,
      company: deliveryNote.company,
      govtEntity: deliveryNote.govtEntity,
      user: Namespace + 'User#' + user.userId,
      deliveryNote: Namespace + "DeliveryNote#" + deliveryNote.deliveryNoteId,
      customerName: deliveryNote.customerName,
      purchaseOrderNumber: deliveryNote.purchaseOrderNumber,
    );

    prettyPrint(
        acceptance.toJson(), '_DeliveryNoteListState._acceptDelivery ......');
    try {
      var key = await DataAPI3.acceptDelivery(acceptance);
      if (key != null) {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Delivery Acceptance failed',
            listener: this,
            actionLabel: 'ERROR');
      } else {
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Delivery  Note accepted',
            textColor: Colors.white,
            backgroundColor: Colors.black,
            actionLabel: 'DONE',
            listener: this,
            action: 0,
            icon: Icons.done);
      }
    } catch (e) {
      print('_DeliveryNoteListState._acceptDelivery ERROR $e');
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Acceptance failed',
          listener: this,
          actionLabel: 'ERROR');
    }
  }

  @override
  onNoteTapped(DeliveryNote note) {
    this.deliveryNote = note;

    prettyPrint(deliveryNote.toJson(),
        '_DeliveryNoteListState.onDeliveryNoteTapped ...');

    _checkDeliveryNote();
  }

  void showAcceptDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Confirm Delivery Acceptance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    new Text("Do you want to accept this Delivery Note?\n\ "),
                    Padding(
                      padding: const EdgeInsets.only(top: 28.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Purchase Order:',
                            style: TextStyle(fontSize: 12.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${deliveryNote.purchaseOrderNumber}',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'NO',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 16.0, bottom: 10.0),
                  child: RaisedButton(
                    elevation: 4.0,
                    onPressed: _acceptDelivery,
                    color: Colors.teal,
                    child: Text(
                      'YES',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  void _checkDeliveryNote() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Checking Delivery Note ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);
    var noteAcceptance = await ListAPI.getDeliveryAcceptanceForNote(
        deliveryNote.deliveryNoteId,
        deliveryNote.supplierDocumentRef,
        'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (noteAcceptance != null) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery note already accepted',
          textColor: Colors.white,
          backgroundColor: Colors.black);
    } else {
      showAcceptDialog();
    }
  }

  int pageLimit;

  @override
  onDeliveryNoteArrived(DeliveryNote note) {
    if (deliveryNotes == null) {
      deliveryNotes = List();
    }
    deliveryNotes.insert(0, note);
    setState(() {});
  }

  @override
  onDeliveryNoteMessage(DeliveryNote deliveryNote) {
    prettyPrint(deliveryNote.toJson(), '### Delivery Note Arrived');
    baseList.insert(0, deliveryNote);
    setState(() {});

    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note Arrived',
        textColor: Styles.lightBlue,
        backgroundColor: Styles.black);
  }

  @override
  onInvoiceMessage(Invoice invoice) {
    prettyPrint(invoice.toJson(), '### Invoice Arrived');

    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'Invoice Arrived',
        textColor: Styles.lightGreen,
        backgroundColor: Styles.black);
  }

  @override
  onNoMoreData() {
    AppSnackbar.showSnackbar(
        scaffoldKey: _scaffoldKey,
        message: 'No mas. No more. Have not.',
        textColor: Styles.white,
        backgroundColor: Colors.brown.shade300);
  }

  @override
  onInitialPage(List<Findable> items) {
    _setNotes(items);
  }

  @override
  onPage(List<Findable> items) {
    _setNotes(items);
  }

  void _setNotes(List<Findable> items) {
    deliveryNotes.clear();
    items.forEach((f) {
      deliveryNotes.add(f);
    });
    setState(() {});
  }
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteCardListener listener;

  DeliveryNoteCard({@required this.deliveryNote, @required this.listener});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onBigTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
        child: Card(
          elevation: 2.0,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        deliveryNote.itemNumber == null
                            ? '0'
                            : '${deliveryNote.itemNumber}',
                        style: Styles.blackBoldSmall,
                      ),
                    ),
                    Text(
                      getFormattedDateLongWithTime(deliveryNote.date, context),
                      style: Styles.blackSmall,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        deliveryNote.supplierName,
                        style: Styles.blackBoldMedium,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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
                          padding: const EdgeInsets.only(left: 0.0),
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
                        Text(
                          deliveryNote.amount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.amount}', context),
                          style: Styles.blackSmall,
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note VAT',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Text(
                        deliveryNote.vat == null
                            ? '0.00'
                            : getFormattedAmount(
                                '${deliveryNote.vat}', context),
                        style: Styles.blackSmall,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        child: Text(
                          'Note Total',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Text(
                        deliveryNote.totalAmount == null
                            ? '0.00'
                            : getFormattedAmount(
                                '${deliveryNote.totalAmount}', context),
                        style: Styles.tealBoldMedium,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onBigTap() {
    print('DeliveryNoteCard._onBigTap .........................');
    listener.onNoteTapped(deliveryNote);
  }
}

abstract class DeliveryNoteCardListener {
  onNoteTapped(DeliveryNote note);
}
