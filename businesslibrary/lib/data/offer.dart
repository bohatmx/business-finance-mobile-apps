//some sort of error toJSON produces an error when sent
class Offer {
  String offerId;
  String startTime;
  String endTime, offerCancellation;
  String invoice, documentReference, privateSectorType;
  String purchaseOrder, participantId, wallet;
  String user, date, supplier, contractURL;
  String invoiceDocumentRef, supplierName, customerName;
  DateTime dateClosed;
  String supplierDocumentRef, supplierFCMToken;
  double invoiceAmount, offerAmount, discountPercent;
  bool isCancelled;

  List<String> invoiceBids;
  Offer(
      {this.offerId,
      this.startTime,
      this.endTime,
      this.discountPercent,
      this.invoice,
      this.documentReference,
      this.date,
      this.participantId,
      this.privateSectorType,
      this.purchaseOrder,
      this.supplier,
      this.invoiceBids,
      this.dateClosed,
      this.supplierName,
      this.customerName,
      this.invoiceAmount,
      this.offerAmount,
      this.contractURL,
      this.wallet,
      this.isCancelled,
      this.offerCancellation,
      this.supplierFCMToken,
      this.invoiceDocumentRef,
      this.supplierDocumentRef,
      this.user});

  Offer.fromJson(Map data) {
    this.offerId = data['offerId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
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
    this.dateClosed = data['dateClosed'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];

    this.invoiceAmount = data['invoiceAmount'];
    this.offerAmount = data['offerAmount'];
    this.contractURL = data['contractURL'];
    this.wallet = data['wallet'];
    this.isCancelled = data['isCancelled'];
    this.offerCancellation = data['offerCancellation'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerId': offerId,
        'startTime': startTime,
        'endTime': endTime,
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
        'dateClosed': dateClosed,
        'supplierName': supplierName,
        'customerName': customerName,
        'invoiceAmount': invoiceAmount,
        'offerAmount': offerAmount,
        'contractURL': contractURL,
        'wallet': wallet,
        'isCancelled': isCancelled,
        'offerCancellation': offerCancellation,
      };
}
