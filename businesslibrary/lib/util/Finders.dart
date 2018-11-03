import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/purchase_order.dart';

class PurchaseOrderResult {
  List<PurchaseOrder> purchaseOrders;
  int startKey;

  PurchaseOrderResult(this.purchaseOrders, this.startKey);
}

class Finder {
  static PurchaseOrderResult findPurchaseOrders(
      {int intDate, int pageLimit, List<PurchaseOrder> baseList}) {
    List<PurchaseOrder> list = List();
    if (baseList.isEmpty) {
      return PurchaseOrderResult(list, intDate);
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
        list.add(baseList.elementAt(i + index));
      }
    }
    print('\n\n_Pager._findOrders -----LOCAL CACHE: ${list.length}');
    int count = 1;
    list.forEach((x) {
      print(
          ' ${x.date} - ${x.intDate} ## $count ${x.purchaserName} for ${x.supplierName}');
      count++;
    });
    if (list.isNotEmpty) {
      return PurchaseOrderResult(list, list.last.intDate);
    } else {
      return PurchaseOrderResult(list, intDate);
    }
  }

  static List<Invoice> findInvoices(
      {int intDate,
      int currentStartKey,
      int pageLimit,
      List<Invoice> baseList}) {
    List<Invoice> list = List();
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
        list.add(baseList.elementAt(i + index));
      }
    }
    if (list.isNotEmpty) {
      currentStartKey = list.last.intDate;
    }
    print('\n\nFinder.findInvoices -----LOCAL CACHE: ${list.length}');
    int count = 1;
    list.forEach((x) {
      print(
          ' ${x.date} - ${x.intDate} ## $count ${x.customerName} for ${x.supplierName}');
      count++;
    });
    return list;
  }

  static List<DeliveryNote> findDeliveryNotes(
      {int intDate,
      int currentStartKey,
      int pageLimit,
      List<DeliveryNote> baseList}) {
    List<DeliveryNote> list = List();
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
        list.add(baseList.elementAt(i + index));
      }
    }
    if (list.isNotEmpty) {
      currentStartKey = list.last.intDate;
    }
    print('\n\nFinder.findDeliveryNotes -----LOCAL CACHE: ${list.length}');
    int count = 1;
    list.forEach((x) {
      print(
          ' ${x.date} - ${x.intDate} ## $count ${x.customerName} for ${x.supplierName}');
      count++;
    });
    return list;
  }
}
