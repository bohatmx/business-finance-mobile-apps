class InvestorInvoiceSettlement {
  String invoiceSettlementId;
  String date;
  String settlementPercent;
  String amount;
  String discountPercent;
  String invoice;
  String investor;
  String user;
  String wallet;

  InvestorInvoiceSettlement(
      {this.invoiceSettlementId,
      this.date,
      this.settlementPercent,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.investor,
      this.user,
      this.wallet});

  InvestorInvoiceSettlement.fromJson(Map data) {
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
  Map<String, String> toJson() => <String, String>{
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
  String date;
  String settlementPercent;
  String amount;
  String discountPercent;
  String invoice;
  String company;
  String user;
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
      };
}
