import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/util/database.dart';

class Refresh {
  static Future refresh(Investor investor) async {
    print('Refresh.refresh ===== refresh investor data');

    var dashboardData = await ListAPI.getInvestorDashboardData(
        investor.participantId, investor.documentReference);
    await SharedPrefs.saveDashboardData(dashboardData);
    await _getDetailData(investor);
    return null;
  }

  static Future _getDetailData(Investor investor) async {
    var m = await ListAPI.getInvoiceBidsByInvestor(investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(m));
    var o = await ListAPI.getOpenOffers();
    await Database.saveOffers(Offers(o));

    print('\n\nRefresh._getDetailData --------- investor data refreshed');
    return null;
  }
}
