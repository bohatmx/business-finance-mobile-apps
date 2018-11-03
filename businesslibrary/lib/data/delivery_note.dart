import 'package:businesslibrary/util/Finders.dart';

class DeliveryNote extends Findable {
  String deliveryNoteId,
      purchaseOrder,
      company,
      govtEntity,
      user,
      acceptedBy,
      deliveryNoteURL,
      documentReference,
      supplier,
      supplierName,
      remarks;
  double amount, vat, totalAmount;
  String date, dateAccepted;
  String companyDocumentRef, purchaseOrderNumber, customerName;
  String supplierDocumentRef;
  String govtDocumentRef;

  DeliveryNote(
      {this.deliveryNoteId,
      this.purchaseOrder,
      this.company,
      this.govtEntity,
      this.user,
      this.acceptedBy,
      this.deliveryNoteURL,
      this.documentReference,
      this.supplier,
      this.supplierName,
      this.remarks,
      this.date,
      this.amount,
      this.vat,
      this.totalAmount,
      this.dateAccepted,
      this.purchaseOrderNumber,
      this.customerName,
      this.companyDocumentRef,
      this.supplierDocumentRef,
      this.govtDocumentRef});

  DeliveryNote.fromJson(Map data) {
    this.deliveryNoteId = data['deliveryNoteId'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.deliveryNoteURL = data['deliveryNoteURL'];
    this.remarks = data['remarks'];

    this.date = data['date'];
    this.intDate = data['intDate'];

    this.dateAccepted = data['dateAccepted'];
    this.acceptedBy = data['acceptedBy'];
    this.documentReference = data['documentReference'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];

    this.govtDocumentRef = data['govtDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];

    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];

    if (data['amount'] == null) {
      this.amount = 0.00;
    } else {
      this.amount = data['amount'] * 1.0;
    }
    if (data['vat'] == null) {
      this.vat = 0.00;
    } else {
      this.vat = data['vat'] * 1.0;
    }
    if (data['totalAmount'] == null) {
      this.totalAmount = 0.00;
    } else {
      this.totalAmount = data['totalAmount'] * 1.0;
    }
  }
  Map<String, dynamic> toJson() {
    var map = {
      'deliveryNoteId': deliveryNoteId,
      'purchaseOrder': purchaseOrder,
      'company': company,
      'govtEntity': govtEntity,
      'user': user,
      'deliveryNoteURL': deliveryNoteURL,
      'remarks': remarks,
      'date': date,
      'intDate': intDate,
      'dateAccepted': dateAccepted,
      'acceptedBy': acceptedBy,
      'documentReference': documentReference,
      'supplierName': supplierName,
      'supplier': supplier,
      'govtDocumentRef': govtDocumentRef,
      'supplierDocumentRef': supplierDocumentRef,
      'companyDocumentRef': companyDocumentRef,
      'purchaseOrderNumber': purchaseOrderNumber,
      'customerName': customerName,
      'amount': amount,
      'vat': vat,
      'totalAmount': totalAmount,
    };
    return map;
  }
}
