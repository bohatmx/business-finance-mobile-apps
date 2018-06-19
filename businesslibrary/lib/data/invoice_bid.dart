class InvoiceBid {
  String invoiceBidId;
  String startTime;
  String endTime;
  String reservePercent;
  String amount;
  String discountPercent;
  String offer;
  String investor, date, participantId;
  String user, documentReference;
  String invoiceBidAcceptance;

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
      this.date,
      this.participantId,
      this.documentReference,
      this.invoiceBidAcceptance});

  InvoiceBid.fromJson(Map data) {
    this.invoiceBidId = data['invoiceBidId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.reservePercent = data['reservePercent'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.offer = data['offer'];
    this.investor = data['investor'];
    this.user = data['user'];
    this.invoiceBidAcceptance = data['invoiceBidAcceptance'];
    this.documentReference = data['documentReference'];
    this.user = data['user'];
    this.participantId = data['participantId'];
  }
  Map<String, String> toJson() => <String, String>{
        'invoiceBidId': invoiceBidId,
        'startTime': startTime,
        'endTime': endTime,
        'reservePercent': reservePercent,
        'amount': amount,
        'discountPercent': discountPercent,
        'offer': offer,
        'investor': investor,
        'user': user,
        'date': date,
        'invoiceBidAcceptance': invoiceBidAcceptance,
        'documentReference': documentReference,
        'participantId': participantId,
      };
}
