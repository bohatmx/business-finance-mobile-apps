class Finder {
  static FindableResult find(
      {int intDate, int pageLimit, List<Findable> baseList}) {
    List<Findable> list = List();
    if (baseList == null || baseList.isEmpty) {
      return FindableResult(list, intDate);
    }
    int index = 0;
    bool isFound = false;
    for (var po in baseList) {
      if (intDate == po.intDate) {
        isFound = true;
        break;
      }
      index++;
    }
    if (!isFound) {
      index = 0;
    } else {
      index++;
      if (index >= baseList.length) {
        index = 0;
      }
    }
    for (var i = 0; i < pageLimit; i++) {
      if (i + index < baseList.length) {
        var findable = baseList.elementAt(i + index);
        findable.itemNumber = i + index + 1;
        list.add(findable);
      }
    }
    print('\n\n_Finder._find  -----Findables in LOCAL CACHE: ${list.length}');

    if (list.isNotEmpty) {
      return FindableResult(list, list.last.intDate);
    } else {
      return FindableResult(list, intDate);
    }
  }
}

abstract class Findable {
  int intDate;
  int itemNumber;
}

class FindableResult {
  List<Findable> items;
  int startKey;

  FindableResult(this.items, this.startKey);
}
