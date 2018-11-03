import 'package:businesslibrary/data/item.dart';

class PurchaseOrder {
  String supplier, company, govtEntity, user;
  String purchaseOrderId;
  String date, deliveryDateRequired;
  double amount;
  int intDate;

  String description;
  String deliveryAddress;
  String reference,
      documentReference,
      supplierDocumentRef,
      supplierName,
      govtDocumentRef,
      companyDocumentRef;
  String purchaseOrderNumber, purchaserName;
  String purchaseOrderURL, contractURL;
  List<PurchaseOrderItem> items;

  PurchaseOrder(
      {this.supplier,
      this.company,
      this.govtEntity,
      this.user,
      this.purchaseOrderId,
      this.date,
      this.intDate,
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
      this.purchaserName,
      this.items,
      this.contractURL,
      this.purchaseOrderURL});

  PurchaseOrder.fromJson(Map data) {
    this.supplier = data['supplier'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.purchaseOrderId = data['purchaseOrderId'];
    this.user = data['user'];
    this.date = data['date'];
    this.intDate = data['intDate'];
    this.deliveryDateRequired = data['deliveryDateRequired'];
    this.amount = data['amount'] * 1.0;
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
    this.purchaserName = data['purchaserName'];
    this.contractURL = data['contractURL'];
    this.items = List();
  }
  Map<String, dynamic> toJson() {
    var map = {
      'supplier': supplier,
      'purchaseOrderId': purchaseOrderId,
      'company': company,
      'govtEntity': govtEntity,
      'user': user,
      'date': date,
      'intDate': intDate,
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
      'purchaserName': purchaserName,
    };
    return map;
  }
}
