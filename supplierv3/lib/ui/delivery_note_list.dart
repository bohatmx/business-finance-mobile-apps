import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
        DeliveryAcceptanceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DeliveryNote> mDeliveryNotes;
  FirebaseMessaging _fcm = FirebaseMessaging();
  DeliveryNote deliveryNote;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryNote, messageShown = false;

  @override
  void initState() {
    super.initState();
    _getCached();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
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

    mDeliveryNotes =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    }
    print(
        '_DeliveryNoteListState._getDeliveryNotes ############ found: ${mDeliveryNotes.length}');

    setState(() {});
  }

  int count;
  String message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    supplier == null ? 'No Supplier?' : supplier.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                      mDeliveryNotes == null ? '0' : '${mDeliveryNotes.length}',
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(80.0)),
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
            child: new ListView.builder(
                itemCount: mDeliveryNotes == null ? 0 : mDeliveryNotes.length,
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
                }),
          ),
        ],
      ),
    );
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
        color: Colors.indigo.shade50,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 20.0, right: 20.0, bottom: 2.0, top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    '${getDate()}',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: Text(
                        deliveryNote.customerName,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          deliveryNote.purchaseOrderNumber,
                          style: TextStyle(
                              color: Colors.purple.shade300,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
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
                          deliveryNote.amount == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.amount}', context),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
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
                          'Note VAT',
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
                          deliveryNote.vat == null
                              ? '0.00'
                              : getFormattedAmount(
                                  '${deliveryNote.vat}', context),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
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
                          style: TextStyle(
                              color: Colors.teal,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold),
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
