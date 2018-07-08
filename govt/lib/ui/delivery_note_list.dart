import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

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
  GovtEntity govtEntity;
  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    govtEntity = await SharedPrefs.getGovEntity();
  }

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
                      govtEntity == null ? 'No Govt' : govtEntity.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        deliveryNotes == null ? '0' : '${deliveryNotes.length}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w900),
                      ),
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
    );
  }

  DeliveryNote deliveryNote;
  @override
  onActionPressed(int action) {
    print('_DeliveryNoteListState.onActionPressed');
    Navigator.pop(context);
  }

  @override
  onDeliveryNoteTapped(DeliveryNote deliveryNote) {
    this.deliveryNote = deliveryNote;

    prettyPrint(deliveryNote.toJson(),
        '_DeliveryNoteListState.onDeliveryNoteTapped ...');

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

  static const Namespace = 'resource:com.oneconnect.biz.';
  void _acceptDelivery() async {
    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Submitting Delivery Acceptance ...',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    DataAPI api = new DataAPI(getURL());
    DeliveryAcceptance acceptance = DeliveryAcceptance(
      date: new DateTime.now().toIso8601String(),
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
}

class DeliveryNoteCard extends StatelessWidget {
  final DeliveryNote deliveryNote;
  final DeliveryNoteListener listener;

  DeliveryNoteCard({@required this.deliveryNote, @required this.listener});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: Colors.pink.shade50,
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
                      'PO Date:',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                    Text(
                      deliveryNote.date == null
                          ? ''
                          : getFormattedDateLong(deliveryNote.date, context),
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
