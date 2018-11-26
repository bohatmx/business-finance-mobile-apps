import 'package:businesslibrary/util/Finders.dart';

class InvoiceBid extends Findable {
  String invoiceBidId;
  String startTime;
  String endTime;
  double reservePercent;
  double amount;
  double discountPercent;
  String offer, supplierFCMToken, investorFCMToken, customerFCMToken, wallet;
  String investor, date, autoTradeOrder;
  String user, documentReference, supplier;
  String invoiceBidAcceptance, customer, offerDocRef, investorDocRef;
  String supplierName;
  String investorName;
  String customerName;
  bool isSettled;

  InvoiceBid(
      {this.invoiceBidId,
      this.startTime,
      this.endTime,
      this.reservePercent,
      this.amount,
      this.discountPercent,
      this.offer,
      this.investor,
      this.user,
      this.investorName,
      this.date,
      this.autoTradeOrder,
      this.wallet,
      this.isSettled,
      this.supplier,
      this.offerDocRef,
      this.investorDocRef,
      this.supplierFCMToken,
      this.investorFCMToken,
      this.customerFCMToken,
      this.documentReference,
      this.invoiceBidAcceptance,
      this.supplierName,
      this.customerName,
      this.customer});

  InvoiceBid.fromJson(Map data) {
    this.invoiceBidId = data['invoiceBidId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    try {
      this.reservePercent = data['reservePercent'] * 1.0;
    } catch (e) {
      this.reservePercent = 0.0;
    }
    this.amount = data['amount'] * 1.0;
    try {
      this.discountPercent = data['discountPercent'] * 1.0;
    } catch (e) {
      this.discountPercent = 0.0;
    }
    this.offer = data['offer'];
    this.investor = data['investor'];
    this.user = data['user'];
    if (data['intDate'] == null) {
      this.intDate = DateTime.parse(data['date']).millisecondsSinceEpoch;
    } else {
      this.intDate = data['intDate'];
    }
    this.invoiceBidAcceptance = data['invoiceBidAcceptance'];
    this.documentReference = data['documentReference'];
    this.user = data['user'];
    this.supplierFCMToken = data['supplierFCMToken'];
    this.investorFCMToken = data['investorFCMToken'];
    this.customerFCMToken = data['customerFCMToken'];
    this.investorName = data['investorName'];
    this.wallet = data['wallet'];
    this.supplier = data['supplier'];
    this.date = data['date'];
    this.isSettled = data['isSettled'];
    this.autoTradeOrder = data['autoTradeOrder'];

    this.supplierName = data['supplierName'];
    this.customerName = data['customerName'];
    this.customer = data['customer'];
    this.offerDocRef = data['offerDocRef'];
    this.investorDocRef = data['investorDocRef'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceBidId': invoiceBidId,
        'startTime': startTime,
        'endTime': endTime,
        'reservePercent': reservePercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'offer': offer,
        'offerDocRef': offerDocRef,
        'investor': investor,
        'user': user,
        'supplierName': supplierName,
        'customerName': customerName,
        'customer': customer,
        'date': date,
        'investorDocRef': investorDocRef,
        'intDate': intDate,
        'itemNumber': itemNumber,
        'invoiceBidAcceptance': invoiceBidAcceptance,
        'documentReference': documentReference,
        'supplierFCMToken': supplierFCMToken,
        'investorFCMToken': investorFCMToken,
        'customerFCMToken': customerFCMToken,
        'investorName': investorName,
        'wallet': wallet,
        'supplier': supplier,
        'isSettled': isSettled,
        'autoTradeOrder': autoTradeOrder,
      };
}
