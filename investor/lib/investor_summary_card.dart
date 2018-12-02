import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/app_model.dart';
import 'package:investor/investor_model_bloc.dart';

class InvestorSummaryCard extends StatelessWidget {
  final InvestorAppModel2 appModel;
  final BuildContext context;
  final InvestorCardListener listener;

  InvestorSummaryCard({this.appModel, this.context, this.listener});

  Widget _getTotalBids() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            '# Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            appModel == null || appModel.dashboardData == null? '0' : '${appModel.dashboardData.totalBids}',
            style: Styles.blackBoldMedium,
          ),
        ),
      ],
    );
  }

  double _getValue() {
    if (appModel.dashboardData.totalBidAmount == null) return 0.0;
//    var t = 0.0;
//    appModel.unsettledInvoiceBids.forEach((bid) {
//      t += bid.amount;
//    });
    return appModel.dashboardData.totalBidAmount;
  }
  Widget _getTotalBidValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 70.0,
          child: Text(
            'Total Bids',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            appModel == null
                ? '0.00'
                : '${getFormattedAmount('${_getValue()}', context)}',
            style: Styles.blackBoldLarge,
          ),
        ),
      ],
    );
  }

  Widget _getAverageDiscount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Avg Discount',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            appModel == null ? '0.0%' : _getAvgDiscount(),
            style: Styles.purpleBoldSmall,
          ),
        ),
      ],
    );
  }

  String _getAvgDiscount() {
    if (appModel == null) {
      return '0.0%';
    }
    if (appModel.unsettledInvoiceBids == null) {
      return '0.0%';
    }
    var totDisc = 0.0;
    appModel.unsettledInvoiceBids.forEach((b) {
      totDisc += b.discountPercent;
    });
    var d = totDisc / appModel.unsettledInvoiceBids.length;
    return appModel.dashboardData.averageDiscountPerc.toStringAsFixed(2) + '%';
  }

  double _getAvg() {
    if (appModel == null) {
      return 0.0;
    }
    if (appModel.unsettledInvoiceBids == null) {
      return 0.0;
    }
    var t = 0.0;
    appModel.unsettledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    var avg = t / appModel.unsettledInvoiceBids.length;
    return avg;
  }
  Widget _getAverageBidAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100.0,
          child: Text(
            'Average Bid',
            style: Styles.greyLabelSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text(
            appModel == null
                ? '0'
                : '${getFormattedAmount('${appModel.dashboardData.averageBidAmount}', context)}',
            style: Styles.blackSmall,
          ),
        ),
      ],
    );
  }

  double totalUnsettledBids() {
    var t = 0.00;
    if (appModel == null) {
      return 0.0;
    }
    if (appModel.unsettledInvoiceBids == null) {
      return 0.0;
    }
    appModel.unsettledInvoiceBids.forEach((b) {
      t += b.amount;
    });
    return appModel.dashboardData.totalUnsettledAmount;
  }
  @override
  Widget build(BuildContext context) {
//    print('\n\nInvestorSummaryCard.build build ...........##############..........');
//    if (appModel.dashboardData != null) {
//      appModel.doPrint();
//      print('InvestorSummaryCard.build ============= appModel.dashboardData is not null');
//    } else {
//      print('InvestorSummaryCard.build ============= appModel.dashboardData is null ========= wtf?');
//    }
    return Card(
      elevation: 2.0,
      color: Colors.brown.shade50,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getTotalBids(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 20.0),
            child: _getTotalBidValue(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getAverageBidAmount(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0),
            child: _getAverageDiscount(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  appModel == null || appModel.dashboardData == null
                      ? '0'
                      : '${appModel.dashboardData.totalUnsettledBids}',
                  style: Styles.blackSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 5.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Unsettled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  appModel == null
                      ? '0.00'
                      : '${getFormattedAmount('${totalUnsettledBids()}', context)}',
                  style: Styles.pinkBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled  Bids',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  appModel == null || appModel.dashboardData == null
                      ? '0'
                      : '${appModel.dashboardData.totalSettledBids}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Text(
                    'Settled Total',
                    style: Styles.greyLabelSmall,
                  ),
                ),
                Text(
                  appModel == null
                      ? '0.00'
                      : '${getFormattedAmount('${appModel.dashboardData.totalSettledAmount}', context)}',
                  style: Styles.blackBoldSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
            child: RaisedButton(
              elevation: 6.0,
              color: Colors.indigo.shade200,
              onPressed: _onStartCharts,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Show Charts',
                  style: Styles.whiteSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStartCharts() {
    if (listener != null) {
      listener.onCharts();
    }
  }

}

abstract class InvestorCardListener {
  onRefresh();
  onCharts();
}