import 'package:businesslibrary/data/misc_data.dart';

class DeliveryNote {
  String deliveryNoteId,
      purchaseOrder,
      company,
      govtEntity,
      user,
      acceptedBy,
      deliveryNoteURL,
      remarks;
  DateTime date, dateAccepted;
  List<LineItem> items;

  DeliveryNote(
      {this.deliveryNoteId,
      this.purchaseOrder,
      this.company,
      this.govtEntity,
      this.user,
      this.deliveryNoteURL,
      this.remarks,
      this.date,
      this.dateAccepted,
      this.acceptedBy,
      this.items});

  DeliveryNote.fromJSON(Map data) {
    this.deliveryNoteId = data['deliveryNoteId'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.deliveryNoteURL = data['deliveryNoteURL'];
    this.remarks = data['remarks'];
    this.date = data['date'];
    this.items = data['items'];
    this.dateAccepted = data['dateAccepted'];
    this.acceptedBy = data['acceptedBy'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'deliveryNoteId': deliveryNoteId,
        'purchaseOrder': purchaseOrder,
        'company': company,
        'govtEntity': govtEntity,
        'user': user,
        'deliveryNoteURL': deliveryNoteURL,
        'remarks': remarks,
        'date': date,
        'items': items,
        'dateAccepted': dateAccepted,
        'acceptedBy': acceptedBy,
      };
}
