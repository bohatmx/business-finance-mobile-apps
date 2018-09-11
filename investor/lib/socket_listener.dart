import 'dart:convert';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/investor_auto_trades_session.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:web_socket_channel/io.dart';

class TradeUtil {
  static var channel =
      new IOWebSocketChannel.connect("ws://bfnrestv3.eu-gb.mybluemix.net");

  static listenForExecuteInvestorAutoTradesEvent(
      InvestorAutoTradeListener listener) async {
    print(
        'listenForExecuteInvestorAutoTradesEvent ------- starting  #################################');
    channel.stream.listen((message) {
      print(
          '\n\n\n############# listenForExecuteInvestorAutoTradesEvent WebSocket  ###################: \n\n\n' +
              message);
      try {
        var data = json.decode(message);
        var m = data['session'];
        if (m == null) {
          return;
        }
        var session = InvestorAutoTradeSession.fromJson(m);
        prettyPrint(session.toJson(),
            'InvestorAutoTradeSession ===============> from web socket: ');
        var api = DataAPI(getURL());
        session.offers.forEach((off) async {
          await api.closeOfferOnFirestore(off.split('#').elementAt(1));
        });
        listener.onAutoTradeComplete(session);
      } catch (e) {
        print('listenForExecuteInvestorAutoTradesEvent ERROR $e');
      }
    });
  }
}

abstract class InvestorAutoTradeListener {
  onAutoTradeComplete(InvestorAutoTradeSession session);
}
