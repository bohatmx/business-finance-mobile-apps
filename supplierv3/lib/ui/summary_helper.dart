import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';

class Refresh {
  static Future refresh(Supplier supplier) async {
    try {
      var dashboardData = await ListAPI.getSupplierDashboardData(
          supplier.participantId, supplier.documentReference);
      await SharedPrefs.saveDashboardData(dashboardData);
      prettyPrint(dashboardData.toJson(),
          '\n\nRefresh.refresh @@@@@@@@@@@ RETURNED dash data:');

      await _getDetailData(supplier);
    } catch (e) {
      throw e;
    }
    return null;
  }

  static Future _getDetailData(Supplier supplier) async {
    print('\n\n_DashboardState._getDetailData ############ get Supplier data');
    var m = await ListAPI.getSupplierPurchaseOrders(supplier.documentReference);
    await Database.savePurchaseOrders(PurchaseOrders(m));

    var n =
        await ListAPI.getDeliveryNotes(supplier.documentReference, 'suppliers');
    await Database.saveDeliveryNotes(DeliveryNotes(n));

    var p = await ListAPI.getInvoices(supplier.documentReference, 'suppliers');
    await Database.saveInvoices(Invoices(p));

    var o = await ListAPI.getOffersBySupplier(supplier.participantId);
    await Database.saveOffers(Offers(o));

    print('\n\nRefresh.refresh  ######### done refreshing supplier data');
    return null;
  }
}
