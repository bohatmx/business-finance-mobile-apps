import 'package:flutter/material.dart';

class DeliveryNoteListPage extends StatefulWidget {
  @override
  _DeliveryNoteListPageState createState() => _DeliveryNoteListPageState();
}

class _DeliveryNoteListPageState extends State<DeliveryNoteListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Delivery  Note List'),
      ),
    );
  }
}
