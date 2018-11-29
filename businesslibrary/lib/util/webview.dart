import 'dart:async';

import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/peach.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const PeachSuccess = 20, PeachError = 19, PeachCancel = 29;

class BFNWebView extends StatefulWidget {
  final String url, title, paymentKey;

  BFNWebView({this.url, this.title, this.paymentKey});

  @override
  _BFNWebViewState createState() => _BFNWebViewState();
}

class _BFNWebViewState extends State<BFNWebView> implements PeachSuccessListener, PeachCancelListener, PeachErrorListener{
  final FirebaseMessaging fm = FirebaseMessaging();
  final Firestore fs = Firestore.instance;
  FCM _fcm = FCM();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => runOnceAfterBuild());



  }
  void runOnceAfterBuild() {
    print('\n\n_BFNWebViewState.runOnceAfterBuild ###################### ......');
//    _listenForError();
//    _listenForNotification();
//    _listenForSuccess();
//    print('_BFNWebViewState.runOnceAfterBuild - listening for Peach events');

    _fcm.configureFCM(
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
      print('\n\n_BFNWebViewState.build --------------- building widget .....');
      return WebviewScaffold(
        url: widget.url == null ? 'https://www.youtube.com/' : widget.url,
        appBar: AppBar(
            title: Text(widget.title == null ? 'YouTube' : widget.title)),
        withJavascript: true,
        withLocalStorage: true,
        withZoom: false,
        appCacheEnabled: true,
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

  onPeachNotify(Map map) {
    print(
        '\n\n_BFNWebViewState.onPeachNotify ############################# n\n');

    Navigator.pop(context, PeachSuccess);
  }

  StreamSubscription<QuerySnapshot> successStream, errorStream, cancelStream, notifyStream;

  void _listenForError() async {
    print('_BFNWebView_listenForError.........................');
    Query reference = fs
        .collection('peachErrors')
        .where('peachPaymentKey', isEqualTo: widget.paymentKey);

    errorStream = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        // Do something with change
        if (change.type == DocumentChangeType.added) {
          var errorNotification = PeachNotification.fromJson(
              change.document.data);
          if (errorNotification.payment_key == null) {
            print('\n_BFNWebViewState._listenForError: errorNotification.payment_key == null');
            return;
          }
          if (errorNotification.payment_key == widget.paymentKey) {
            prettyPrint(errorNotification.toJson(),
                '\n\n_BFNWebView_listenForError- DocumentChangeType = added, error added:');
            print('_BFNWebView_listenForError about to call errorStream.cancel();');
            errorStream.cancel();
            onPeachError(errorNotification);
          }


        } else {
          print('_BFNWebView_listenForError - this is NOT our error - IGNORE!');
        }

      });
    });
  }
  void _listenForNotification() async {
    print('_BFNWebView__listenForNotification........................');
    Query reference = fs
        .collection('peachTransactions')
        .where('payment_key', isEqualTo: widget.paymentKey);

    notifyStream = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        // Do something with change
        if (change.type == DocumentChangeType.added) {
          var notification = PeachNotification.fromJson(
              change.document.data);
          if (notification.payment_key == widget.paymentKey) {
            prettyPrint(notification.toJson(),
                '\n\n_BFNWebView__listenForNotification DocumentChangeType = added, error added:');
            print('_BFNWebView__listenForNotification about to call notifyStream.cancel();');
            notifyStream.cancel();
            onPeachSuccess(change.document.data);
          }


        } else {
          print('_BFNWebView__listenForNotification - this is NOT our notification - IGNORE!');
        }

      });
    });
  }
  void _listenForSuccess() async {
    print('_BFNWebView__listenForSuccess.......................');
    Query reference = fs
        .collection('peachSuccesses')
        .where('payment_key', isEqualTo: widget.paymentKey);

    successStream = reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        try {
          // Do something with change
          if (change.type == DocumentChangeType.added) {
            var notification = PeachNotification.fromJson(
                change.document.data);
            prettyPrint(change.document.data,
                '\n\_BFNWebView__listenForSuccess DocumentChangeType = added, success added:');
            if (notification.payment_key == widget.paymentKey) {
              print(
                  '_BFNWebView__listenForSuccess about to call successStream.cancel();');
              successStream.cancel();
              onPeachSuccess(change.document.data);
            }
          } else {
            print(
                '_BFNWebView__listenForSuccess - this is NOT our success - IGNORE!');
          }

        } catch (e) {
          print(e);
        }

      });
    });
  }

}
