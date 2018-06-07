import 'package:govapp/data/misc_data.dart';
import 'package:meta/meta.dart';

class PurchaseOrder {
  String supplier, company, govtEntity, user;
  DateTime date, deliveryDateRequired;
  double amount;

  String description;
  String deliveryAddress;
  String reference;
  String purchaseOrderNumber;
  String purchaseOrderURL;
  List<LineItem> items;

  PurchaseOrder({@required this.supplier, this.company, this.govtEntity, @required this.user,
      @required this.date, this.deliveryDateRequired, @required this.amount, this.description,
      this.deliveryAddress, this.reference, this.purchaseOrderNumber,
      this.purchaseOrderURL, this.items});

  PurchaseOrder.fromJSON(Map data) {
    this.supplier = data['supplier'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.date = data['date'];
    this.deliveryDateRequired = data['deliveryDateRequired'];
    this.amount = data['amount'];
    this.description = data['description'];
    this.deliveryAddress = data['deliveryAddress'];
    this.reference = data['reference'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.purchaseOrderURL = data['purchaseOrderURL'];
    this.items = data['items'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'supplier': supplier,
    'company': company,
    'govtEntity': govtEntity,
    'user': user,
    'date': date,
    'deliveryDateRequired': deliveryDateRequired,
    'amount': amount,
    'description': description,
    'deliveryAddress': deliveryAddress,
    'reference': reference,
    'purchaseOrderNumber': purchaseOrderNumber,
    'purchaseOrderURL': purchaseOrderURL,
    'items': items,
  };
}
