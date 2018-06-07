class DeliveryAcceptance {
  String acceptanceId;
  DateTime date;
  String deliveryNote;
  String govtEntity;
  String company;
  String user;

  DeliveryAcceptance(
      {this.acceptanceId,
      this.date,
      this.deliveryNote,
      this.govtEntity,
      this.company,
      this.user});

  DeliveryAcceptance.fromJSON(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.date = data['date'];
    this.deliveryNote = data['deliveryNote'];
    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.user = data['user'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'acceptanceId': acceptanceId,
        'date': date,
        'deliveryNote': deliveryNote,
        'govtEntity': govtEntity,
        'company': company,
        'user': user
      };
}
