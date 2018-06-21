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
  String companyDocumentRef, purchaseOrderNumber, customerName;
  String supplierDocumentRef;
  String govtDocumentRef;

  DeliveryNote(
      {this.deliveryNoteId,
      this.purchaseOrder,
      this.company,
      this.govtEntity,
      this.user,
      this.acceptedBy,
      this.deliveryNoteURL,
      this.documentReference,
      this.supplier,
      this.supplierName,
      this.remarks,
      this.date,
      this.dateAccepted,
      this.purchaseOrderNumber,
      this.customerName,
      this.companyDocumentRef,
      this.supplierDocumentRef,
      this.govtDocumentRef});

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

    this.govtDocumentRef = data['govtDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];

    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];
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
        'govtDocumentRef': govtDocumentRef,
        'supplierDocumentRef': supplierDocumentRef,
        'companyDocumentRef': companyDocumentRef,
        'purchaseOrderNumber': purchaseOrderNumber,
        'customerName': customerName,
      };
}
