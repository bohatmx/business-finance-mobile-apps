class DashboardData {
  int totalOpenOffers = 0,
      totalUnsettledBids = 0,
      totalSettledBids = 0,
      totalBids = 0,
      totalOffers = 0,
      purchaseOrders = 0,
      invoices = 0,
      deliveryNotes = 0,
      cancelledOffers = 0,
      closedOffers = 0;
  double totalOpenOfferAmount = 0.00,
      totalUnsettledAmount = 0.00,
      totalSettledAmount = 0.00,
      totalBidAmount = 0.0,
      totalOfferAmount = 0.00,
      averageBidAmount = 0.00,
      totalPurchaseOrderAmount = 0.00,
      totalInvoiceAmount = 0.00,
      averageDiscountPerc = 0.0;
  String date;

  DashboardData(
      {this.totalOpenOffers,
      this.totalUnsettledBids,
      this.totalSettledBids,
      this.totalBids,
      this.totalOffers,
      this.purchaseOrders,
      this.invoices,
      this.deliveryNotes,
      this.cancelledOffers,
      this.closedOffers,
      this.totalPurchaseOrderAmount,
      this.totalInvoiceAmount,
      this.totalOpenOfferAmount,
      this.totalUnsettledAmount,
      this.totalSettledAmount,
      this.totalBidAmount,
      this.totalOfferAmount,
      this.averageBidAmount,
      this.averageDiscountPerc,
      this.date});

  DashboardData.fromJson(Map data) {
    this.totalOpenOffers = data['totalOpenOffers'];
    this.totalUnsettledBids = data['totalUnsettledBids'];
    this.totalSettledBids = data['totalSettledBids'];
    this.totalBids = data['totalBids'];
    this.totalOffers = data['totalOffers'];
    try {
      this.totalOpenOfferAmount = data['totalOpenOfferAmount'] * 1.0;
    } catch (e) {
      print('DashboardData.fromJson $e');
    }
    this.totalUnsettledAmount = data['totalUnsettledAmount'] * 1.0;
    this.totalSettledAmount = data['totalSettledAmount'] * 1.0;
    this.totalBidAmount = data['totalBidAmount'] * 1.0;
    this.totalOfferAmount = data['totalOfferAmount'] * 1.0;
    this.averageBidAmount = data['averageBidAmount'] * 1.0;
    this.averageDiscountPerc = data['averageDiscountPerc'] * 1.0;

    this.totalPurchaseOrderAmount = data['totalPurchaseOrderAmount'] * 1.0;
    this.totalInvoiceAmount = data['totalInvoiceAmount'] * 1.0;

    this.date = data['date'];

    this.deliveryNotes = data['deliveryNotes'];
    this.purchaseOrders = data['purchaseOrders'];
    this.invoices = data['invoices'];
    this.closedOffers = data['closedOffers'];
    this.cancelledOffers = data['cancelledOffers'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalOpenOffers': totalOpenOffers,
        'totalUnsettledBids': totalUnsettledBids,
        'totalSettledBids': totalSettledBids,
        'totalBids': totalBids,
        'totalOffers': totalOffers,
        'totalPurchaseOrderAmount': totalPurchaseOrderAmount,
        'totalInvoiceAmount': totalInvoiceAmount,
        'totalOpenOfferAmount': totalOpenOfferAmount,
        'totalUnsettledAmount': totalUnsettledAmount,
        'totalSettledAmount': totalSettledAmount,
        'totalBidAmount': totalBidAmount,
        'totalOfferAmount': totalOfferAmount,
        'averageBidAmount': averageBidAmount,
        'averageDiscountPerc': averageDiscountPerc,
        'closedOffers': closedOffers,
        'date': date,
        'deliveryNotes': deliveryNotes,
        'purchaseOrders': purchaseOrders,
        'invoices': invoices,
        'cancelledOffers': cancelledOffers,
      };
}
