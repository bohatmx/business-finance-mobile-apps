import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:govt/util.dart';

class DeliveryNoteList extends StatefulWidget {
  final List<DeliveryNote> deliveryNotes;

  DeliveryNoteList(this.deliveryNotes);

  @override
  _DeliveryNoteListState createState() => _DeliveryNoteListState();
}

class _DeliveryNoteListState extends State<DeliveryNoteList>
    implements SnackBarListener, DeliveryNoteListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Supplier> suppliers;
  List<DeliveryNote> deliveryNotes;
  User user;

  @override
  Widget build(BuildContext context) {
    deliveryNotes = widget.deliveryNotes;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery Notes'),
        bottom: PreferredSize(
          preferredSize: new Size.fromHeight(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 18.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      deliveryNotes == null ? '0' : '${deliveryNotes.length}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: deliveryNotes == null ? 0 : deliveryNotes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: new DeliveryNoteCard(
                            deliveryNote: deliveryNotes.elementAt(index),
                            listener: this),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DeliveryNote deliveryNote;
  @override
  onActionPressed() {
    print('_DeliveryNoteListState.onActionPressed');
  }

  @override
  onDeliveryNoteTapped(DeliveryNote deliveryNote) {
    this.deliveryNote = deliveryNote;
    print(
        '_DeliveryNoteListState.onDeliveryNoteTapped ...  showing dialog.... ${deliveryNote.toJson()}');

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Confirm Delivery Acceptance"),
              content: new Text(
                  "Do you want to accept this Delivery Note?\n\nPurchase Order: ${deliveryNote.purchaseOrderNumber}"),
              actions: <Widget>[
                FlatButton(
                  onPressed: _cancel,
                  child: Text(
                    'NO',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red,
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _acceptDelivery,
                    child: Text(
                      'YES',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  void _cancel() {}

  static const Namespace = 'com.oneconnect.biz.';
  void _acceptDelivery() async {
    DataAPI api = new DataAPI(Util.getURL());
    DeliveryAcceptance acceptance = DeliveryAcceptance(
      date: new DateTime.now().toIso8601String(),
      supplier: deliveryNote.supplier,
      supplierDocumentRef: deliveryNote.supplierDocumentRef,
      companyDocumentRef: deliveryNote.companyDocumentRef,
      govtDocumentRef: deliveryNote.govtDocumentRef,
      company: deliveryNote.company,
      govtEntity: deliveryNote.govtDocumentRef,
      user: Namespace + 'User#' + user.userId,
      deliveryNote: Namespace + "DeliveryNote#" + deliveryNote.deliveryNoteId,
    );
    print(
        '_DeliveryNoteListState._acceptDelivery ...... ${acceptance.toJson()}');
    var key = await api.acceptDelivery(acceptance);
    if (key == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Delivery Acceptance failed',
          listener: this,
          actionLabel: 'ERROR');
    } else {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Deilvery  Note accepted',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'DONE',
          listener: this,
          icon: Icons.done);
    }
  }
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteListener listener;

  DeliveryNoteCard({@required this.deliveryNote, @required this.listener});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new GestureDetector(
          onTap: _onNoteTapped,
          child: Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.apps,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                  Text(
                    deliveryNote.supplierName == null
                        ? ''
                        : deliveryNote.supplierName,
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: new Row(
                  children: <Widget>[
                    Text(
                      'Purchase Order:',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                    Text(
                      deliveryNote.purchaseOrderNumber == null
                          ? ''
                          : deliveryNote.purchaseOrderNumber,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: new Row(
                  children: <Widget>[
                    Text(
                      'Customer:',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                    Text(
                      deliveryNote.customerName == null
                          ? ''
                          : deliveryNote.customerName,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: new Row(
                  children: <Widget>[
                    Text(
                      'PO Date:',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                    Text(
                      deliveryNote.date == null
                          ? ''
                          : Util.getFormattedLongDate(deliveryNote.date),
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNoteTapped() {
    print('DeliveryNoteCard._onNoteTapped: .... ${deliveryNote.toJson()}');
    listener.onDeliveryNoteTapped(deliveryNote);
  }
}

abstract class DeliveryNoteListener {
  onDeliveryNoteTapped(DeliveryNote deliveryNote);
}
