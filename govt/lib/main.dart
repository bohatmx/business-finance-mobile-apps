import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/util.dart';

void main() => runApp(new MyApp());

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: new MyHomePage(title: 'Business Finance - Govt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FirebaseUser firebaseUser;

  @override
  initState() {
    super.initState();
    _configMessaging();
    checkUser();
  }

  checkUser() async {
    firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      print('_MyHomePageState.checkUser firebaseUser:  ${firebaseUser.email}');
    } else {
      signUp();
    }
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
  }

  void _configMessaging() async {
    print(
        '_MyHomePageState._configMessaging starting _firebaseMessaging config shit');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
//        P.mprint(widget,
//            "onMessage, AccountDetails: expecting wallet, payment or error mesage via FCM:\n: $message");
//        var messageType = message["messageType"];
//        if (messageType == "PAYMENT") {
//          P.mprint(widget,
//              "AccountDetails Receiving PAYMENT message )))))))))))))))))))))))))))))))))");
//          Map map = json.decode(message["json"]);
//          var payment = new Payment.fromJson(map);
//          assert(payment != null);
//          P.mprint(widget, "received payment, details below");
//          payment.printDetails();
//          receivedPayment(payment);
//        }
//
//        if (messageType == "PAYMENT_ERROR") {
//          P.mprint(widget,
//              "AccountDetails Receiving PAYMENT_ERROR message ################");
//          Map map = json.decode(message["json"]);
//          PaymentFailed paymentFailed = new PaymentFailed.fromJson(map);
//          assert(paymentFailed != null);
//          P.mprint(widget, paymentFailed.toJson().toString());
//          P.mprint(widget,
//              "What do we do now, Boss? payment error, Chief ....maybe show a snackbar?");
//
//          _showSnackbar("Payment failed, try again later. Sorry!");
//        }
      },
      onLaunch: (Map<String, dynamic> message) {},
      onResume: (Map<String, dynamic> message) {},
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      var oldToken = await SharedPrefs.getFCMToken();
      if (token != oldToken) {
        await SharedPrefs.saveFCMToken(token);
        print('_MyHomePageState._configMessaging fcm token saved: $token');
      }
    }).catchError((e) {
      print('_MyHomePageState._configMessaging ERROR fcmToken ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //resource:com.oneconnect.biz.GovtEntity#0445
  void signUp() async {
    SignUp signUp = SignUp(Util.getURL());
    var user = User(
        firstName: 'Johnson',
        lastName: 'Drogueman',
        idNumber: '7609124660081',
        email: 'drouman@golf.com',
        password: 'kktiger3x',
        isAdministrator: 'true',
        userType: User.govtStaff,
        govtEntity:
            'resource:com.oneconnect.biz.GovtEntity#09f19ec0-4800-11e8-9c07-5ba79e5d711f');

    var result = await signUp.signUp(user);
    switch (result) {
      case SignUp.Success:
        print('_MyHomePageState.signUp --- SUCCESS !!!');
        break;
      case SignUp.ErrorCreatingFirebaseUser:
        print('_MyHomePageState.signUp ErrorCreatingFirebaseUser ');
        break;
      case SignUp.ErrorFireStore:
        print('_MyHomePageState.signUp ErrorFireStore ');
        break;
      case SignUp.ErrorFirebaseUserExists:
        print('_MyHomePageState.signUp ErrorFirebaseUserExists ');
        break;
      case SignUp.ErrorBlockchain:
        print('_MyHomePageState.signUp ErrorBlockchain ');
        break;
      case SignUp.ErrorMissingOrInvalidData:
        print('_MyHomePageState.signUp  ErrorMissingOrInvalidData');
        break;
    }
  }
}
