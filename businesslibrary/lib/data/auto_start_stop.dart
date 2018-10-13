class AutoTradeStart {
  String dateStarted;
  String dateEnded;
  int possibleTrades;
  double possibleAmount;
  int elapsedSeconds;

  AutoTradeStart({
    this.dateStarted,
    this.dateEnded,
    this.elapsedSeconds,
    this.possibleAmount,
    this.possibleTrades,
  });

  AutoTradeStart.fromJson(Map data) {
    this.dateStarted = data['dateStarted'];
    this.dateEnded = data['dateEnded'];
    this.possibleTrades = data['possibleTrades'];
    this.possibleAmount = data['possibleAmount'] * 1.00;
    this.elapsedSeconds = data['elapsedSeconds'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dateStarted': dateStarted,
        'dateEnded': dateEnded,
        'possibleTrades': possibleTrades,
        'possibleAmount': possibleAmount,
        'elapsedSeconds': elapsedSeconds,
      };
}
