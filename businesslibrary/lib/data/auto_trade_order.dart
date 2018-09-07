class AutoTradeOrder {
  String autoTradeOrderId;
  String date;
  String investorName;
  String dateCancelled;
  String investorProfile, user, investor;

  AutoTradeOrder(
      {this.autoTradeOrderId,
      this.date,
      this.investor,
      this.investorName,
      this.dateCancelled,
      this.investorProfile,
      this.user});

  AutoTradeOrder.fromJson(Map data) {
    this.autoTradeOrderId = data['autoTradeOrderId'];
    this.date = data['date'];
    this.investorName = data['investorName'];
    this.dateCancelled = data['dateCancelled'];
    this.investorProfile = data['investorProfile'];
    this.user = data['user'];
    this.investor = data['investor'];
  }
  Map<String, String> toJson() => <String, String>{
        'autoTradeOrderId': autoTradeOrderId,
        'date': date,
        'investorName': investorName,
        'dateCancelled': dateCancelled,
        'investorProfile': investorProfile,
        'user': user,
        'investor': investor,
      };
}
