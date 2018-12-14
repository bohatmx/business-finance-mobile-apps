import 'package:businesslibrary/data/chat_message.dart';

class ChatResponse {
  String documentPath;
  String responderName;
  String responseMessage;
  ChatMessage chatMessage;
  DateTime dateTime;

  ChatResponse({
    this.documentPath,
    this.responderName,
    this.responseMessage,
    this.dateTime,
    this.chatMessage,
  });

  static const String SUPPLIER = 'Supplier',
      CUSTOMER = 'Customer',
      STAFF = 'Staff',
      INVESTOR = 'Investor';
  ChatResponse.fromJson(Map data) {
    this.documentPath = data['documentPath'];
    this.responderName = data['responderName'];
    this.responseMessage = data['responseMessage'];
    this.dateTime = data['dateTime'];

    if (data['chatMessage'] != null) {
      this.chatMessage = ChatMessage.fromJson(data['chatMessage']);
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['documentPath'] = this.documentPath;
    map['responderName'] = this.responderName;
    if (this.chatMessage != null) {
      map['chatMessage'] = this.chatMessage.toJson();
    }

    map['responseMessage'] = this.responseMessage;
    map['dateTime'] = this.dateTime;
    return map;
  }
}
