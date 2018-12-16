import 'dart:convert';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/chat_response.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:businesslibrary/api/shared_prefs.dart';

class ChatResponsePage extends StatefulWidget {
  final ChatMessage chatMessage;

  ChatResponsePage({this.chatMessage});

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
  List<ChatMessage> chatMessagesPending = List(), filteredMessages = List();
  bool _isWriting = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;
  @override
  void initState() {
    super.initState();
    
    if (widget.chatMessage == null) {
      _getMessages();
    } else {
      selectedMessage = widget.chatMessage;
    }
    _configureFCM();
  }

  //FCM methods #############################
  _configureFCM() async {
    print(
        '\n\n\ ################ CONFIGURE FCM MESSAGE ###########  starting _firebaseMessaging');

    bool isRunningIOs = await isDeviceIOS();
    fcmToken = await _firebaseMessaging.getToken();
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
            print('FCM.configureFCM platform is iOS');
          } else {
            var data = map['data'];
            messageType = data["messageType"];
            mJSON = data["json"];
            print('FCM.configureFCM platform is Android');
          }
        } catch (e) {
          print(e);
          print('configureFCM -------- EXCEPTION handling platform detection');
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
    print('\n\nChatResponseWindow.onChatMessage - message received: ${msg.message}');
    selectedMessage = msg;
    _submitMsg(
      addToFirestore: false,
      color: Colors.indigo,
      txt: msg.message,
      defaultUserName: msg.name,
    );
  }

  void _getMessages() async {
    print('ChatResponseWindow._getMessages Pending %%%%%%%%%% start ......');
    var qs = await fs
        .collection('chatResponsesPending')
        .where('hasResponse', isEqualTo: null)
        .orderBy('date')
        .getDocuments();
    int cnt = 0;
    qs.documents.forEach((doc) {
      var msg = ChatMessage.fromJson(doc.data);
      chatMessagesPending.add(msg);
    });

    print(
        'ChatResponseWindow._getMessages --- pending messages: ${qs.documents.length}');
    setState(() {

    });
  }

  ChatMessage selectedMessage;
  List<DropdownMenuItem<ChatMessage>> dropdownMenuItems = List();
  Map<String, ChatMessage> map = Map();
  void _buildDropDownItems() {
    if (chatMessagesPending == null) return;
    print(
        'ChatResponseWindow._buildDropDownItems - chatMessagesPending: ${chatMessagesPending.length}');
  
    chatMessagesPending.forEach((m) {
      var x = DropdownMenuItem<ChatMessage>(
        value: m,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.assignment,
              color: getRandomColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${m.name}, ${getFormattedDateShortWithTime(m.date, context)}',
                style: Styles.blackBoldSmall,
              ),
            )
          ],
        ),
      );

      dropdownMenuItems.add(x);
    });
    setState(() {});
  }

  void _addMessage(String text) async {
    assert(text != null);
    print('ChatResponseWindow._addMessage --> $text');
    assert(selectedMessage != null);
    var cm = ChatResponse(
      dateTime: getUTCDate(),
      responseMessage: text,
      chatMessage: selectedMessage,
      responderName: 'Support Staff',
      fcmToken: fcmToken,
    );
    prettyPrint(cm.toJson(), '.... about to write this chatResponse:');
    try {
      ChatResponse resp = await DataAPI3.addChatResponse(cm);
      prettyPrint(resp.toJson(), '###### function call returned response:');
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Chat response failed',
          listener: this,
          actionLabel: 'close');
    }
    //setState(() {});
  }

  Widget _getColumn() {
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

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DropdownButton<ChatMessage>(
              onChanged: _onMessageSelected,
              items: dropdownMenuItems,
              elevation: 4,
              hint: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select User',
                  style: Styles.whiteBoldMedium,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  selectedMessage == null
                      ? ''
                      : '${selectedMessage.name} ${getFormattedDateShortWithTime(selectedMessage.date, context)}',
                  style: Styles.blackBoldMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    print('ChatResponseWindow.build #################### rebuild widget + _configureFCM');
    _configureFCM();
    _buildDropDownItems();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Support Chat"),
        elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
        bottom: _getBottom(),
        actions: <Widget>[
          IconButton(
            onPressed: _getRegularUsers,
            icon: Icon(Icons.people, color: Colors.black,),
          ),
        ],
      ),
      backgroundColor: Colors.brown.shade100,
      body: _getColumn(),
    );
  }
  _getRegularUsers() {
    print('ChatResponseWindow._getRegularUsers .................');
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
                              ? () => _submitMsg(txt: _textController.text, addToFirestore: true, defaultUserName: 'Support Staff')
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(txt: _textController.text, addToFirestore: true, defaultUserName: 'Support Staff')
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

  void _submitMsg({String txt, bool addToFirestore, Color color, String defaultUserName}) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    if (color == null) color = Colors.pink;
    Msg msg = Msg(
      defaultUserName: defaultUserName,
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

  void _onMessageSelected(ChatMessage msg) {
    prettyPrint(msg.toJson(), 'ChatResponseWindow._onMessageSelected ...');
    selectedMessage = msg;
    _messages.clear();
    _submitMsg(
        addToFirestore: false,
        txt: msg.message,
        color: Colors.indigo,
        defaultUserName: msg.name
    );

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
                  backgroundColor: color == null? Colors.pink : color,
                  child: new Text(
                    defaultUserName[0] + defaultUserName[1],
                    style: Styles.whiteSmall,
                  )),
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
