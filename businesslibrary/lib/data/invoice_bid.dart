class InvoiceBid {
  String invoiceBidId;
  DateTime startTime;
  DateTime endTime;
  double reservePercent;
  double amount;
  double discountPercent;
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

  InvoiceBid.fromJSON(Map data) {
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
  Map<String, dynamic> toJson() => <String, dynamic>{
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
