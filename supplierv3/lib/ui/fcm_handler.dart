import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FCMessageListener {
  onPurchaseOrderMessage();
  onDeliveryAcceptance();
  onInvoiceAcceptance();
  onInvoiceBidMessage();
  onGovtInvoiceSettlement();
  onInvestorSettlement();
  onCompanySettlement();
}

configureAppMessaging(FCMessageListener listener) async {
  print(
      '\n\n################ configureAppMessaging starting ############## \n\n');
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      var messageType = message["messageType"];

      if (messageType == "PURCHASE_ORDER") {
        print(
            'configureMessaging: ############## receiving PURCHASE_ORDER message from FCM ....');
        var msg = message["json"];
        print('configureAppMessaging: ' + msg);
        try {
//          Map map = json.decode(message["json"]);
//          var po = new PurchaseOrder.fromJson(map);
//          assert(po != null);
          print('configureMessaging .... about to tell listener about po');
          listener.onPurchaseOrderMessage();
        } catch (e) {
          print('configureAppMessaging EERROR - fcm message bad');
          print(e);
        }
      }

      if (messageType == "DELIVERY_ACCEPTANCE") {
        print(
            'configureMessaging: ############## receiving DELIVERY_ACCEPTANCE message from FCM');
        listener.onDeliveryAcceptance();
      }
      //
      if (messageType == "INVOICE_ACCEPTANCE") {
        print(
            'configureMessaging: \n\n############## receiving INVOICE_ACCEPTANCE from FCM');
        try {
          listener.onInvoiceAcceptance();
        } catch (e) {
          print('configureMessaging ERROR $e');
        }
      }
      //

      if (messageType == "INVOICE_BID") {
        print(
            'configureMessaging: ############## receiving INVOICE_BID message from FCM: $message');

        listener.onInvoiceBidMessage();
      }
      if (messageType == "GOVT_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving GOVT_INVOICE_SETTLEMENT message from FCM');
        listener.onGovtInvoiceSettlement();
      }
      if (messageType == "INVESTOR_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving INVESTOR_INVOICE_SETTLEMENT message from FCM');
        listener.onInvestorSettlement();
      }
      if (messageType == "COMPANY_INVOICE_SETTLEMENT") {
        print(
            'configureMessaging: ############## receiving COMPANY_INVOICE_SETTLEMENT message from FCM');
        listener.onCompanySettlement();
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

  _firebaseMessaging.getToken().then((String token) async {
    assert(token != null);
    var oldToken = await SharedPrefs.getFCMToken();
    if (token != oldToken) {
      await SharedPrefs.saveFCMToken(token);
      print('configureMessaging fcm token saved: $token');
      _updateToken(token);
    } else {
      print('configureMessaging: token has not changed. no need to save');
    }
  }).catchError((e) {
    print('configureMessaging ERROR fcmToken $e');
  });
}

_updateToken(String token) async {
  print('_updateToken #################  update user FCM token');
  Firestore _firestore = Firestore.instance;
  var user = await SharedPrefs.getUser();
  if (user == null) {
    print('_updateToken - user NULL, no need to update -----');
    return;
  }
  var qs = await _firestore
      .collection('users')
      .where('userId', isEqualTo: user.userId)
      .getDocuments();
  User mUser = User.fromJson(qs.documents.first.data);
  mUser.fcmToken = token;
  await _firestore
      .collection('users')
      .document(qs.documents.first.documentID)
      .updateData(mUser.toJson());
  SharedPrefs.saveUser(mUser);
}
