import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
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
  DashboardData dashboardData = DashboardData();
  int pageNumber = 1, startKey;
  int localPageLimit;
  List<Findable> currentPage = List();
  double totalValue = 0.00;
  KeyItems keyItems = KeyItems();
  int currentIndex = 0;
  Pages pages = Pages();

  @override
  void initState() {
    super.initState();
    print('_Pager3State.initState ..........................');
    _setPageLimit();
    _buildNumberItems();
    _setItemNumbers();
    _getDashData();
  }

  void _setItemNumbers() {
    print('_Pager3State._setItemNumbers - getting itemNumbers into items');
    int count = 1;
    widget.items.forEach((o) {
      o.itemNumber = count;
      count++;
    });
  }

  void _getDashData() async {
    print('\n_Pager3State._getDashborad Data ...........................');
    if (widget.addHeader == true) {
      dashboardData = DashboardData();
      print('_Pager3State._getDashData ...... calling _getInitialPage');
    }
    setState(() {});
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
    _buildPages();
    _getInitialPage();
  }

  void _buildPages() {
    /////
    if (widget.items == null) {
      return;
    }
    var rem = widget.items.length % localPageLimit;
    var numPages = widget.items.length ~/ localPageLimit;
    if (rem > 0) {
      numPages++;
    }
    startKey = null;
    currentIndex = 0;
    pageNumber = 1;

    for (var i = 0; i < numPages; i++) {
      //build page
      var result = Finder.find(
          intDate: startKey, pageLimit: localPageLimit, baseList: widget.items);
      var page = Page(
          index: currentIndex, pageNumber: pageNumber, items: result.items);
      pages.addPage(page);
      currentIndex++;
      pageNumber++;
      startKey = result.startKey;
    }
    pages.doPrint();
  }

  void _getInitialPage() {
    print('\n\n\n_Pager3State._getInitialPage .... starting over ............');

    var page = pages.getPage(0);
    currentPage = page.items;
    currentIndex = 0;
    pageNumber = 1;
    setState(() {});

    print(
        '_Pager3State._getInitialPage ############# calling widget.listener.onInitialPage with ${currentPage.length} rows');
    widget.listener.onInitialPage(currentPage);
  }

  void _buildNumberItems() {
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
    currentIndex++;
    pageNumber++;
    if (pageNumber > pages._pages.length) {
      print(
          '_PagerState._forwardPressed ... hey Toto, we not in Kansas nomore ....pageNumber: $pageNumber');
      pageNumber = 1;
      startKey = null;
      currentIndex = 0;
    }

    currentPage = pages.getPage(currentIndex).items;
    print(
        '\n#### FORWARD pressed ---- page below to listener: currentIndex: $currentIndex');
    doPrint();

    setState(() {});
//    currentPage.forEach((p) {
//      print(
//          '_Pager3State._forwardPressed ####### item: ${p.itemNumber} date: ${p.intDate}');
//    });
    widget.listener.onPage(currentPage);
  }

  void _backPressed() {
    print(
        '_Pager3State._backPressed currentIndex: $currentIndex at the top, pageNumber: $pageNumber');
    currentIndex--;
    pageNumber--;
    if (pageNumber == 0) {
      pageNumber = 1;
      currentIndex = 0;
      print(
          '_PagerState._rewindPressed ...... cant go back in time, Jojo Kiss!');
      widget.listener.onNoMoreData();
      return;
    }

    if (currentIndex < 0) {
      currentIndex = 0;
    }

    print(
        '_Pager3State._backPressed currentIndex: $currentIndex after process, , pageNumber: $pageNumber - about to get page');

    currentPage = pages.getPage(currentIndex).items;
    print(
        '######## BACK pressed: -------- currentPage - to listener ##################### currentIndex: $currentIndex');
    doPrint();
//    currentPage.forEach((p) {
//      print(
//          '_Pager3State._backPressed ####### item: ${p.itemNumber} date: ${p.intDate}');
//    });
    widget.listener.onPage(currentPage);
  }

  void doPrint() {
    currentPage.forEach((i) {
      if (i is Offer) {
        print(
            'itemNumber: ${i.itemNumber} intDate: ${i.intDate} supplier: ${i.supplierName} customer: ${i.customerName} ${i.offerAmount}');
      }
      if (i is PurchaseOrder) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.purchaserName} ${i.amount}');
      }
      if (i is DeliveryNote) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
      if (i is Invoice) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
    });
  }

  void _onNumber(int value) async {
    print('Pager._onNumber #################---------------> value: $value');
    if (localPageLimit == value) {
      return;
    }
    localPageLimit = value;
    await SharedPrefs.savePageLimit(value);
    pages = Pages();
    _buildPages();
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
      if (f is InvoiceBid) {
        t += f.amount;
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

class KeyItem {
  final int index;
  final int startKey;

  KeyItem(this.index, this.startKey);
}

class KeyItems {
  final List<KeyItem> items = List();

  void addItem(KeyItem item) {
//    items.add(item);
    var isFound = false;
    items.forEach((i) {
      if (i.startKey == item.startKey) {
        isFound = true;
      }
    });
    if (!isFound) {
      items.add(item);
    }
  }

  doPrint() {
    print('\n\n################################################');
    items.forEach((i) {
      print('keyItem:index: ${i.index} startKey: ${i.startKey}');
    });
    print('################################################\n\n');
  }
}

class Page {
  final int pageNumber;
  final int index;
  final List<Findable> items;

  Page({this.pageNumber, this.items, this.index});
}

class Pages {
  List<Page> _pages = List();

  void addPage(Page page) {
    _pages.add(page);
  }

  Page getPage(int index) {
    print('Pages.getPage ........... index: $index');
    var page = _pages.elementAt(index);
    page.items.forEach((i) {
      if (i is Offer) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.offerAmount}');
      }
      if (i is PurchaseOrder) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.purchaserName} ${i.amount}');
      }
      if (i is DeliveryNote) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
      if (i is Invoice) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
      }
      if (i is InvoiceBid) {
        print(
            'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.investorName} reservePercent: ${i.reservePercent} ${i.amount}');
      }
    });
    return page;
  }

  doPrint() {
    print('\n\n##############################################');
    print('Pages.doPrint .... number of pages: ${_pages.length}');
    _pages.forEach((p) {
      print('\n\npageNumber: ${p.pageNumber} items: ${p.items.length}');
      p.items.forEach((i) {
        if (i is Offer) {
          print(
              'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.offerAmount}');
        }
        if (i is PurchaseOrder) {
          print(
              'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.purchaserName} ${i.amount}');
        }
        if (i is DeliveryNote) {
          print(
              'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
        }
        if (i is Invoice) {
          print(
              'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.supplierName} customer: ${i.customerName} ${i.amount}');
        }
        if (i is InvoiceBid) {
          print(
              'itemNumber: ${i.itemNumber} ${i.intDate} ${i.date} ${i.investorName} reservePercent: ${i.reservePercent} ${i.amount}');
        }
      });
    });
    print('\n##############################################\n\n');
  }
}
