import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/pager_helper.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

abstract class Pager3Listener {
  onPage(List<Findable> items);
  onInitialPage(List<Findable> items);
  onNoMoreData();
}

class Pager3 extends StatefulWidget {
  final Pager3Listener listener;
  final String itemName, type;
  final int pageLimit;
  final double elevation;
  final bool addHeader;
  final List<Findable> items;
  static const Back = 1, Next = 2;

  Pager3(
      {this.listener,
      this.itemName,
      this.elevation,
      this.items,
      this.addHeader,
      this.type,
      this.pageLimit});
  static const DefaultPageLimit = 4;

  @override
  _Pager3State createState() => _Pager3State();
}

class _Pager3State extends State<Pager3> {
  static const numbers = [2, 4, 6, 8, 10, 20];
  final List<DropdownMenuItem<int>> dropDownItems = List();
  DashboardData dashboardData;
  int previousStartKey, pageNumber = 1, startKey;
  int localPageLimit = 2;
  List<Findable> currentPage = List();
  double totalValue = 0.00;

  @override
  void initState() {
    super.initState();
    print('_Pager3State.initState ..........................');
    _setPageLimit();
    _buildItems();
    _getDashData();
  }

  void _getDashData() async {
    print('_Pager3State._getDashData ...........................');
    if (widget.addHeader == true) {
      dashboardData = await SharedPrefs.getDashboardData();
      int mIndex = 0;
      widget.items.forEach((f) {
        widget.items.elementAt(mIndex).itemNumber = mIndex + 1;
        mIndex++;
        if (f is PurchaseOrder) {
          totalValue += f.amount;
          dashboardData.totalPurchaseOrderAmount = totalValue;
        }
        if (f is DeliveryNote) {
          totalValue += f.amount;
          dashboardData.totalDeliveryNoteAmount = totalValue;
        }
        if (f is Invoice) {
          totalValue += f.amount;
          dashboardData.totalInvoiceAmount = totalValue;
        }
        if (f is Offer) {
          totalValue += f.offerAmount;
          dashboardData.totalOpenOfferAmount = totalValue;
        }
      });
      print('_Pager3State._getDashData ...... calling _forwardPressed');
      var result = Finder.find(
          intDate: startKey, pageLimit: localPageLimit, baseList: widget.items);
      if (result.items.isNotEmpty) {
        currentPage = result.items;
        startKey = currentPage.last.intDate;
      }
      setState(() {});
      print(
          '_Pager3State._getDashData - calling widget.listener.onPage(currentPage)');
      widget.listener.onPage(currentPage);
    }
  }

  void _getInitialPage() {
    startKey = null;
    previousStartKey = null;
    pageNumber = 1;

    var result = Finder.find(
        intDate: startKey, pageLimit: localPageLimit, baseList: widget.items);
    if (result.items.isNotEmpty) {
      currentPage = result.items;
      startKey = result.startKey;
    }
    setState(() {});
    widget.listener.onPage(currentPage);
  }

