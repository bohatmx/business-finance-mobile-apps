import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const PeachSuccess = 0, PeachError = 1, PeachCancel = 2;

class BFNWebView extends StatefulWidget {
  final String url, title;

  BFNWebView({this.url, this.title});

  @override
  _BFNWebViewState createState() => _BFNWebViewState();
}

class _BFNWebViewState extends State<BFNWebView>
    implements PeachSuccessListener, PeachErrorListener, PeachCancelListener {
  final FirebaseMessaging fm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    FCM.configureFCM(
      context: context,
      peachSuccessListener: this,
      peachCancelListener: this,
      peachErrorListener: this,
    );
    fm.subscribeToTopic(FCM.TOPIC_PEACH_CANCEL);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_SUCCESS);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_ERROR);
    print('_BFNWebViewState.initState - subscribed to Peach topics');
  }

  void exit() {
    print('_BFNWebViewState.exit ********************************');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    try {
      return WebviewScaffold(
        url: widget.url == null ? 'https://www.youtube.com/' : widget.url,
        appBar: AppBar(
            title: Text(widget.title == null ? 'YouTube' : widget.title)),
        withJavascript: true,
        withLocalStorage: true,
      );
    } catch (e) {
      print(e);
      return Text(
        'WTF?',
        style: Styles.blackBoldReallyLarge,
      );
    }
  }

  @override
  onPeachCancel(Map map) {
    print('_BFNWebViewState.onPeachCancel');
    Navigator.pop(context, PeachCancel);
  }

  @override
  onPeachError(PeachNotification map) {
    print('_BFNWebViewState.onPeachError');
    Navigator.pop(context, PeachError);
  }

  @override
  onPeachSuccess(Map map) {
    print(
        '\n\n_BFNWebViewState.onPeachSuccess ############################# waiting for notify with result data....\n\n');
    Navigator.pop(context, PeachSuccess);
  }
}
