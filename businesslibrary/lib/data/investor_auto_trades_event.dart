import 'package:businesslibrary/data/investor_auto_trades_session.dart';

class ExecuteInvestorAutoTradesEvent {
  String $class;
  InvestorAutoTradeSession session;

  ExecuteInvestorAutoTradesEvent({
    this.$class,
    this.session,
  });

  ExecuteInvestorAutoTradesEvent.fromJson(Map data) {
    this.$class = data['\$class'];
    this.session = data['session'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        '\$class': $class,
        'session': session,
      };
}
