import 'package:businesslibrary/util/Finders.dart';

class InvestorInvoiceSettlement extends Findable {
  String invoiceSettlementId;
  String date;
  double amount;
  String peachPaymentKey, peachTransactionId;
  String supplierName;
  String investorName;
  String customerName;
  String invoiceBid;
  String investor, supplier, offer, customer;
  String user, documentReference;
  String wallet, supplierFCMToken;

  InvestorInvoiceSettlement(
      {this.invoiceSettlementId,
      this.date,
      this.amount,
      this.peachPaymentKey,
      this.invoiceBid,
      this.investor,
      this.supplierFCMToken,
      this.documentReference,
      this.user,
      this.peachTransactionId,
      this.offer,
      this.supplier,
      this.customer,
      this.customerName,
      this.supplierName,
      this.investorName,
      this.wallet});

  InvestorInvoiceSettlement.fromJson(Map data) {
    this.invoiceSettlementId = data['invoiceSettlementId'];
    this.date = data['date'];
    this.amount = data['amount'] * 1.0;
    this.peachPaymentKey = data['peachPaymentKey'];
    this.peachTransactionId = data['peachTransactionId'];

    this.invoiceBid = data['invoiceBid'];
    this.investor = data['investor'];
    this.user = data['user'];
    this.wallet = data['wallet'];
    this.documentReference = data['documentReference'];
    this.supplierFCMToken = data['supplierFCMToken'];

    this.supplier = data['supplier'];
    this.offer = data['offer'];

    this.customer = data['customer'];
    this.customerName = data['customerName'];
    this.supplierName = data['supplierName'];
    this.investorName = data['investorName'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceSettlementId': invoiceSettlementId,
        'date': date,
        'amount': amount,
        'peachPaymentKey': peachPaymentKey,
        'peachTransactionId': peachTransactionId,
        'invoiceBid': invoiceBid,
        'investor': investor,
        'user': user,
        'wallet': wallet,
        'documentReference': documentReference,
        'supplierFCMToken': supplierFCMToken,
        'supplier': supplier,
        'offer': offer,
        'customer': customer,
        'customerName': customerName,
        'supplierName': supplierName,
        'investorName': investorName,
      };
}

class CompanyInvoiceSettlement {
  String invoiceSettlementId;
  String date;
  String settlementPercent;
  String amount;
  String discountPercent, documentReference;
  String invoice;
  String company;
  String user, supplierFCMToken, supplier;
  String wallet;

  CompanyInvoiceSettlement(
      {this.invoiceSettlementId,
      this.date,
      this.settlementPercent,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.company,
      this.user,
      this.supplier,
      this.supplierFCMToken,
      this.documentReference,
      this.wallet});

  CompanyInvoiceSettlement.fromJson(Map data) {
    this.invoiceSettlementId = data['invoiceSettlementId'];
    this.date = data['date'];
    this.settlementPercent = data['settlementPercent'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.company = data['company'];
    this.user = data['user'];
    this.wallet = data['wallet'];
    this.documentReference = data['documentReference'];
    this.supplierFCMToken = data['supplierFCMToken'];

    this.supplier = data['supplier'];
  }
  Map<String, String> toJson() => <String, String>{
        'invoiceSettlementId': invoiceSettlementId,
        'date': date,
        'settlementPercent': settlementPercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'company': company,
        'user': user,
        'wallet': wallet,
        'documentReference': documentReference,
        'supplierFCMToken': supplierFCMToken,
        'supplier': supplier,
      };
}

class GovtInvoiceSettlement {
  String invoiceSettlementId;
  String date;
  String amount;
  String invoice;
  String govtEntity, supplierFCMToken;
  String user, supplier;
  String wallet;

  GovtInvoiceSettlement(
      {this.invoiceSettlementId,
      this.date,
      this.amount,
      this.invoice,
      this.supplierFCMToken,
      this.govtEntity,
      this.user,
      this.supplier,
      this.wallet});

  GovtInvoiceSettlement.fromJson(Map data) {
    this.invoiceSettlementId = data['invoiceSettlementId'];
    this.date = data['date'];
    this.amount = data['amount'];
    this.invoice = data['invoice'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.wallet = data['wallet'];
    this.supplierFCMToken = data['supplierFCMToken'];
    this.supplier = data['supplier'];
  }
  Map<String, String> toJson() => <String, String>{
        'invoiceSettlementId': invoiceSettlementId,
        'date': date,
        'amount': amount,
        'invoice': invoice,
        'govtEntity': govtEntity,
        'user': user,
        'wallet': wallet,
        'supplierFCMToken': supplierFCMToken,
        'supplier': supplier,
      };
}
