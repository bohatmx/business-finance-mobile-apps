//some sort of error toJSON produces an error when sent
class Offer {
  String offerId;
  String startTime;
  String endTime;
  String amount;
  String discountPercent;
  String invoice, documentReference, privateSectorType;
  String purchaseOrder, participantId;
  String user, date;

  Offer(
      {this.offerId,
      this.startTime,
      this.endTime,
      this.amount,
      this.discountPercent,
      this.invoice,
      this.documentReference,
      this.date,
      this.participantId,
      this.privateSectorType,
      this.purchaseOrder,
      this.user});

  Offer.fromJson(Map data) {
    this.offerId = data['offerId'];
    this.startTime = data['startTime'];
    this.endTime = data['endTime'];
    this.amount = data['amount'];
    this.discountPercent = data['discountPercent'];
    this.invoice = data['invoice'];
    this.purchaseOrder = data['purchaseOrder'];
    this.user = data['user'];
    this.date = data['date'];
    this.participantId = data['participantId'];
    this.documentReference = data['documentReference'];
    this.privateSectorType = data['privateSectorType'];
  }

  Map<String, String> toJson() => <String, String>{
        'offerId': offerId,
        'startTime': startTime,
        'endTime': endTime,
        'amount': amount,
        'discountPercent': discountPercent,
        'invoice': invoice,
        'purchaseOrder': purchaseOrder,
        'user': user,
        'date': date,
        'documentReference': documentReference,
        'participantId': participantId,
        'privateSectorType': privateSectorType,
      };
}
