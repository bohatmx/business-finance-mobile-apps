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
      supplierDocumentRef,
      govtDocumentRef,
      companyDocumentRef,
      supplierContract,
      contractDocumentRef,
      isOnOffer,
      offer,
      supplierName;
  String date, datePaymentRequired;
  String amount, customerName, purchaseOrderNumber;

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
      this.purchaseOrderNumber,
      this.customerName,
      this.supplierName,
      this.documentReference,
      this.supplierDocumentRef,
      this.govtDocumentRef,
      this.contractDocumentRef,
      this.supplierContract,
      this.companyDocumentRef,
      this.datePaymentRequired,
      this.isOnOffer,
      this.offer,
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
    this.supplierName = data['supplierName'];
    this.govtDocumentRef = data['govtDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];
    this.supplierContract = data['supplierContract'];
    this.contractDocumentRef = data['contractDocumentRef'];
    this.isOnOffer = data['isOnOffer'];
    this.offer = data['offer'];
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
        'supplierName': supplierName,
        'govtDocumentRef': govtDocumentRef,
        'companyDocumentRef': companyDocumentRef,
        'purchaseOrderNumber': purchaseOrderNumber,
        'customerName': customerName,
        'supplierContract': supplierContract,
        'contractDocumentRef': contractDocumentRef,
        'isOnOffer': isOnOffer,
        'offer': offer,
      };
}
