import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/util/invoice_bid_card.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/mypager.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:investor/app_model.dart';
import 'package:investor/ui/settle_all.dart';
import 'package:investor/ui/settle_invoice_bid.dart';
import 'package:flutter/scheduler.dart';
import 'package:scoped_model/scoped_model.dart';

class UnsettledBids2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<InvoiceBid> currentPage;
    ScrollController scrollController = ScrollController();
    InvestorAppModel appModel;
    BasePager basePager;
    void _setBasePager() {
      if (appModel == null) return;
      print(
          '\n\n\nUnsettledBids2.setBasePager appModel.pageLimit: ${appModel.pageLimit}, get first page');
      if (basePager == null) {
        basePager = BasePager(
          items: appModel.unsettledInvoiceBids,
          pageLimit: 12,
        );
      }

      if (currentPage == null)
        currentPage = List();
      else
        currentPage.clear();
      var page = basePager.getAllPages();
      page.forEach((f) {
        currentPage.add(f);
      });
    }
    void _onRefreshPressed() {
      print('UnsettledBids2._onRefreshPressed ..........');
//      if (appModel.investor == null) {
//        print('UnsettledBids2._onRefreshPressed calling refresh on model');
//        appModel.refreshModel();
//      }
      var page = basePager.getAllPages();
      page.forEach((f) {
        currentPage.add(f);
      });
    }
    Widget _getBody() {
      if (currentPage == null) {
        print('UnsettledBids2._getBody currentPage is null - return empty container');
        return Container();
      }
      print('UnsettledBids2._getBody ---- returning a ListView ...... ${currentPage.length} rows in currentPage');
      return ListView.builder(
          itemCount: currentPage == null ? 0 : currentPage.length,
          controller: scrollController,
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
              onTap: () {
                _checkBid(currentPage.elementAt(index));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4.0, left: 12.0, right: 12.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: InvoiceBidCard(
                    bid: currentPage.elementAt(index),
                    showItemNumber: true,
                  ),
                ),
              ),
            );
          });
    }

    return ScopedModelDescendant<InvestorAppModel>(
        builder: (context, _, model) {
      model.doPrint();
      appModel = model;
      _setBasePager();
      return Scaffold(
        appBar: AppBar(
          title: Text('Unsettled Test'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _onRefreshPressed,
            ),
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: _getBody(),
      );
    });
  }

  void doSomething() {}
  void _checkBid(InvoiceBid bid) {
    prettyPrint(bid.toJson(), '\n#### check this bid: ...................\n');
  }


}
