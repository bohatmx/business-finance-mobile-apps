import 'package:businesslibrary/data/delivery_note.dart';
import 'package:flutter/material.dart';

class DeliveryNoteAcceptance extends StatelessWidget {
  final DeliveryNote deliveryNote;

  DeliveryNoteAcceptance(this.deliveryNote);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Note Acceptance'),
      ),
    );
  }
}
