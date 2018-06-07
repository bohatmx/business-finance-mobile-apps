import 'package:meta/meta.dart';

class InvestorInvoiceSettlement {
  String invoiceSettlementId;
  DateTime date;
  double settlementPercent;
  double amount;
  double discountPercent;
  String invoice;
  String investor;
  String user;
  String wallet;

  InvestorInvoiceSettlement(
      {@required this.invoiceSettlementId,
      @required this.date,
      @required this.settlementPercent,
      @required this.amount,
      this.discountPercent,
      @required this.invoice,
      @required this.investor,
      @required this.user,
      @required this.wallet});

  InvestorInvoiceSettlement.fromJSON(Map data) {
    this.invoiceSettlementId = data['invoiceSettlementId'];
    this.date = data['date'];
    this.settlementPercent = data['settlementPercent'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.investor = data['investor'];
    this.user = data['user'];
    this.wallet = data['wallet'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceSettlementId': invoiceSettlementId,
        'date': date,
        'settlementPercent': settlementPercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'investor': investor,
        'user': user,
        'wallet': wallet,
      };
}

class CompanyInvoiceSettlement {
  String invoiceSettlementId;
  DateTime date;
  double settlementPercent;
  double amount;
  double discountPercent;
  String invoice;
  String company;
  String user;
  String wallet;

  CompanyInvoiceSettlement(
      {@required this.invoiceSettlementId,
      @required this.date,
      @required this.settlementPercent,
      @required this.amount,
      this.discountPercent,
      @required this.invoice,
      @required this.company,
      @required this.user,
      @required this.wallet});

  CompanyInvoiceSettlement.fromJSON(Map data) {
    this.invoiceSettlementId = data['invoiceSettlementId'];
    this.date = data['date'];
    this.settlementPercent = data['settlementPercent'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.company = data['company'];
    this.user = data['user'];
    this.wallet = data['wallet'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'invoiceSettlementId': invoiceSettlementId,
        'date': date,
        'settlementPercent': settlementPercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'company': company,
        'user': user,
        'wallet': wallet,
      };
}
