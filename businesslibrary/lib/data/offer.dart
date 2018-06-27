//some sort of error toJSON produces an error when sent
class Offer {
  String offerId;
  String startTime;
  String endTime;
  String amount;
  String discountPercent;
  String invoice, documentReference, privateSectorType;
  String purchaseOrder, participantId;
  String user, date, supplier;
  String invoiceDocumentRef;
  String supplierDocumentRef, supplierFCMToken;
  List<String> invoiceBids;
  Offer(
      {this.offerId,
      this.startTime,
      this.endTime,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.documentReference,
      this.date,
      this.participantId,
      this.privateSectorType,
      this.purchaseOrder,
      this.supplier,
      this.invoiceBids,
      this.supplierFCMToken,
      this.invoiceDocumentRef,
      this.supplierDocumentRef,
      this.user});

  Offer.fromJson(Map data) {
    this.offerId = data['offerId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
    this.date = data['date'];
    this.participantId = data['participantId'];
    this.documentReference = data['documentReference'];
    this.privateSectorType = data['privateSectorType'];

    this.invoiceDocumentRef = data['invoiceDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.supplier = data['supplier'];
    this.invoiceBids = data['invoiceBids'];
    this.supplierFCMToken = data['supplierFCMToken'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerId': offerId,
        'startTime': startTime,
        'endTime': endTime,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
        'date': date,
        'documentReference': documentReference,
        'participantId': participantId,
        'privateSectorType': privateSectorType,
        'invoiceDocumentRef': invoiceDocumentRef,
        'supplierDocumentRef': supplierDocumentRef,
        'supplier': supplier,
        'invoiceBids': invoiceBids,
        'supplierFCMToken': supplierFCMToken,
      };
}
