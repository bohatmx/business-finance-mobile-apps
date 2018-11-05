import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

abstract class PagerListener {
  onNext(int pageNumber);
  onBack(int startKey, int pageNumber);
  onPrompt(int pageLimit);
  onNoMoreData();
}

class Pager extends StatefulWidget {
  final PagerListener listener;
  final int currentStartKey;
  final int totalItems;
  final String itemName;
  final int pageLimit;
  final double elevation;
  static const Back = 1, Next = 2;

  Pager(
      {this.listener,
      this.currentStartKey,
      this.totalItems,
      this.itemName,
      this.elevation,
      this.pageLimit});
  static const DefaultPageLimit = 4;

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  static const numbers = [2, 4, 6, 8, 10, 20];
  final List<DropdownMenuItem<int>> items = List();
  int currentIndex = 0;
  int previousStartKey, pageNumber = 1;
  int localPageLimit;

  PagerItems pagerItems = PagerItems();

  void _buildItems() {
    print(
        '\n\n\n_Pager2State._buildItems widget.currentStartKey: ${widget.currentStartKey} currentIndex: $currentIndex');
    if (currentIndex == 0) {
      pagerItems.addItem(PagerItem(0, null));
      _setPageLimit();
    }
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
      items.add(item);
    });
  }

  void _forwardPressed() {
    currentIndex++;
    pageNumber++;
    if (pageNumber > int.parse(_getTotalPages())) {
      pageNumber--;
      print(
          '_PagerState._forwardPressed ... hey Toto, we not in Kansas nomore ....');
      widget.listener.onNoMoreData();
      return;
    } else {
      pagerItems.addItem(PagerItem(currentIndex, widget.currentStartKey));
      pagerItems.doPrint();
    }

    print(
        '++++++++++++++++++++++++++ Pager2._forwardPressed currentIndex: $currentIndex previousStartKey: $previousStartKey\n');
    widget.listener.onNext(currentIndex + 1);
  }

  void _rewindPressed() {
    currentIndex--;
    pageNumber--;
    if (pageNumber == 0) {
      pageNumber = 1;
      print(
          '_PagerState._rewindPressed ...... cant go back in time, Jojo Kiss!');
      widget.listener.onNoMoreData();
      return;
    }
    print(
        '\n\n\n_Pager2State._rewindPressed -------- currentIndex: $currentIndex previousStartKey: $previousStartKey');
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    if (currentIndex == 0) {
      pagerItems = PagerItems();
      pagerItems.addItem(PagerItem(0, null));
      pageNumber = 1;
      previousStartKey = null;
    } else {
      previousStartKey = pagerItems.items.elementAt(currentIndex).startKey;
    }
    print(
        '_Pager2State._rewindPressed -------- currentIndex: $currentIndex previousStartKey: $previousStartKey -- after manipulation');
    pagerItems.doPrint();
    widget.listener.onBack(previousStartKey, currentIndex);
  }

  void _onNumber(int value) async {
    print('Pager2._onNumber #################---------------> value: $value');
    SharedPrefs.savePageLimit(value);
    setState(() {
      localPageLimit = value;
    });
    widget.listener.onPrompt(localPageLimit);
  }

  @override
  void initState() {
    super.initState();
    _setPageLimit();
    _buildItems();
  }

  void _setPageLimit() async {
    if (localPageLimit == null) {
      localPageLimit = await SharedPrefs.getPageLimit();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (localPageLimit == null) {
      print('_PagerState.build setting localPageLimit: ${widget.pageLimit}');
      localPageLimit = widget.pageLimit;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: widget.elevation == null ? 16.0 : widget.elevation,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
              child: Row(
                children: <Widget>[
                  DropdownButton<int>(
                    items: items,
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
                    onTap: _rewindPressed,
                    child: Row(
                      children: <Widget>[
                        Text('Back', style: Styles.blackSmall),
                        IconButton(
                          icon: Icon(
                            Icons.fast_rewind,
                            color: Colors.black,
                            size: 36.0,
                          ),
                          onPressed: _rewindPressed,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
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
              padding:
                  const EdgeInsets.only(left: 20.0, bottom: 20.0, top: 10.0),
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
                    '${widget.totalItems}',
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
    );
  }

  String _getTotalPages() {
    int rem = widget.totalItems % localPageLimit;
    int pages = widget.totalItems ~/ localPageLimit;

    if (rem > 0) {
      pages++;
    }
    return '$pages';
  }
}

class PagerItem {
  final int index;
  final int startKey;

  PagerItem(this.index, this.startKey);
}

class PagerItems {
  final List<PagerItem> items = List();

  void addItem(PagerItem item) {
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
