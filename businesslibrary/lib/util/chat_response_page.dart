import 'dart:convert';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:businesslibrary/api/shared_prefs.dart';

class ChatResponsePage extends StatefulWidget {
  @override
  State createState() => new ChatResponseWindow();
}

class ChatResponseWindow extends State<ChatResponsePage>
    with TickerProviderStateMixin
    implements SnackBarListener {
  final List<Msg> _messages = <Msg>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController _textController = new TextEditingController();
  final Firestore fs = Firestore.instance;
  List<ChatMessage> chatMessagesPending = List();
  bool _isWriting = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    _getMessages();
    _configureFCM();
  }
  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');


    bool isRunningIOs = await isDeviceIOS();

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
            print('FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('FCM.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print(
              'configureFCM -------- EXCEPTION handling platform detection');
        }

        print(
            'configureFCM ************************** messageType: $messageType');
        try {
          switch (messageType) {

            case 'CHAT_MESSAGE':
              var m = ChatMessage.fromJson(json.decode(mJSON));
              prettyPrint(m.toJson(), '\n\n########## FCM CHAT MESSAGE :');
              onChatMessage(m);
              break;
          }
        } catch (e) {
          print(
              'FCM.configureFCM - Houston, we have a problem with null listener somewhere');
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

    _subscribeToFCMTopics();
  }
  _subscribeToFCMTopics() async {

    _firebaseMessaging.subscribeToTopic(FCM.TOPIC_CHAT_MESSAGES_ADDED);

    print(
        '\n\n_DashboardState._subscribeToFCMTopics SUBSCRIBED to topis - ${FCM.TOPIC_CHAT_MESSAGES_ADDED}');
  }
  //end of FCM methods ######################

  void onChatMessage(ChatMessage msg) {
    print('ChatResponseWindow.onChatMessage - message received');
    chatMessagesPending.add(msg);
    setState(() {

    });
  }
  void _getMessages() async {
    print('ChatResponseWindow._getMessages Pending %%%%%%%%%% start ......');
    var qs = await fs
        .collection('chatResponsesPending')
        .where('hasResponse', isEqualTo: null)
        .orderBy('date')
        .getDocuments();
    qs.documents.forEach((doc) {
      chatMessagesPending.add(ChatMessage.fromJson(doc.data));
    });

    setState(() {});
  }

  ChatMessage selectedMessage;
  void _addMessage(String text) async {
    assert(text != null);
    print('ChatResponseWindow._addMessage --> $text');

    var cm = ChatResponse(
      dateTime: DateTime.now(),
      responseMessage: text,
      chatMessage: selectedMessage,
      responderName: 'Support Staff',
    );
    try {
      ChatResponse resp = await DataAPI3.addChatResponse(cm);
      prettyPrint(resp.toJson(), '###### function call returned response:');
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Chat response failed',
          listener: this,
          actionLabel: 'close');
    }
    //setState(() {});
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
        title: new Text("BFN Support Chat Response"),
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
                              ? () => _submitMsg(_textController.text, true)
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(_textController.text, true)
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

  void _submitMsg(String txt, bool addToFirestore) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = Msg(
      defaultUserName: 'Support Staff',
      txt: txt,
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
  Msg({this.txt, this.animationController, this.defaultUserName});
  final String txt, defaultUserName;
  final AnimationController animationController;

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
                  backgroundColor: Colors.pink,
                  child: new Text(defaultUserName[0] + defaultUserName[1], style: Styles.whiteSmall,)),
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
