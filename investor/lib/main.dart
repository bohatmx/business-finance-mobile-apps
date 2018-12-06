
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/util/theme_bloc.dart';

import 'package:flutter/material.dart';
import 'package:investor/ui/dashboard.dart';
import 'package:investor/ui/signin_page.dart';
import 'package:investor/ui/signup_page.dart';

void main() => runApp(new InvestorApp());

class InvestorApp extends StatelessWidget {
  // This widget is the root of your application.

  InvestorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      initialData: null,
      stream: bloc.newThemeStream,
      builder: (context, snapShot) => MaterialApp(
            title: 'BFNInvestor',
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

class _StartPageState extends State<StartPage> {
  double fabOpacity = 0.3;
  Investor investor;
  @override
  initState() {
    super.initState();
    _checkUser();
  }

  _checkUser() async {
    investor = await SharedPrefs.getInvestor();
    if (investor != null) {
      await Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => new Dashboard(null)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Business Finance Network'),
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
                    'To create a brand new Investor Account press the button below. To do this, you must be an Administrator or Manager',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: _startSignUpPage,
                    color: Theme.of(context).primaryColor,
                    elevation: 16.0,
                    child: new Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Start Investor Account',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                new Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 50.0, right: 30.0),
                  child: Text(
                    'To sign in to Investor Entity Account press the button below.',
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
                        'Sign in to Investor App',
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
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SignInPage()),
    );
  }

  void receivedPurchaseOrder(PurchaseOrder po) {
    print('_StartPageState.receivedPurchaseOrder, -------------- '
        'about to go refresh Dashboard: ${po.toJson()}');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Dashboard(null)),
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


//

