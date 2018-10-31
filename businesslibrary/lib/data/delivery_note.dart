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
  double amount, vat, totalAmount;
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
      this.amount,
      this.vat,
      this.totalAmount,
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

    print(
        '\n\nDeliveryNote.fromJson RAW, UNADULTERATED date: ${data['date']}'); //2018-10-23T04:52:32.333Z
    //print('*** DateTime.parse: ${DateTime.parse(data['date'])}');

    //this.date = data['date'];
    // print('DeliveryNote.fromJson afterwards??? date: ${this.date}\n\n');
//    try {
//      var s = DateTime.parse(data['date']);
//      print('---------- Parsed date: ${s.toLocal().toIso8601String()}');
//      this.date = s.toLocal();
//      print(
//          '----------- did anything happen?, this.date: ${this.date.toIso8601String()}');
//    } catch (e) {
//      print(e);
//    }
    this.date = data['date'];
    // this.dateAccepted = data['dateAccepted'];
    this.acceptedBy = data['acceptedBy'];
    this.documentReference = data['documentReference'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];

    this.govtDocumentRef = data['govtDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];

    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];

    this.amount = data['amount'] * 1.00;
    this.vat = data['vat'] * 1.00;
    this.totalAmount = data['totalAmount'] * 1.00;
  }
  Map<String, dynamic> toJson() {
    var map = {
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
      'amount': amount,
      'vat': vat,
      'totalAmount': totalAmount,
    };
    return map;
  }
}
