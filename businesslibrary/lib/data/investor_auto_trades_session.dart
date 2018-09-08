class InvestorAutoTradeSession {
  String sessionId, order, profile;
  int sessionBids;
  int sessionTotal, maxSessionInvestment;
  List<String> offers;
  List<String> bids;
  String date;

  InvestorAutoTradeSession(
      {this.sessionId,
      this.sessionBids,
      this.sessionTotal,
      this.bids,
      this.date,
      this.profile,
      this.order,
      this.maxSessionInvestment,
      this.offers});

  InvestorAutoTradeSession.fromJson(Map data) {
    this.sessionId = data['sessionId'];
    this.sessionBids = data['sessionBids'];
    this.sessionTotal = data['sessionTotal'];
    this.maxSessionInvestment = data['maxSessionInvestment'];
    this.date = data['date'];
    this.profile = data['profile'];
    this.order = data['order'];
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
        'sessionId': sessionId,
        'sessionBids': sessionBids,
        'sessionTotal': sessionTotal,
        'maxSessionInvestment': maxSessionInvestment,
        'offers': offers,
        'bids': bids,
        'date': date,
        'profile': profile,
        'order': order,
      };
}
