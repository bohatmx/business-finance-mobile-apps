import 'dart:convert';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:businesslibrary/api/shared_prefs.dart';

class ChatPage extends StatefulWidget {
  final ChatResponse chatResponse;

  ChatPage({this.chatResponse});

  @override
  State createState() => new ChatWindow();
}

class ChatWindow extends State<ChatPage>
    with TickerProviderStateMixin
    implements SnackBarListener {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Firestore fs = Firestore.instance;
  List<ChatMessage> chatMessages = List();
  bool _isWriting = false;
  User user;
  GovtEntity customer;
  Supplier supplier;
  Investor investor;
  String uType, participantId, org;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;
  @override
  void initState() {
    super.initState();
    _getCached();
    if (widget.chatResponse != null) {
      _chatResponse = widget.chatResponse;
    }
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    assert(user != null);
    print('ChatWindow._getCached ====== user: ${user.toJson()}');
    if (widget.chatResponse == null) {
      _getMessages();
    } else {
      _submitMsg(
        txt: _chatResponse.responseMessage,
        color: Colors.pink,
        addToFirestore: false,
        name: _chatResponse.responderName
      );
    }

    if (user.supplier != null) {
      uType = ChatMessage.SUPPLIER;
      supplier = await SharedPrefs.getSupplier();
      participantId = supplier.participantId;
      org = supplier.name;
    }
    if (user.govtEntity != null) {
      uType = ChatMessage.CUSTOMER;
      customer = await SharedPrefs.getGovEntity();
      participantId = customer.participantId;
      org = customer.name;
    }
    if (user.investor != null) {
      uType = ChatMessage.INVESTOR;
      investor = await SharedPrefs.getInvestor();
      participantId = investor.participantId;
      org = investor.name;
    }
    _configureFCM();
  }

  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');

    bool isRunningIOs = await isDeviceIOS();
    fcmToken = await _firebaseMessaging.getToken();
    print(
        '\n\nChatWindow._configureFCM : **************** fcmtoken: $fcmToken');
    if (fcmToken != null) {
      SharedPrefs.saveFCMToken(fcmToken);
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> map) async {
        prettyPrint(map,
            '\n\n################ Message from FCM ################# ${DateTime.now().toIso8601String()}');

        String messageType = 'unknown';
        String mJSON;
        try {
          if (isRunningIOs == true) {
            messageType = map["messageType"];
            mJSON = map['json'];
            print('configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print('configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            'configureFCM ************************** messageType: $messageType');
        try {
          switch (messageType) {
            case 'CHAT_RESPONSE':
              var m = ChatResponse.fromJson(json.decode(mJSON));
              prettyPrint(
                  m.toJson(), '\n\n########## FCM CHAT_RESPONSE MESSAGE :');
              onChatResponseMessage(m);
              break;
          }
        } catch (e) {
          print(
              'configureFCM - Houston, we have a problem with null listener somewhere');
          print(e);
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        print('configureMessaging onLaunch *********** ');
        prettyPrint(message, 'message delivered on LAUNCH!');
      },
      onResume: (Map<String, dynamic> message) {
        print('configureMessaging onResume *********** ');
        prettyPrint(message, 'message delivered on RESUME!');
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  //end of FCM methods ######################

  ChatResponse _chatResponse;
  void onChatResponseMessage(ChatResponse msg) {
    print(
        '\n\n\nChatResponseWindow.onChatResponseMessage --------------- message received');
    prettyPrint(msg.toJson(), '########## RESPONSE RECEIVED!!!');
    _chatResponse = msg;
    _submitMsg(
        txt: msg.responseMessage,
        addToFirestore: false,
        color: Colors.pink,
        name: 'Support Staff');

    setState(() {});
  }

  List<ChatResponse> chatResponses = List();
  void _getMessages() async {
    print('ChatWindow._getMessages %%%%%%%%%% start ......');
    chatMessages = await ListAPI.getChatMessages(user.userId);
    chatMessages.sort((xa, xb) => xa.date.compareTo(xb.date));
    chatMessages.forEach((m) {
      _submitMsg(
          txt: m.message,
          addToFirestore: false,
          color: Colors.indigo,
          name: user.firstName);
    });

    var start = DateTime.now();
    print(
        'ChatWindow._getMessages ... ################## found: ${chatMessages.length} ... finding responses ....');

    _messages.clear();
    chatMessages.sort((xa, xb) => xa.date.compareTo(xb.date));
    chatMessages.forEach((m) {
      _submitMsg(
          txt: m.message,
          addToFirestore: false,
          color: Colors.indigo,
          name: user.firstName);
      if (m.responses != null && m.responses.isNotEmpty) {
        m.responses.forEach((r) {
          _submitMsg(
              txt: r.responseMessage,
              addToFirestore: false,
              color: Colors.pink,
              name: r.responderName);
        });
      }
    });
    var end = DateTime.now();
    print(
        'ChatWindow._getMessages ########### getting responses took ${end.difference(start).inMilliseconds} ms');
  }

  void _addMessage(String text) async {
    assert(text != null);
    print(
        'ChatWindow._addMessage ------------------------------------> \n$text');

    assert(uType != null);
    assert(fcmToken != null);
    var cm = ChatMessage(
      date: DateTime.now().toIso8601String(),
      message: text,
      name: user.firstName,
      participantId: participantId,
      userId: user.userId,
      userType: uType,
      fcmToken: fcmToken,
      org: org,
    );
    if (_chatResponse != null) {
      prettyPrint(_chatResponse.toJson(), 'ChatResponse received from FCM');
      cm.responseFCMToken = _chatResponse.fcmToken;
    }
    prettyPrint(cm.toJson(), 'ChatMessage to send to DataAPI3 ..');
    try {
      ChatMessage resp = await DataAPI3.addChatMessage(cm);
      prettyPrint(resp.toJson(), '######### message from function call:');
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Message cannot be sent',
          listener: this,
          actionLabel: 'close');
    }
  }

  Widget _getColumn() {
    print(
        'ChatWindow._getColumn rebuilding ListView ...... ${_messages.length}');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Column(
          children: <Widget>[
            new Flexible(
                child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            )),
            new Divider(height: 4.0),
            new Container(
              child: _buildComposer(),
              decoration: new BoxDecoration(color: Colors.brown.shade100),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("BFN Support Chat"),
        elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getColumn(),
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  style: Styles.blackBoldSmall,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  decoration: new InputDecoration.collapsed(
                      hintText: "Enter some text to send a message"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                          child: new Text("Submit"),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  color: Colors.indigo,
                                  txt: _textController.text,
                                  name: user == null ? '' : user.firstName,
                                  addToFirestore: true)
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(
                                  color: Colors.indigo,
                                  txt: _textController.text,
                                  name: user == null ? '' : user.firstName,
                                  addToFirestore: true)
                              : null,
                        )),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.brown)))
              : null),
    );
  }

  void _submitMsg(
      {String txt,
      bool addToFirestore,
      Color color,
      String name}) {
    _textController.clear();
    assert(name != null);
    setState(() {
      _isWriting = false;
    });
    Msg msg = Msg(
      defaultUserName: name,
      txt: txt,
      color: color,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );

    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
    //
    if (addToFirestore) {
      _addMessage(txt);
    }
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
    return null;
  }
}

class Msg extends StatelessWidget {
  Msg({this.txt, this.animationController, this.defaultUserName, this.color});
  final String txt, defaultUserName;
  final AnimationController animationController;
  final Color color;

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0, left: 12),
              child: new CircleAvatar(
                  backgroundColor: color == null ? Colors.indigo : color,
                  child: new Text(defaultUserName[0])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                      defaultUserName == null ? 'Anonymous' : defaultUserName,
                      style: Theme.of(ctx).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt == null ? '' : txt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
