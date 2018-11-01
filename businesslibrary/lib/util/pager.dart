import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

abstract class PagerListener {
  onEvent(int action, int number);
  onPrompt();
}

class Pager extends StatefulWidget {
  final PagerListener listener;
  final String itemName;
  static const Back = 1, Next = 2;
  Pager({this.listener, this.itemName});

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  static const numbers = [2, 4, 6, 8, 10, 20, 30, 40, 50, 60, 70, 80, 100];
  final List<DropdownMenuItem<int>> items = List();
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
      items.add(item);
    });
  }

  void _forwardPressed() {
    print('Pager._forwardPressed');
    widget.listener.onEvent(Pager.Next, number);
  }

  void _rewindPressed() {
    print('Pager._rewindPressed');
    widget.listener.onEvent(Pager.Back, number);
  }

  int number = 10;
  void _onNumber(int value) async {
    print('Pager._onNumber value: $value');
    SharedPrefs.savePageLimit(value);
    setState(() {
      number = value;
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
    number = await SharedPrefs.getPageLimit();
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
                      '$number',
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

class KeyItem {
  final int index;
  final int startKey;

  KeyItem(this.index, this.startKey);
}

class KeyItemX {
  final int index;
  final String startKey;

  KeyItemX(this.index, this.startKey);
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

class KeyItemsX {
  final List<KeyItemX> items = List();

  void addItem(KeyItemX item) {
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
