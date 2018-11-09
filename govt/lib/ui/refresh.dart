import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/util/database.dart';

class Refresh {
  static Future refresh(GovtEntity govtEntity) async {
    print('Refresh_getSummaryData ..................................');

    var dashboardData =
        await ListAPI.getCustomerDashboardData(govtEntity.documentReference);
    SharedPrefs.saveDashboardData(dashboardData);

    await _getDetailData(govtEntity);
    return null;
  }

  static Future _getDetailData(GovtEntity govtEntity) async {
    print('\n\nRefresh_getDetailData ###################################');
    var pos =
        await ListAPI.getCustomerPurchaseOrders(govtEntity.documentReference);
    var invoices =
        await ListAPI.getCustomerInvoices(govtEntity.documentReference);
    var notes = await ListAPI.getDeliveryNotes(
        govtEntity.documentReference, 'govtEntities');
    await Database.savePurchaseOrders(PurchaseOrders(pos));
    await Database.saveInvoices(Invoices(invoices));
    await Database.saveDeliveryNotes(DeliveryNotes(notes));

    return null;
  }
}
