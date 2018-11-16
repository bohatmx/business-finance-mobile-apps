class InvestorUnsettledBidSummary {
  String investorName, investorId;
  int totalUnsettledBids = 0;
  double totalUnsettledBidAmount = 0.0, maxInvestableAmount = 0.0;

  InvestorUnsettledBidSummary(
      {this.investorName,
      this.investorId,
      this.totalUnsettledBids,
      this.totalUnsettledBidAmount,
      this.maxInvestableAmount});

  InvestorUnsettledBidSummary.fromJson(Map data) {
    this.investorName = data['investorName'];
    this.investorId = data['investorId'];
    this.totalUnsettledBids = data['totalUnsettledBids'];
    this.maxInvestableAmount = data['maxInvestableAmount'] * 1.0;
    this.totalUnsettledBidAmount = data['totalUnsettledBidAmount'] * 1.0;
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'investorName': investorName,
        'investorId': investorId,
        'totalUnsettledBids': totalUnsettledBids,
        'maxInvestableAmount': maxInvestableAmount,
        'totalUnsettledBidAmount': totalUnsettledBidAmount,
      };
}
