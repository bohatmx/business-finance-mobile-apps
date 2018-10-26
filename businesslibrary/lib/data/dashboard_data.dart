class DashboardData {
  int totalOpenOffers = 0,
      totalUnsettledBids = 0,
      totalSettledBids = 0,
      totalBids = 0,
      totalOffers = 0;
  double totalOpenOfferAmount = 0.00,
      totalUnsettledAmount = 0.00,
      totalSettledAmount = 0.00,
      totalBidAmount = 0.0,
      totalOfferAmount = 0.00,
      averageBidAmount = 0.00,
      averageDiscountPerc = 0.0;
  String investorId, supplierId, govtEntityId, name, date;

  DashboardData(
      {this.totalOpenOffers,
      this.totalUnsettledBids,
      this.totalSettledBids,
      this.totalBids,
      this.totalOffers,
      this.totalOpenOfferAmount,
      this.totalUnsettledAmount,
      this.totalSettledAmount,
      this.totalBidAmount,
      this.totalOfferAmount,
      this.averageBidAmount,
      this.averageDiscountPerc,
      this.investorId,
      this.supplierId,
      this.govtEntityId,
      this.name,
      this.date});

  DashboardData.fromJson(Map data) {
    this.totalOpenOffers = data['totalOpenOffers'];
    this.totalUnsettledBids = data['totalUnsettledBids'];
    this.totalSettledBids = data['totalSettledBids'];
    this.totalBids = data['totalBids'];
    this.totalOffers = data['totalOffers'];
    this.totalOpenOfferAmount = data['totalOpenOfferAmount'] * 1.0;
    this.totalUnsettledAmount = data['totalUnsettledAmount'] * 1.0;
    this.totalSettledAmount = data['totalSettledAmount'] * 1.0;
    this.totalBidAmount = data['totalBidAmount'] * 1.0;
    this.totalOfferAmount = data['totalOfferAmount'] * 1.0;
    this.averageBidAmount = data['averageBidAmount'] * 1.0;
    this.averageDiscountPerc = data['averageDiscountPerc'] * 1.0;
    this.investorId = data['investorId'];
    this.supplierId = data['supplierId'];
    this.govtEntityId = data['govtEntityId'];
    this.name = data['name'];
    this.date = data['date'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalOpenOffers': totalOpenOffers,
        'totalUnsettledBids': totalUnsettledBids,
        'totalSettledBids': totalSettledBids,
        'totalBids': totalBids,
        'totalOffers': totalOffers,
        'totalOpenOfferAmount': totalOpenOfferAmount,
        'totalUnsettledAmount': totalUnsettledAmount,
        'totalSettledAmount': totalSettledAmount,
        'totalBidAmount': totalBidAmount,
        'totalOfferAmount': totalOfferAmount,
        'averageBidAmount': averageBidAmount,
        'averageDiscountPerc': averageDiscountPerc,
        'investorId': investorId,
        'supplierId': supplierId,
        'govtEntityId': govtEntityId,
        'name': name,
        'date': date,
      };
}
