import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/listeners/firestore_listener.dart';
import 'package:supplierv3/ui/delivery_note_page.dart';
import 'package:supplierv3/ui/invoice_page.dart';

class DeliveryNoteList extends StatefulWidget {
  final String message;

  DeliveryNoteList(this.message);

  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements
        SnackBarListener,
        DeliveryNoteCardListener,
        DeliveryAcceptanceListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<DeliveryNote> deliveryNotes;
  DeliveryNote deliveryNote;
  User user;
  Supplier supplier;
  bool isPurchaseOrder, isDeliveryNote, messageShown = false;

  @override
  void initState() {
    super.initState();
    _getDeliveryNotes();
  }

  _getDeliveryNotes() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Loading delivery notes',
        textColor: Colors.white,
        backgroundColor: Colors.black);
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    listenForDeliveryAcceptance(supplier.documentReference, this);

    deliveryNotes =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    print(
        '_DeliveryNoteListState._getDeliveryNotes ############ found: ${deliveryNotes.length}');

    setState(() {});
  }

  int count;
  String message;
  @override
  Widget build(BuildContext context) {
    message = widget.message;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    supplier == null ? 'No Supplier?' : supplier.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 20.0),
                    child: Text(
                      deliveryNotes == null ? '0' : '${deliveryNotes.length}',
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 30.0,
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
      body: Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(message == null ? '' : message),
            ),
            new Flexible(
              child: new ListView.builder(
                  itemCount: deliveryNotes == null ? 0 : deliveryNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
                      onTap: () {
                        onNoteTapped(deliveryNotes.elementAt(index));
                      },
                      child: DeliveryNoteCard(
                        deliveryNote: deliveryNotes.elementAt(index),
                        listener: this,
                      ),
                    );
                  }),
            ),
          ],
        ),
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
      //todo - find invoice for this acceptance
      inv = await ListAPI.getInvoiceByDeliveryNote(
          deliveryAcceptance.deliveryNote.split('#').elementAt(1),
          supplier.documentReference);
      if (inv == null) {
        //todo - has been accepted bt invoice not created yet
        _showDialog();
      } else {
        AppSnackbar.showSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice is already created ${inv.invoiceNumber}',
            textColor: Colors.green,
            backgroundColor: Colors.black);
      }
    }
    if (_scaffoldKey.currentState != null) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
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
                height: 80.0,
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
  onDeliveryAcceptance(DeliveryAcceptance da) {
    print(
        '_DeliveryNoteListState.onDeliveryAcceptance ******** purchaseOrderNumber ${da.purchaseOrderNumber} acceptanceId: ${da.acceptanceId}');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    AppSnackbar.showSnackbarWithAction(
        scaffoldKey: _scaffoldKey,
        message: 'Delivery Note accepttance arrived',
        textColor: Colors.yellow,
        action: 5,
        listener: this,
        actionLabel: 'Refresh',
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.event,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    getFormattedDate(deliveryNote.date),
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      deliveryNote.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
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
                padding: const EdgeInsets.only(left: 40.0),
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
                padding: const EdgeInsets.only(left: 40.0),
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
                padding: const EdgeInsets.only(left: 40.0),
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
