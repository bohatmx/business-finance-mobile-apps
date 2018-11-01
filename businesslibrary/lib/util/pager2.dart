import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

abstract class Pager2Listener {
  onNext(int pageLimit, int pageNumber);
  onBack(int pageLimit, int startKey, int pageNumber);
  onPrompt();
}

class Pager2 extends StatefulWidget {
  final Pager2Listener listener;
  final String itemName;
  final int currentStartKey;
  static const Back = 1, Next = 2;
  Pager2({this.listener, this.itemName, this.currentStartKey});

  @override
  _Pager2State createState() => _Pager2State();
}

class _Pager2State extends State<Pager2> {
  static const numbers = [2, 4, 6, 8, 10, 20, 30, 40, 50, 60, 70, 80, 100];
  final List<DropdownMenuItem<int>> items = List();
  int currentIndex = 0;
  int previousStartKey;
  PagerItems pagerItems = PagerItems();

  void _buildItems() {
    print(
        '\n\n\n_Pager2State._buildItems widget.currentStartKey: ${widget.currentStartKey} currentIndex: $currentIndex');
    if (currentIndex == 0) {
      pagerItems.addItem(PagerItem(0, null));
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
    pagerItems.addItem(PagerItem(currentIndex, widget.currentStartKey));
    pagerItems.doPrint();

    print(
        '++++++++++++++++++++++++++ Pager2._forwardPressed currentIndex: $currentIndex previousStartKey: $previousStartKey\n');
    widget.listener.onNext(pageLimit, currentIndex + 1);
  }

  void _rewindPressed() {
    currentIndex--;
    print(
        '\n\n\n_Pager2State._rewindPressed -------- currentIndex: $currentIndex previousStartKey: $previousStartKey');
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    previousStartKey = pagerItems.items.elementAt(currentIndex).startKey;
    widget.listener.onBack(pageLimit, previousStartKey, currentIndex + 1);
  }

  int pageLimit = 10;
  void _onNumber(int value) async {
    print('Pager2._onNumber ---------------> value: $value');
    SharedPrefs.savePageLimit(value);
    setState(() {
      pageLimit = value;
    });
    widget.listener.onPrompt();
  }

  @override
  void initState() {
    super.initState();
    _buildItems();
    _setPageLimit();
  }

  void _setPageLimit() async {
    pageLimit = await SharedPrefs.getPageLimit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  DropdownButton<int>(
                    items: items,
                    hint: Text(widget.itemName),
                    onChanged: _onNumber,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                    child: Text(
                      '$pageLimit',
                      style: Styles.pinkBoldSmall,
                    ),
                  ),
                  InkWell(
                      onTap: _rewindPressed,
                      child: Text('Back', style: Styles.blackBoldSmall)),
                  IconButton(
                    icon: Icon(
                      Icons.fast_rewind,
                      color: Colors.indigo,
                      size: 36.0,
                    ),
                    onPressed: _rewindPressed,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: InkWell(
                        onTap: _forwardPressed,
                        child: Text('Next', style: Styles.blackBoldSmall)),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.fast_forward,
                      color: Colors.teal,
                      size: 36.0,
                    ),
                    onPressed: _forwardPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
