import 'package:flutter/material.dart';

///summary card used in dashboards
class SummaryCard extends StatelessWidget {
  final int total;
  final String label;
  final TextStyle totalStyle;

  SummaryCard({this.total, this.totalStyle, this.label});
  final bigLabel = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 18.0,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    var height = 70.0, top = 4.0;

    return new Container(
      height: height,
      child: new Padding(
        padding: const EdgeInsets.only(left: 28.0, right: 28.0, bottom: 12.0),
        child: Card(
          elevation: 4.0,
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
