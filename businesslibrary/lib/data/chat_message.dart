import 'package:businesslibrary/data/misc_data.dart';

class ChatMessage extends BaseParticipant {
  String participantId;
  String name;
  String message, userId;
  String date, path, userType, org;

  ChatMessage({
    this.participantId,
    this.name,
    this.message,
    this.userId,
    this.path,
    this.userType,
    this.org,
    this.date,
  });

  static const String SUPPLIER = 'Supplier',
      CUSTOMER = 'Customer',
      STAFF = 'Staff',
      INVESTOR = 'Investor';
  ChatMessage.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.message = data['message'];
    this.date = data['date'];
    this.userId = data['userId'];
    this.path = data['path'];
    this.userType = data['userType'];
    this.org = data['org'];
  }
  Map<String, String> toJson() => <String, String>{
        'participantId': participantId,
        'name': name,
        'userId': userId,
        'message': message,
        'date': date,
        'path': path,
        'userType': userType,
        'org': org,
      };
}
