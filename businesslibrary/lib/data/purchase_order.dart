class PurchaseOrder {
  String supplier, company, govtEntity, user;
  String purchaseOrderId;
  String date, deliveryDateRequired;
  String amount;

  String description;
  String deliveryAddress;
  String reference,
      documentReference,
      supplierDocumentRef,
      supplierName,
      govtDocumentRef,
      companyDocumentRef;
  String purchaseOrderNumber;
  String purchaseOrderURL;

  PurchaseOrder(
      {this.supplier,
      this.company,
      this.govtEntity,
      this.user,
      this.purchaseOrderId,
      this.date,
      this.deliveryDateRequired,
      this.amount,
      this.description,
      this.deliveryAddress,
      this.reference,
      this.documentReference,
      this.supplierDocumentRef,
      this.govtDocumentRef,
      this.companyDocumentRef,
      this.purchaseOrderNumber,
      this.supplierName,
      this.purchaseOrderURL});

  PurchaseOrder.fromJson(Map data) {
    this.supplier = data['supplier'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.purchaseOrderId = data['purchaseOrderId'];
    this.user = data['user'];
    this.date = data['date'];
    this.deliveryDateRequired = data['deliveryDateRequired'];
    this.amount = data['amount'];
    this.description = data['description'];
    this.deliveryAddress = data['deliveryAddress'];
    this.reference = data['reference'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.purchaseOrderURL = data['purchaseOrderURL'];
    this.documentReference = data['documentReference'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.govtDocumentRef = data['govtDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];
    this.supplierName = data['supplierName'];
  }
  Map<String, String> toJson() => <String, String>{
        'supplier': supplier,
        'purchaseOrderId': purchaseOrderId,
        'company': company,
        'govtEntity': govtEntity,
        'user': user,
        'date': date,
        'deliveryDateRequired': deliveryDateRequired,
        'amount': amount,
        'description': description,
        'deliveryAddress': deliveryAddress,
        'reference': reference,
        'purchaseOrderNumber': purchaseOrderNumber,
        'purchaseOrderURL': purchaseOrderURL,
        'documentReference': documentReference,
        'supplierDocumentRef': supplierDocumentRef,
        'govtDocumentRef': govtDocumentRef,
        'companyDocumentRef': companyDocumentRef,
        'supplierName': supplierName,
      };
}
