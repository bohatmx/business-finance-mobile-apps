class AutoTradeStart {
  DateTime dateStarted;
  DateTime dateEnded;
  int possibleTrades;
  double possibleAmount;

  AutoTradeStart({
    this.dateStarted,
    this.dateEnded,
    this.possibleTrades,
    this.possibleAmount,
  });

  AutoTradeStart.fromJson(Map data) {
    this.dateStarted = data['dateStarted'];
    this.dateEnded = data['dateEnded'];
    this.possibleTrades = data['possibleTrades'];
    this.possibleAmount = data['possibleAmount'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dateStarted': dateStarted,
        'dateEnded': dateEnded,
        'possibleTrades': possibleTrades,
        'possibleAmount': possibleAmount,
      };
}
