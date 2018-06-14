class Invoice {
  String supplier,
      purchaseOrder,
      invoiceId,
      deliveryNote,
      company,
      govtEntity,
      wallet,
      user,
      invoiceNumber,
      description,
      reference,
      documentReference,
      supplierDocumentRef;
  String date, datePaymentRequired;
  String amount;

  Invoice(
      {this.supplier,
      this.invoiceId,
      this.purchaseOrder,
      this.deliveryNote,
      this.company,
      this.govtEntity,
      this.wallet,
      this.user,
      this.invoiceNumber,
      this.description,
      this.reference,
      this.date,
      this.documentReference,
      this.supplierDocumentRef,
      this.datePaymentRequired,
      this.amount});

  Invoice.fromJson(Map data) {
    this.supplier = data['supplier'];
    this.invoiceId = data['invoiceId'];
    this.deliveryNote = data['deliveryNote'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.wallet = data['wallet'];
    this.user = data['user'];
    this.invoiceNumber = data['invoiceNumber'];
    this.description = data['description'];
    this.reference = data['reference'];
    this.date = data['date'];
    this.datePaymentRequired = data['datePaymentRequired'];
    this.amount = data['amount'];
    this.documentReference = data['documentReference'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
  }
  Map<String, String> toJson() => <String, String>{
        'supplier': supplier,
        'invoiceId': invoiceId,
        'deliveryNote': deliveryNote,
        'purchaseOrder': purchaseOrder,
        'company': company,
        'govtEntity': govtEntity,
        'wallet': wallet,
        'user': user,
        'invoiceNumber': invoiceNumber,
        'description': description,
        'reference': reference,
        'date': date,
        'datePaymentRequired': datePaymentRequired,
        'amount': amount,
        'documentReference': documentReference,
        'supplierDocumentRef': supplierDocumentRef,
      };
}
