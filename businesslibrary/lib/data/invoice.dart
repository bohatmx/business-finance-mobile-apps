class Invoice {
  String supplier,
      purchaseOrder,
      deliveryNote,
      company,
      govtEntity,
      wallet,
      user,
      invoiceNumber,
      description,
      reference;
  DateTime date, datePaymentRequired;
  double amount;

  Invoice(
      {this.supplier,
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
      this.datePaymentRequired,
      this.amount});

  Invoice.fromJSON(Map data) {
    this.supplier = data['supplier'];
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
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'supplier': supplier,
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
      };
}
