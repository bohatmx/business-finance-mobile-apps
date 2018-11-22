
import 'package:businesslibrary/util/Finders.dart';

class Offer extends Findable {
  String offerId;
  String startTime;
  String endTime, offerCancellation;
  String invoice, documentReference;
  String purchaseOrder, participantId, wallet;
  String user, date, supplier, contractURL;
  String invoiceDocumentRef, supplierName, customerName;
  String dateClosed;
  String supplierDocumentRef, supplierFCMToken, customerFCMToken;
  double invoiceAmount, offerAmount, discountPercent;
  bool isCancelled, isOpen;
  String sector, sectorName;
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
      this.isOpen,
      this.isCancelled,
      this.offerCancellation,
      this.supplierFCMToken,
      this.customerFCMToken,
      this.invoiceDocumentRef,
      this.supplierDocumentRef,
      this.sector,
      this.sectorName,
      this.user});

  Offer.fromJson(Map data) {
    this.offerId = data['offerId'];
    this.intDate = data['intDate'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.discountPercent = data['discountPercent'] * 1.00;
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
    this.date = data['date'];
    this.participantId = data['participantId'];
    this.documentReference = data['documentReference'];

    this.invoiceDocumentRef = data['invoiceDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.supplier = data['supplier'];
    this.invoiceBids = data['invoiceBids'];
    this.supplierFCMToken = data['supplierFCMToken'];
    this.customerFCMToken = data['customerFCMToken'];
    this.dateClosed = data['dateClosed'];
    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];

    this.invoiceAmount = data['invoiceAmount'] * 1.00;
    this.offerAmount = data['offerAmount'] * 1.00;
    this.contractURL = data['contractURL'];
    this.wallet = data['wallet'];
    this.isCancelled = data['isCancelled'];
    this.offerCancellation = data['offerCancellation'];

    this.sector = data['sector'];
    this.sectorName = data['sectorName'];
    this.isOpen = data['isOpen'];
    this.itemNumber = data['itemNumber'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'offerId': offerId,
        'intDate': intDate,
        'startTime': startTime,
        'endTime': endTime,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
        'date': date,
        'documentReference': documentReference,
        'participantId': participantId,
        'invoiceDocumentRef': invoiceDocumentRef,
        'supplierDocumentRef': supplierDocumentRef,
        'supplier': supplier,
        'invoiceBids': invoiceBids,
        'supplierFCMToken': supplierFCMToken,
        'customerFCMToken': customerFCMToken,
        'dateClosed': dateClosed,
        'supplierName': supplierName,
        'customerName': customerName,
        'invoiceAmount': invoiceAmount,
        'offerAmount': offerAmount,
        'contractURL': contractURL,
        'wallet': wallet,
        'isCancelled': isCancelled,
        'offerCancellation': offerCancellation,
        'sector': sector,
        'sectorName': sectorName,
        'isOpen': isOpen,
        'itemNumber': itemNumber,
      };
}
