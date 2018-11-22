import 'package:businesslibrary/util/Finders.dart';

class DeliveryAcceptance extends Findable{
  String acceptanceId;
  String date;
  String deliveryNote;
  String govtEntity, purchaseOrder, purchaseOrderNumber, customerName;
  String company, supplierDocumentRef, invoice;
  String user, supplier, govtDocumentRef, companyDocumentRef;

  DeliveryAcceptance(
      {this.acceptanceId,
      this.date,
      this.deliveryNote,
      this.govtEntity,
      this.company,
      this.supplierDocumentRef,
      this.invoice,
      this.user,
      this.supplier,
      this.govtDocumentRef,
      this.customerName,
      this.purchaseOrderNumber,
      this.purchaseOrder,
      this.companyDocumentRef});

  DeliveryAcceptance.fromJson(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.date = data['date'];
    this.deliveryNote = data['deliveryNote'];
    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.user = data['user'];
    this.supplier = data['supplier'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.govtDocumentRef = data['govtDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];

    this.customerName = data['customerName'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
  }
  Map<String, String> toJson() => <String, String>{
        'acceptanceId': acceptanceId,
        'date': date,
        'deliveryNote': deliveryNote,
        'govtEntity': govtEntity,
        'company': company,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
        'supplier': supplier,
        'supplierDocumentRef': supplierDocumentRef,
        'govtDocumentRef': govtDocumentRef,
        'companyDocumentRef': companyDocumentRef,
        'customerName': customerName,
        'purchaseOrderNumber': purchaseOrderNumber,
      };
}
