import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class InvoiceBidCard extends StatelessWidget {
  final InvoiceBid bid;
  final bool showItemNumber;

  InvoiceBidCard({this.bid, this.showItemNumber});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: <Widget>[
                  showItemNumber == true
                      ? Container(
                          width: 20.0,
                          child: Text(
                            '${bid.itemNumber}',
                            style: Styles.blackBoldSmall,
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.date == null
                            ? '0.00'
                            : getFormattedDateLongWithTime(
                                '${bid.date}', context),
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 80.0,
                      child: Text('Bid Time', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.date == null
                            ? '0.00'
                            : getFormattedDateHour('${bid.date}'),
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 80.0,
                      child: Text('Reserved', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.reservePercent == null
                            ? '0.0%'
                            : '${bid.reservePercent.toStringAsFixed(1)} %',
                        style: Styles.purpleBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                      width: 80.0,
                      child: Text('Discount', style: Styles.greyLabelSmall)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid == null
                            ? '0.0%'
                            : '${bid.discountPercent.toStringAsFixed(1)} %',
                        style: Styles.blackBoldSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                children: <Widget>[
                  Text('Expires', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid == null
                            ? ''
                            : '${getFormattedDateLong(bid.endTime, context)}',
                        style: Styles.blackSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
              child: Row(
                children: <Widget>[
                  Text('Type', style: Styles.greyLabelSmall),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        bid.autoTradeOrder == null
                            ? 'Manual Trade'
                            : 'Automatic Trade',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text('Amount', style: Styles.greyLabelSmall),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      bid.amount == null
                          ? '0.00'
                          : getFormattedAmount('${bid.amount}', context),
                      style: Styles.tealBoldLarge),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
