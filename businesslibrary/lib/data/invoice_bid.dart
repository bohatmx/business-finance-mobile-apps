class InvoiceBid {
  String invoiceBidId;
  String startTime;
  String endTime;
  String reservePercent;
  String amount;
  String discountPercent;
  String invoice;
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
      this.invoice,
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
    this.invoice = data['invoice'];
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
        'invoice': invoice,
        'investor': investor,
        'user': user,
        'invoiceBidAcceptance': invoiceBidAcceptance,
      };
}
