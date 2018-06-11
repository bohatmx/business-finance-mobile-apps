class InvoiceBid {
  String invoiceBidId;
  String startTime;
  String endTime;
  String reservePercent;
  String amount;
  String discountPercent;
  String invoiceOffer;
  String investor;
  String user;
  String invoiceBidAcceptance;

  InvoiceBid(
      {this.invoiceBidId,
      this.startTime,
      this.endTime,
      this.reservePercent,
      this.amount,
      this.discountPercent,
      this.invoiceOffer,
      this.investor,
      this.user,
      this.invoiceBidAcceptance});

  InvoiceBid.fromJson(Map data) {
    this.invoiceBidId = data['invoiceBidId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.reservePercent = data['reservePercent'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoiceOffer = data['invoiceOffer'];
    this.investor = data['investor'];
    this.user = data['user'];
    this.invoiceBidAcceptance = data['invoiceBidAcceptance'];
  }
  Map<String, String> toJson() => <String, String>{
        'invoiceBidId': invoiceBidId,
        'startTime': startTime,
        'endTime': endTime,
        'reservePercent': reservePercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoiceOffer': invoiceOffer,
        'investor': investor,
        'user': user,
        'invoiceBidAcceptance': invoiceBidAcceptance,
      };
}
