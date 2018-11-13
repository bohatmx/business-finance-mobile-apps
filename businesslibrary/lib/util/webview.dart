import 'dart:async';

import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class BFNWebView extends StatefulWidget {
  final String url, title;

  BFNWebView({this.url, this.title});

  @override
  _BFNWebViewState createState() => _BFNWebViewState();
}

class _BFNWebViewState extends State<BFNWebView>
    implements
        PeachNotifyListener,
        PeachSuccessListener,
        PeachErrorListener,
        PeachCancelListener {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  final FirebaseMessaging fm = FirebaseMessaging();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  @override
  void initState() {
    super.initState();
    FCM.configureFCM(
      peachSuccessListener: this,
      peachCancelListener: this,
      peachErrorListener: this,
      peachNotifyListener: this,
    );
    fm.subscribeToTopic(FCM.TOPIC_PEACH_CANCEL);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_NOTIFY);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_SUCCESS);
    fm.subscribeToTopic(FCM.TOPIC_PEACH_ERROR);
    print('_BFNWebViewState.initState - subscribed to Peach topics');
//    // flutterWebviewPlugin.close();
//
//    // Add a listener to on destroy WebView, so you can make came actions.
//    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
//      print('_BFNWebViewState.initState - onDestroy');
//      exit();
//    });
//
//    // Add a listener to on url changed
//    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
//      print('_BFNWebViewState.initState - _onUrlChanged');
//    });
//    _onStateChanged =
//        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
//      print('_BFNWebViewState.initState - onStateChanged ${state.url}');
//      exit();
//    });
//
//    _onHttpError =
//        flutterWebviewPlugin.onHttpError.listen((WebViewHttpError error) {
//      if (mounted) {
//        print('_BFNWebViewState.initState - onHttpError');
//      }
//    });
  }

  void exit() {
    print('_BFNWebViewState.exit ********************************');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
//    _onDestroy.cancel();
//    _onUrlChanged.cancel();
//    _onStateChanged.cancel();
//    _onHttpError.cancel();

    flutterWebviewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url == null ? 'https://www.youtube.com/' : widget.url,
      appBar:
          AppBar(title: Text(widget.title == null ? 'YouTube' : widget.title)),
      withJavascript: true,
      withLocalStorage: true,
    );
  }

  @override
  onPeachCancel(Map map) {
    print('_BFNWebViewState.onPeachCancel');
    Navigator.pop(context, map);
  }

  @override
  onPeachError(PeachNotification map) {
    print('_BFNWebViewState.onPeachError');
    Navigator.pop(context, map);
  }

  @override
  onPeachNotify(PeachNotification m) {
    print(
        '_BFNWebViewState.onPeachNotify ###################################\n\n');
    prettyPrint(
        m.toJson(), '\n######### RESULT from Peach Notify: &&&&&&&&&&&&&&&');
    Navigator.pop(context, m);
  }

  @override
  onPeachSuccess(Map map) {
    print(
        '\n\n_BFNWebViewState.onPeachSuccess ############################# waiting for notify with result data\n\n');
    Navigator.pop(context, map);
  }
}
