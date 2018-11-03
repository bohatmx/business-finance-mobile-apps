import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class PagerHelper extends StatelessWidget {
  final DashboardData dashboardData;
  final int pageNumber, totalPages;
  final double pageValue;
  final String itemName;
  final TextStyle totalValueStyle, pageValueStyle;

  PagerHelper(
      {this.dashboardData,
      this.pageNumber,
      this.pageValue,
      this.itemName,
      this.totalValueStyle,
      this.pageValueStyle,
      this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 6.0),
          child: Row(
            children: <Widget>[
              Text(
                'Total Value:',
                style: Styles.whiteSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  dashboardData == null
                      ? '0.00'
                      : '${getFormattedAmount('${dashboardData.totalPurchaseOrderAmount}', context)}',
                  style: totalValueStyle == null
                      ? Styles.brownBoldMedium
                      : totalValueStyle,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Text(
                'Page Value:',
                style: Styles.whiteSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  pageValue == null
                      ? '0.00'
                      : getFormattedAmount('$pageValue', context),
                  style: pageValueStyle == null
                      ? Styles.blackBoldMedium
                      : pageValueStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
