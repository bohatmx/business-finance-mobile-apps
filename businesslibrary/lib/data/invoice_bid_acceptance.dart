import 'package:meta/meta.dart';

class InvoiceBidAcceptance {
  String acceptanceId;
  DateTime date;
  String invoiceBid;
  String user;

  InvoiceBidAcceptance(
      {@required this.acceptanceId,
      @required this.date,
      @required this.invoiceBid,
      @required this.user});

  InvoiceBidAcceptance.fromJSON(Map data) {
    this.acceptanceId = data['acceptanceId'];
    this.date = data['date'];
    this.invoiceBid = data['invoiceBid'];
    this.user = data['user'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'acceptanceId': acceptanceId,
        'date': date,
        'invoiceBid': invoiceBid,
        'user': user
      };
}
