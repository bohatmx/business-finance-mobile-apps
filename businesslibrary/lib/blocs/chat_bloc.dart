import 'dart:async';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/util/database.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/Finders.dart';

abstract class ChatBlocListener {
  onEvent(String message);
}
class ChatBloc {
  final StreamController<ChatResponse> _chatController = StreamController<ChatResponse>();

  ChatBloc() {
    print(
        '\n\nChatBloc.ChatBloc - CONSTRUCTOR - wait for chatt responses');

  }

  closeStream() {
    _chatController.close();
  }


  get chatResponseStream => _chatController.stream;

  receiveChatResponse(ChatResponse chatResponse) {
    print('ChatBloc.receiveChatResponse ... calling:  _chatController.sink.add(chatResponse);');
    _chatController.sink.add(chatResponse);
  }

}

final chatBloc = ChatBloc();
