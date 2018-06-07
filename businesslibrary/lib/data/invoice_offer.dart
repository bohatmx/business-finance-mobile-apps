class InvoiceOffer {
  String invoiceOfferId;
  DateTime startTime;
  DateTime endTime;
  double amount;
  double discountPercent;
  String invoice;
  String purchaseOrder;
  String user;

  InvoiceOffer(
      {this.invoiceOfferId,
      this.startTime,
      this.endTime,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.purchaseOrder,
      this.user});

  InvoiceOffer.fromJSON(Map data) {
    this.invoiceOfferId = data['invoiceOfferId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceOfferId': invoiceOfferId,
        'startTime': startTime,
        'endTime': endTime,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
      };
}
