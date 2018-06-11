class InvoiceOffer {
  String invoiceOfferId;
  String startTime;
  String endTime;
  String amount;
  String discountPercent;
  String invoice, documentReference;
  String purchaseOrder;
  String user;

  InvoiceOffer(
      {this.invoiceOfferId,
      this.startTime,
      this.endTime,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.documentReference,
      this.purchaseOrder,
      this.user});

  InvoiceOffer.fromJson(Map data) {
    this.invoiceOfferId = data['invoiceOfferId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
    this.documentReference = data['documentReference'];
  }

  Map<String, String> toJson() => <String, String>{
        'invoiceOfferId': invoiceOfferId,
        'startTime': startTime,
        'endTime': endTime,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
        'documentReference': documentReference,
      };
}
