import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/data/chat_message.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChatPage extends StatefulWidget {
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
    _listenForResponses();
  }

  void _listenForResponses() async{
    print('ChatWindow._listenForResponses ++++++++++++++++++++++++++++++++++');
    Firestore fs = Firestore.instance;
    CollectionReference collectionReference = fs.collection('chatMessages').document(user.userId).collection('messages');
    collectionReference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((docChange) {
        if (docChange.type == DocumentChangeType.added) {
           var m = ChatMessage.fromJson(docChange.document.data);
           prettyPrint(m.toJson(), '########### firestore listener awoke, message: find response here????');
        }

      });
    });
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
      _submitMsg(m.message, false);
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
