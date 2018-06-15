import 'package:flutter/material.dart';

///summary card used in dashboards
class SummaryCard extends StatelessWidget {
  final int total;
  final String label, date, lastLabel;
  final double amount;
  final TextStyle totalStyle;

  SummaryCard(
      {this.total,
      this.totalStyle,
      this.label,
      this.date,
      this.lastLabel,
      this.amount});
  final bigLabel = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    var opacity = 1.0;
    var height = 150.0, cHeight = 60.0, top = 10.0;
    if (total == 0) {
      opacity = 0.0;
      height = 90.0;
      cHeight = 0.0;
      top = 5.0;
    }

    return new Container(
      height: height,
      child: new Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 6.0,
          child: Column(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(top: top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      label,
                      style: bigLabel,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        '$total',
                        style: totalStyle,
                      ),
                    ),
                  ],
                ),
              ),
              new Padding(
                padding:
                    const EdgeInsets.only(left: 28.0, bottom: 10.0, top: 0.0),
                child: new Container(
                  height: cHeight,
                  child: new Opacity(
                    opacity: opacity,
                    child: Row(
                      children: <Widget>[
                        Text(
                          lastLabel,
                          style: TextStyle(color: Colors.grey),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            date,
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '$amount',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