  void _buildItems() {
    numbers.forEach((num) {
      var item = DropdownMenuItem<int>(
        value: num,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.apps,
              color: getRandomColor(),
            ),
            Text('$num'),
          ],
        ),
      );
      dropDownItems.add(item);
    });
  }

  void _forwardPressed() {
    pageNumber++;
    var titPages = int.parse(_getTotalPages());
    if (pageNumber > titPages) {
      pageNumber = 1;
      startKey = null;
      print(
          '_PagerState._forwardPressed ... hey Houston, aint no more ....pageNumber: $pageNumber');
      setState(() {});
      //widget.listener.onNoMoreData();
      //return;
    }
    previousStartKey = startKey;
    print(
        '++++++++++++++++++++++++++ Pager2._forwardPressed startKey: $startKey previousStartKey: $previousStartKey\n');
    var result = Finder.find(
        intDate: startKey, pageLimit: localPageLimit, baseList: widget.items);
    if (result.items.isNotEmpty) {
      currentPage = result.items;
      startKey = currentPage.last.intDate;
    }
    setState(() {});
    widget.listener.onPage(currentPage);
  }

  void _backPressed() {
    pageNumber--;
    if (pageNumber < 0) {
      pageNumber = 1;
      print(
          '_PagerState._backPressed ...... cant go back in time, Dani Daniels!');
      setState(() {});
      widget.listener.onNoMoreData();
    }
    if (pageNumber == 0) {
      pageNumber = 1;
      print('_PagerState._backPressed ...... cant go back in time, Jojo Kiss!');
      setState(() {});
      widget.listener.onNoMoreData();
      return;
    }
    startKey = previousStartKey;
    print(
        '\n\n\n_Pager2State._backPressed -------- startKey: $startKey  previousStartKey: $previousStartKey');
    if (pageNumber == 1) {
      _getInitialPage();
      return;
    }

    print(
        '_Pager2State._backPressed -------- startKey: $startKey  previousStartKey: $previousStartKey -- after manipulation');

    var result = Finder.find(
        intDate: startKey, pageLimit: localPageLimit, baseList: widget.items);
    if (result.items.isNotEmpty) {
      currentPage = result.items;
      startKey = result.startKey;
    }
    widget.listener.onPage(currentPage);
  }

  void _onNumber(int value) async {
    print('Pager2._onNumber #################---------------> value: $value');
    if (localPageLimit == value) {
      return;
    }
    localPageLimit = value;
    SharedPrefs.savePageLimit(value);
    _getInitialPage();
    setState(() {
      localPageLimit = value;
    });
  }

  void _setPageLimit() async {
    if (widget.pageLimit != null && localPageLimit == null) {
      localPageLimit = widget.pageLimit;
    }
    if (localPageLimit == null) {
      localPageLimit = await SharedPrefs.getPageLimit();
    }
    if (localPageLimit == null) {
      localPageLimit = 2;
    }
  }

  double _getPageValue() {
    double t = 0.00;
    currentPage.forEach((f) {
      if (f is PurchaseOrder) {
        t += f.amount;
      }
      if (f is DeliveryNote) {
        t += f.amount;
      }
      if (f is Invoice) {
        t += f.amount;
      }
      if (f is Offer) {
        t += f.offerAmount;
      }
    });
    return t;
  }

  @override
  Widget build(BuildContext context) {
    if (localPageLimit == null) {
      print('_PagerState.build setting localPageLimit: ${widget.pageLimit}');
      localPageLimit = widget.pageLimit;
    }
    return Column(
      children: <Widget>[
        widget.addHeader == true
            ? PagerHelper(
                dashboardData: dashboardData,
                itemName: widget.itemName,
                type: widget.type,
                pageValue: _getPageValue(),
                labelStyle: Styles.whiteSmall,
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Card(
            elevation: widget.elevation == null ? 16.0 : widget.elevation,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                  child: Row(
                    children: <Widget>[
                      DropdownButton<int>(
                        items: dropDownItems,
                        hint: Text('Per Page'),
                        onChanged: _onNumber,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                        child: Text(
                          '$localPageLimit',
                          style: Styles.pinkBoldSmall,
                        ),
                      ),
                      GestureDetector(
                        onTap: _backPressed,
                        child: Row(
                          children: <Widget>[
                            Text('Back', style: Styles.blackSmall),
                            IconButton(
                              icon: Icon(
                                Icons.fast_rewind,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              onPressed: _backPressed,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          onTap: _forwardPressed,
                          child: Row(
                            children: <Widget>[
                              Text('Next', style: Styles.blackSmall),
                              IconButton(
                                icon: Icon(
                                  Icons.fast_forward,
                                  color: Colors.black,
                                  size: 36.0,
                                ),
                                onPressed: _forwardPressed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, bottom: 20.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Page",
                        style: Styles.blueSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '$pageNumber',
                          style: Styles.blackSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'of',
                          style: Styles.blueSmall,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 60.0),
                        child: Text(
                          _getTotalPages(),
                          style: Styles.blackSmall,
                        ),
                      ),
                      Text(
                        '${widget.items.length}',
                        style: Styles.pinkBoldSmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          widget.itemName,
                          style: Styles.blackSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTotalPages() {
    if (widget.items == null || localPageLimit == null) {
      return '0';
    }
    int rem = widget.items.length % localPageLimit;
    int pages = widget.items.length ~/ localPageLimit;

    if (rem > 0) {
      pages++;
    }
    return '$pages';
  }
}
