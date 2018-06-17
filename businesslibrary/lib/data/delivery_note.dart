class DeliveryNote {
  String deliveryNoteId,
      purchaseOrder,
      company,
      govtEntity,
      user,
      acceptedBy,
      deliveryNoteURL,
      documentReference,
      supplier,
      supplierName,
      remarks;
  String date, dateAccepted;

  DeliveryNote({
    this.deliveryNoteId,
    this.purchaseOrder,
    this.company,
    this.govtEntity,
    this.user,
    this.deliveryNoteURL,
    this.remarks,
    this.date,
    this.supplierName,
    this.supplier,
    this.documentReference,
    this.dateAccepted,
    this.acceptedBy,
  });

  DeliveryNote.fromJson(Map data) {
    this.deliveryNoteId = data['deliveryNoteId'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.deliveryNoteURL = data['deliveryNoteURL'];
    this.remarks = data['remarks'];
    this.date = data['date'];
    this.dateAccepted = data['dateAccepted'];
    this.acceptedBy = data['acceptedBy'];
    this.documentReference = data['documentReference'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];
  }

  Map<String, String> toJson() => <String, String>{
        'deliveryNoteId': deliveryNoteId,
        'purchaseOrder': purchaseOrder,
        'company': company,
        'govtEntity': govtEntity,
        'user': user,
        'deliveryNoteURL': deliveryNoteURL,
        'remarks': remarks,
        'date': date,
        'dateAccepted': dateAccepted,
        'acceptedBy': acceptedBy,
        'documentReference': documentReference,
        'supplierName': supplierName,
        'supplier': supplier,
      };
}
