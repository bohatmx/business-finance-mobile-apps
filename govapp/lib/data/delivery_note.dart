import 'package:govapp/data/misc_data.dart';
import 'package:meta/meta.dart';

class DeliveryNote {
  String deliveryNoteId,
      purchaseOrder,
      company,
      govtEntity,
      user,
      deliveryNoteURL,
      remarks;
  DateTime date;
  List<LineItem> items;

  DeliveryNote(
      {@required this.deliveryNoteId,
      this.purchaseOrder,
      this.company,
      this.govtEntity,
      this.user,
      this.deliveryNoteURL,
      this.remarks,
      @required this.date,
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
      };
}
