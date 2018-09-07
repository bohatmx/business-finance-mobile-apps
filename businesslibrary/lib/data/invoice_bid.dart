class InvoiceBid {
  String invoiceBidId;
  String startTime;
  String endTime;
  String reservePercent;
  double amount;
  double discountPercent;
  String offer, supplierFCMToken, wallet;
  String investor, date, participantId;
  String user, documentReference, supplierId;
  String invoiceBidAcceptance, investorName;
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
      this.wallet,
      this.isSettled,
      this.supplierId,
      this.supplierFCMToken,
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
    this.supplierFCMToken = data['supplierFCMToken'];
    this.investorName = data['investorName'];
    this.wallet = data['wallet'];
    this.supplierId = data['supplierId'];
    this.date = data['date'];
    this.isSettled = data['isSettled'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
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
        'supplierFCMToken': supplierFCMToken,
        'investorName': investorName,
        'wallet': wallet,
        'supplierId': supplierId,
        'isSettled': isSettled,
      };
}
