class ExecuteInvestorAutoTradesEvent {
  String profileId;
  String autoTradeOrderId;
  int sessionBids;
  double sessionTotal, maxSessionInvestment;
  List<String> offers;
  List<String> bids;

  ExecuteInvestorAutoTradesEvent(
      {this.profileId,
      this.autoTradeOrderId,
      this.sessionBids,
      this.sessionTotal,
      this.bids,
      this.maxSessionInvestment,
      this.offers});

  ExecuteInvestorAutoTradesEvent.fromJson(Map data) {
    this.profileId = data['profileId'];
    this.autoTradeOrderId = data['autoTradeOrderId'];
    this.sessionBids = data['sessionBids'];
    this.sessionTotal = data['sessionTotal'];
    this.maxSessionInvestment = data['maxSessionInvestment'];
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
      };
}
