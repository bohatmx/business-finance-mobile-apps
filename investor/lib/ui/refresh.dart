import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/util/database.dart';

class Refresh {
  static Future refresh(Investor investor) async {
    print('Refresh.refresh ############## ===== refresh investor data');

    var dashboardData = await ListAPI.getInvestorDashboardData(
        investor.participantId, investor.documentReference);
    await SharedPrefs.saveDashboardData(dashboardData);
    await refreshBids(investor);
    await refreshOpenOffers();
    return null;
  }

  static Future refreshBids(Investor investor) async {
    var start = DateTime.now();
    var m = await ListAPI.getUnsettledInvoiceBidsByInvestor(
        investor.documentReference);
    await Database.saveInvoiceBids(InvoiceBids(m));
    var end = DateTime.now();
    print(
        '\n\nRefresh.refreshBids --------- ++++++++++++ investor bid data refreshed ${end.difference(start).inSeconds}');
    return null;
  }

  static Future refreshOpenOffers() async {
    var start = DateTime.now();
    var o = await ListAPI.getOpenOffers(300);
    await Database.saveOffers(Offers(o));
    var end = DateTime.now();
    print(
        '\n\nRefresh.refreshOpenOffers --------- ++++++++++++ offer data refreshed ${end.difference(start).inSeconds}');

    return null;
  }
}
