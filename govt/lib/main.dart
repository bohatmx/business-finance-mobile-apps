import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/theme_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:govt/ui/dashboard.dart';
import 'package:govt/ui/signin_page.dart';
import 'package:govt/ui/signup_page.dart';
import 'package:govt/ui/theme_util.dart';

void main() => runApp(new GovtApp());

final FirebaseAuth _auth = FirebaseAuth.instance;

class GovtApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: null,
      stream: bloc.newThemeStream,
      builder: (context, snapShot) => MaterialApp(
        title: 'BFNCustomer',
        debugShowCheckedModeBanner: false,
        theme: snapShot.data == null
            ? ThemeUtil.getTheme(themeIndex: 0)
            : ThemeUtil.getTheme(themeIndex: snapShot.data),
        home: new Dashboard(null),
      ),
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
  double fabOpacity = 0.3;
  GovtEntity customer;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('BFN'),
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
                    'To create a brand new Customer Account press the button below. To do this, you must be an Administrator or Manager',
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
                        'Start New CustomerAccount',
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
                    'To sign in to an existing Customer Account press the button below.',
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
                        'Sign in to Customer App',
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
      //-LOgb4poza3eLtedkXMq
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

  @override
  onActionPressed(int action) {
    print('_StartPageState.onActionPressed +++++++++++++++++ >>>');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
    );
  }
}

class BackImage extends StatelessWidget {
  final AssetImage _assetImage = AssetImage('assets/fincash.jpg');
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
