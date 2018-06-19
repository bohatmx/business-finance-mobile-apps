import 'package:flutter/material.dart';

///summary card used in dashboards
class SummaryCard extends StatelessWidget {
  final int total;
  final String label;
  final TextStyle totalStyle;

  SummaryCard({this.total, this.totalStyle, this.label});
  final bigLabel = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    var opacity = 1.0;
    var height = 90.0, cHeight = 60.0, top = 10.0;

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
            ],
          ),
        ),
      ),
    );
  }
}
