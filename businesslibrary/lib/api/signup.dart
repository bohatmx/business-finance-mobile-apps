import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUp {
  final String url;
  final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  SignUp(this.url);
  static const Success = 0,
      ErrorFirebaseUserExists = 1,
      ErrorMissingOrInvalidData = 4,
      ErrorCreatingFirebaseUser = 5,
      ErrorFireStore = 2,
      ErrorBlockchain = 3;

  Future<int> signUpGovtEntity(GovtEntity govtEntity, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addGovtEntity(govtEntity);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.govtEntity = 'resource:oneconnect.com.biz.GovtEntity#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpCompany(Company company, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addCompany(company);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.company = 'resource:oneconnect.com.biz.Company#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpSupplier(Supplier supplier, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addSupplier(supplier);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.supplier = 'resource:oneconnect.com.biz.Supplier#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpInvestor(Investor investor, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addInvestor(investor);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.investor = 'resource:oneconnect.com.biz.Investor#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpAuditor(Auditor auditor, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addAuditor(auditor);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.auditor = 'resource:oneconnect.com.biz.Auditor#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpProcurementOffice(
      ProcurementOffice office, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addProcurementOffice(office);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.procurementOffice =
        'resource:oneconnect.com.biz.ProcurementOffice#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpBank(Bank bank, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addBank(bank);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.bank = 'resource:oneconnect.com.biz.Bank#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpOneConnect(OneConnect oneConnect, User admin) async {
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addOneConnect(oneConnect);
    if (key == null) {
      return ErrorBlockchain;
    }

    admin.oneConnect = 'resource:oneconnect.com.biz.OneConnect#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  /// add user to firebase and blockchain
  Future<int> signUp(User user) async {
    assert(user.email != null);
    assert(user.password != null);
    assert(user.firstName != null);
    assert(user.lastName != null);
    assert(user.idNumber != null);
    assert(user.isAdministrator != null);
    assert(user.userType != null);

    if (!hasOwner(user)) {
      return ErrorMissingOrInvalidData;
    }

    user.userId = DataAPI.getKey();
    user.dateRegistered = DateTime.now().toIso8601String();

    var fbUser = await _createUser(user.email, user.password).catchError((e) {
      return ErrorCreatingFirebaseUser;
    });
    if (fbUser == null) {
      return ErrorFirebaseUserExists;
    }
    var token = await SharedPrefs.getFCMToken();
    user.fcmToken = token;

    DocumentReference ref =
        await _firestore.collection('users').add(user.toJson()).catchError((e) {
      print('SignUp.signUp ERROR: $e');
      return ErrorFireStore;
    });
    print('SignUp.signUp: @@@@@@@@ DocumentReference path: ${ref.path}');
    user.documentReference = ref.documentID;

    DataAPI api = DataAPI(url);
    String key = await api.addUser(user);
    if (key == "0") {
      return ErrorBlockchain;
    } else {
      await SharedPrefs.saveUser(user);
      return Success;
    }
  }

  Future<FirebaseUser> _createUser(String email, String password) async {
    print('SignUp.createUser ========= starting to create new user .... ===');
    FirebaseUser user;
    try {
      user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        print('SignUp.createUser done.  new user on firebase: '
            '${user.email} $password ---- Yay!');
      }
    } catch (e) {
      print('SignUp.createUser ERROR: $e');
    }

    return user;
  }

  Future<FirebaseUser> signInWithEmail(String email, String password) async {
    print('SignUp.signInWithEmail ========= starting sign in .... ===');
    FirebaseUser user;
    try {
      user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('SignUp.signInWithEmail ERROR $e');
    }

    return user;
  }

  Future<FirebaseUser> signInWithGoogle() async {
    print('SignUp.signInWithGoogle  ========= starting sign in .... ===');
    FirebaseUser user;
    try {
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
        print('MyAuth.signInWithGoogle: onCurrentUserChanged ' + account.email);
      });
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print('SignUp.signInWithGoogle  ${googleUser.email}');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          'SignUp.signInWithGoogle googleAuth done ...... now authenticate with Firebase');

      user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (e) {
      print('&&&&&&&& Google Sign in FUCKED ^%%5#&% $e');
    }
    if (user == null) {
      print('%%%%%% ERROR - user null from Google sign in');
      return null;
    }
    print(
        "This user signed in via Google #############################: $user");
    return user;
  }

  bool hasOwner(User user) {
    int count = 0;
    if (user.govtEntity != null) {
      count++;
    }
    if (user.company != null) {
      count++;
    }
    if (user.supplier != null) {
      count++;
    }
    if (user.oneConnect != null) {
      count++;
    }
    if (user.auditor != null) {
      count++;
    }
    if (user.procurementOffice != null) {
      count++;
    }
    if (user.investor != null) {
      count++;
    }
    if (user.bank != null) {
      count++;
    }
    switch (count) {
      case 0:
        return false;
      case 1:
        return true;
      default:
        return false;
    }
  }
}
