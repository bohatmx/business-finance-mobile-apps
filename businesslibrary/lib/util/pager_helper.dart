import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class PagerHelper extends StatelessWidget {
  final DashboardData dashboardData;
  final int pageNumber, totalPages;
  final double pageValue;
  final String itemName;

  PagerHelper(
      {this.dashboardData,
      this.pageNumber,
      this.pageValue,
      this.itemName,
      this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
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
                  style: Styles.brownBoldMedium,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
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
                  style: Styles.blackBoldMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
