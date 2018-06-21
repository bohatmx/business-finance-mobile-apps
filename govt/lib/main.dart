import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/dashboard.dart';
import 'package:govt/ui/signin_page.dart';
import 'package:govt/ui/signup_page.dart';

void main() => runApp(new GovtApp());

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
final FirebaseAuth _auth = FirebaseAuth.instance;

class GovtApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'FinanceNetwork',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.teal,
        fontFamily: 'Raleway',
      ),
      home: new StartPage(title: 'Business Finance App - Govt'),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartPageState createState() => new _StartPageState();
}

class _StartPageState extends State<StartPage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseUser firebaseUser;
  double fabOpacity = 0.3;
  @override
  initState() {
    super.initState();
    checkUser();
  }

  checkUser() async {
    firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      print('_StartPageState.checkUser firebaseUser:  ${firebaseUser.email}');
      await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Dashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
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
                  padding: const EdgeInsets.only(
                      top: 110.0, left: 50.0, right: 30.0),
                  child: Text(
                    'To create a brand new Government Entity Account press the button below. To do this, you must be an Administrator or Manager',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: RaisedButton(
                    onPressed: _startSignUpPage,
                    color: Theme.of(context).primaryColor,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Start New Government Entity Account',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding:
                      const EdgeInsets.only(top: 80.0, left: 50.0, right: 30.0),
                  child: Text(
                    'To sign in to an existing Government Entity Account press the button below.',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: _startSignInPage,
                    color: Colors.blue,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Sign in to Government Entity App',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),

//      floatingActionButton: new Opacity(
//        opacity: fabOpacity,
//        child: new FloatingActionButton(
//          onPressed: _startSignUp,
//          tooltip: 'Increment',
//          child: new Icon(FontAwesomeIcons.lockOpen),
//        ),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startSignUpPage() async {
    print('_MyHomePageState._btnPressed ................');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignUpPage()),
    );
  }

  void _startSignInPage() async {
    print('_MyHomePageState._startSignInPage ...........');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignInPage()),
    );
  }

  void _startDashboard() async {
    print('_MyHomePageState._starDashboard ...........');
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard()),
    );
  }

  @override
  onActionPressed() {
    print('_StartPageState.onActionPressed +++++++++++++++++ >>>');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard()),
    );
  }
}

class BackImage extends StatelessWidget {
  AssetImage _assetImage = AssetImage('assets/fincash.jpg');
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
