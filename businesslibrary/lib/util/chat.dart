import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:businesslibrary/api/shared_prefs.dart';

class Chat extends StatefulWidget {
  @override
  State createState() => new ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  final Firestore fs = Firestore.instance;
  List<ChatMessage> chatMessages = List();
  bool _isWriting = false;
  User user;
  GovtEntity customer;
  Supplier supplier;
  Investor investor;
  String uType, participantId, org;
  @override
  void initState() {
    super.initState();
    _getCached();
  }

  void _getCached() async {
    user = await SharedPrefs.getUser();
    assert(user != null);
    print('ChatWindow._getCached ====== user: ${user.toJson()}');
    _getMessages();

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
  }

  void _getMessages() async {
    print('ChatWindow._getMessages %%%%%%%%%% start ......');
    var qs = await fs
        .collection('chatMessages')
        .document(user.userId)
        .collection('messages')
        .orderBy('date')
        .getDocuments();
    qs.documents.forEach((doc) {
      chatMessages.add(ChatMessage.fromJson(doc.data));
    });

    chatMessages.forEach((m) {
      _messages.add(Msg(
        defaultUserName: user.firstName,
        animationController: new AnimationController(
            vsync: this, duration: new Duration(milliseconds: 800)),
      ));
    });
    print(
        'ChatWindow._getMessages ... ################## found: ${_messages.length}');
    setState(() {});
  }

  void _addMessage(String text) async {
    assert(text != null);
    print('ChatWindow._addMessage --> $text');

    assert(uType != null);
    var cm = ChatMessage(
      date: DateTime.now().toIso8601String(),
      message: text,
      name: user.firstName,
      participantId: participantId,
      userId: user.userId,
      userType: uType,
      org: org,
    );
    var ref = await fs
        .collection('chatMessages')
        .document(user.userId)
        .collection('messages')
        .add(cm.toJson())
        .catchError((err) {});
    print('ChatWindow._addMessage -- added message ${ref.path}');
    cm.path = ref.path;
    await ref.setData(cm.toJson());
    print('ChatWindow._addMessage -- updated message ${ref.path} with path.');
    //setState(() {});
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("BFN Support Chat"),
        elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
          reverse: true,
          padding: new EdgeInsets.all(6.0),
        )),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Colors.brown.shade100),
        ),
      ]),
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
                  onSubmitted: _submitMsg,
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
                              ? () => _submitMsg(_textController.text)
                              : null)
                      : new IconButton(
                          icon: new Icon(Icons.message),
                          onPressed: _isWriting
                              ? () => _submitMsg(_textController.text)
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

  void _submitMsg(String txt) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = Msg(
      defaultUserName: user.firstName,
      txt: txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
    //
    _addMessage(txt);
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
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
              margin: const EdgeInsets.only(right: 18.0),
              child: new CircleAvatar(child: new Text(defaultUserName[0])),
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
