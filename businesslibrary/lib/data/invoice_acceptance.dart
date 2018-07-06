class InvoiceAcceptance {
  String acceptanceId;
  String supplierName;
  String customerName;
  String invoiceNumber;
  String date;
  String invoice;
  String govtEntity;
  String company;
  String user, supplierDocumentRef;

  InvoiceAcceptance(
      {this.acceptanceId,
      this.supplierName,
      this.customerName,
      this.invoiceNumber,
      this.date,
      this.supplierDocumentRef,
      this.invoice,
      this.govtEntity,
      this.company,
      this.user});

  InvoiceAcceptance.fromJson(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.invoice = data['invoice'];
    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.user = data['user'];
    this.date = data['date'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'acceptanceId': acceptanceId,
        'invoice': invoice,
        'govtEntity': govtEntity,
        'company': company,
        'user': user,
        'date': date,
        'supplierName': supplierName,
        'customerName': customerName,
        'supplierDocumentRef': supplierDocumentRef,
      };
}
