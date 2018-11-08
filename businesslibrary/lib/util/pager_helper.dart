import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class PagerHelper extends StatelessWidget {
  final DashboardData dashboardData;
  final int pageNumber, totalPages;
  final double pageValue;
  final String itemName, type;
  final TextStyle labelStyle;
  final TextStyle totalValueStyle, pageValueStyle;

  static const PURCHASE_ORDER = 'po',
      DELIVERY_NOTE = 'note',
      INVOICE = 'invoice',
      OFFER = 'offer';
  PagerHelper(
      {this.dashboardData,
      this.pageNumber,
      this.pageValue,
      this.itemName,
      this.type,
      this.labelStyle,
      this.totalValueStyle,
      this.pageValueStyle,
      this.totalPages});

  @override
  Widget build(BuildContext context) {
    double getTotalValue() {
      if (dashboardData == null) {
        return 0.00;
      }
      switch (type) {
        case PURCHASE_ORDER:
          return dashboardData.totalPurchaseOrderAmount;
        case DELIVERY_NOTE:
          return dashboardData.totalDeliveryNoteAmount;
        case INVOICE:
          return dashboardData.totalInvoiceAmount;
        case OFFER:
          return dashboardData.totalOpenOfferAmount;
        default:
          return 999999.9999;
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 6.0),
          child: Row(
            children: <Widget>[
              Text(
                'Total Value:',
                style: labelStyle == null ? Styles.greyLabelSmall : labelStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${getFormattedAmount('${getTotalValue()}', context)}',
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
                style: labelStyle == null ? Styles.greyLabelSmall : labelStyle,
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
