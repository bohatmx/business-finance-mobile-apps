import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supplierv3/ui/dashboard.dart';
import 'package:supplierv3/ui/signin_page.dart';
import 'package:supplierv3/ui/signup_page.dart';

void main() => runApp(new SupplierApp());

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
final FirebaseAuth _auth = FirebaseAuth.instance;

class SupplierApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'FinanceNetwork',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.teal,
          accentColor: Colors.deepOrange,
          fontFamily: 'Raleway'),
      home: new StartPage(title: 'Business Finance App - Supplier'),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => new _StartPageState();
}

class _StartPageState extends State<StartPage> {
  FirebaseUser firebaseUser;
  double fabOpacity = 0.3;
  Supplier supplier;
  User user;
  @override
  initState() {
    super.initState();
    _configMessaging();
    checkUser();
  }

  checkUser() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      print('_StartPageState.checkUser firebaseUser:  ${firebaseUser.email}');

      supplier = await SharedPrefs.getSupplier();
      user = await SharedPrefs.getUser();
      assert(supplier != null);
      await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Dashboard()),
      );
    }
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
      body: Stack(
        children: <Widget>[
          new Opacity(
            opacity: 0.4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fincash.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          new Center(
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: RaisedButton(
                    onPressed: _startSignUpPage,
                    color: Theme.of(context).primaryColor,
                    elevation: 8.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Start Supplier SignUp',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: _startSignInPage,
                    color: Colors.blue,
                    elevation: 8.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Sign into Supplier App',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),

      floatingActionButton: new Opacity(
        opacity: fabOpacity,
        child: new FloatingActionButton(
          onPressed: _startSignUpPage,
          tooltip: 'Increment',
          child: new Icon(FontAwesomeIcons.lockOpen),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startSignUpPage() async {
    print('_MyHomePageState._btnPressed ................');
    PrivateSectorType type = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignUpPage()),
    );
    print('_StartPageState._startSignUpPage  ${type.type}');
  }

  void _startSignInPage() async {
    print('_MyHomePageState._startSignInPage ...........');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignInPage()),
    );
  }
}

class BackImage extends StatelessWidget {
  final AssetImage _assetImage = AssetImage('assets/fin3.jpeg');
  @override
  Widget build(BuildContext context) {
    // var m = Image.asset('assets/fincash.jpg', fit: BoxFit.cover,)
    var image = new Opacity(
      opacity: 0.5,
      child: Image(
        image: _assetImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
    return Container(
      child: image,
    );
  }
}
