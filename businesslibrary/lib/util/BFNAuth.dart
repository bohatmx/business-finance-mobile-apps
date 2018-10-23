import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BFNAuthListener {
  onAuthenticated(User user);
  onAuthenticationError();
}

class BFNAuthPage extends StatefulWidget {
  final BFNAuthListener listener;

  BFNAuthPage(this.listener);

  @override
  _BFNAuthPageState createState() => _BFNAuthPageState();
}

class _BFNAuthPageState extends State<BFNAuthPage> implements SnackBarListener {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String email, password;
  User user = User();

  void _setName(FirebaseUser fbUser) {
    user.email = fbUser.email;
    user.uid = fbUser.uid;
    try {
      if (fbUser.displayName != null) {
        user.firstName = fbUser.displayName.split(' ').elementAt(0);
        user.firstName = fbUser.displayName.split(' ').elementAt(1);
      }
    } catch (e) {}
    widget.listener.onAuthenticated(user);
  }

  void _authWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser fbUser = await _auth
        .signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    )
        .catchError((err) {
      print(err);
      widget.listener.onAuthenticationError();
      showError('Sign In With Google FAILED');
      return;
    });
    // do something with signed-in user
    print(
        '_BFNAuthPageState._authWithGoogle - authenticated ${fbUser.displayName}');
    _setName(fbUser);
  }

  void _authWithFacebook() async {
    final FirebaseUser fbUser =
        await _auth.signInWithFacebook(accessToken: null).catchError((err) {
      print(err);
      widget.listener.onAuthenticationError();
      showError('Sign In With Facebook FAILED');
    });
    // do something with signed-in user
    print(
        '_BFNAuthPageState._authWithGoogle - authenticated ${fbUser.displayName}');
  }

  void _authWithPhone() async {
    final FirebaseUser fbUser = await _auth
        .signInWithPhoneNumber(verificationId: null, smsCode: null)
        .catchError((err) {
      print(err);
      widget.listener.onAuthenticationError();
      showError('Sign In With Phone Number FAILED');
    });
    // do something with signed-in user
    print(
        '_BFNAuthPageState._authWithGoogle - authenticated ${fbUser.displayName}');
  }

  void _authWithTwitter() async {
    final FirebaseUser fbUser = await _auth
        .signInWithTwitter(authToken: null, authTokenSecret: null)
        .catchError((err) {
      print(err);
      widget.listener.onAuthenticationError();
      showError('Sign In With Twitter FAILED');
    });
    // do something with signed-in user
    print(
        '_BFNAuthPageState._authWithGoogle - authenticated ${fbUser.displayName}');
  }

  void _authWithEmailAndPassword() async {
    if (email == null || email.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter email address',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (password == null || password.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter password',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    final FirebaseUser fbUser = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      print(e);
      showError('Sign In With Email and Password FAILED');
      widget.listener.onAuthenticationError();
    });
    _setName(fbUser);
    print(
        '_BFNAuthPageState._authWithGoogle - authenticated ${fbUser.displayName}');
  }

  showError(String message) {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _scaffoldKey,
        message: message,
        listener: this,
        actionLabel: 'OK');
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: Text(
              'Welcome to BFN',
              style: Styles.whiteBoldMedium,
            ),
          )
        ],
      ),
    );
  }

  Widget _getBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: RaisedButton(
            onPressed: _authWithGoogle,
            elevation: 8.0,
            color: Colors.red.shade800,
            child: Text(
              'Google',
              style: Styles.whiteMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: RaisedButton(
            onPressed: _authWithFacebook,
            elevation: 8.0,
            color: Colors.blue.shade800,
            child: Text(
              'Facebook',
              style: Styles.whiteMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: RaisedButton(
            onPressed: _authWithTwitter,
            elevation: 8.0,
            color: Colors.lightBlue.shade500,
            child: Text(
              'Twitter',
              style: Styles.whiteMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: RaisedButton(
            elevation: 8.0,
            onPressed: _authWithPhone,
            color: Colors.teal.shade600,
            child: Text(
              'Phone Number',
              style: Styles.whiteMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _onEmailChanged,
            keyboardType: TextInputType.emailAddress,
            style: Styles.blackMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _onPasswdChanged,
            keyboardType: TextInputType.emailAddress,
            style: Styles.blackMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: RaisedButton(
            elevation: 8.0,
            onPressed: _authWithEmailAndPassword,
            color: Colors.grey.shade600,
            child: Text(
              'Email',
              style: Styles.whiteMedium,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Authentication'),
        bottom: _getBottom(),
      ),
      body: _getBody(),
    );
  }

  void _onEmailChanged(String value) {
    email = value;
  }

  void _onPasswdChanged(String value) {
    password = value;
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }
}
