class InvestorAutoTradeSession {
  String profileId;
  String autoTradeOrderId;
  int sessionBids;
  double sessionTotal, maxSessionInvestment;
  List<String> offers;
  List<String> bids;
  DateTime date;

  InvestorAutoTradeSession(
      {this.profileId,
      this.autoTradeOrderId,
      this.sessionBids,
      this.sessionTotal,
      this.bids,
      this.date,
      this.maxSessionInvestment,
      this.offers});

  InvestorAutoTradeSession.fromJson(Map data) {
    this.profileId = data['profileId'];
    this.autoTradeOrderId = data['autoTradeOrderId'];
    this.sessionBids = data['sessionBids'];
    this.sessionTotal = data['sessionTotal'];
    this.maxSessionInvestment = data['maxSessionInvestment'];
    this.date = data['date'];
    this.offers = List();
    List list = data['offers'];
    list.forEach((s) {
      this.offers.add(s);
    });
    this.bids = List();
    List listm = data['bids'];
    listm.forEach((s) {
      this.bids.add(s);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'profileId': profileId,
        'autoTradeOrderId': autoTradeOrderId,
        'sessionBids': sessionBids,
        'sessionTotal': sessionTotal,
        'maxSessionInvestment': maxSessionInvestment,
        'offers': offers,
        'bids': bids,
        'date': date,
      };
}
