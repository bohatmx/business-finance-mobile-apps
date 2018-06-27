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
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUp {
  static const NameSpace = 'resource:com.oneconnect.biz';
  final String url;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
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
      ErrorEntityAlreadyExists = 6,
      ErrorUserAlreadyExists = 7,
      ErrorFireStore = 2,
      ErrorBlockchain = 3;
  static const ACCOUNT_ID =
          "GDJ4EYJNMQEE75OXVSRXP7G7IMDUXVPZUBYTORILVKH5FAG2I3EPXJY5",
      SECRET = "SCY6UGXJAWH6FFCNCW4HH72TUVGU5ESUI6SSBWVSJ7MHOBQEWOSQKTPB";
  Future<int> signUpGovtEntity(GovtEntity govtEntity, User admin) async {
    var qs = await _firestore
        .collection('govtEntities')
        .where('name', isEqualTo: govtEntity.name)
        .where('govtEntityType', isEqualTo: govtEntity.govtEntityType)
        .where('country', isEqualTo: govtEntity.govtEntityType)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpGovtEntity ERROR $e');
      return ErrorFireStore;
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpGovtEntity ERROR govtEntity already exists');
      return ErrorEntityAlreadyExists;
    }
    govtEntity.dateRegistered = new DateTime.now().toIso8601String();
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addGovtEntity(govtEntity);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveGovtEntity(govtEntity);
    var wallet = await _getWallet();
    wallet.govtEntity = NameSpace + 'GovtEntity#' + govtEntity.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.govtEntity = NameSpace + '.GovtEntity#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<Wallet> _getWallet() async {
    var wallet = Wallet();
    wallet.dateRegistered = new DateTime.now().toIso8601String();
    wallet.lastBalance = '0';
    wallet.sourceSeed = SECRET;
    wallet.debug = isInDebugMode;
    wallet.fcmToken = await SharedPrefs.getFCMToken();
    return wallet;
  }

  Future<int> signUpCompany(Company company, User admin) async {
    var qs = await _firestore
        .collection('companies')
        .where('name', isEqualTo: company.name)
        .where('country', isEqualTo: company.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpCompany ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpCompany ERROR company already exists');
      return ErrorEntityAlreadyExists;
    }

    company.dateRegistered = DateTime.now().toIso8601String();
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addCompany(company);
    if (key == '0') {
      return ErrorBlockchain;
    }
    await SharedPrefs.saveCompany(company);

    var wallet = await _getWallet();
    wallet.govtEntity = NameSpace + 'Company#' + company.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.company = NameSpace + '.Company#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpSupplier(Supplier supplier, User admin) async {
    var qs = await _firestore
        .collection('suppliers')
        .where('name', isEqualTo: supplier.name)
        .where('country', isEqualTo: supplier.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpSupplier ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpSupplier ERROR supplier already exists');
      return ErrorEntityAlreadyExists;
    }
    DataAPI dataAPI = DataAPI(url);
    supplier.dateRegistered = new DateTime.now().toIso8601String();
    var key = await dataAPI.addSupplier(supplier);
    if (key == '0') {
      return ErrorBlockchain;
    }
    await SharedPrefs.saveSupplier(supplier);
    admin.supplier = NameSpace + '.Supplier#' + key;
    admin.isAdministrator = 'true';

    var wallet = await _getWallet();
    wallet.supplier = NameSpace + 'Supplier#' + supplier.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    return await signUp(admin);
  }

  Future<int> signUpInvestor(Investor investor, User admin) async {
    var qs = await _firestore
        .collection('investors')
        .where('name', isEqualTo: investor.name)
        .where('country', isEqualTo: investor.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpInvestor ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpInvestor ERROR investor already exists');
      return ErrorEntityAlreadyExists;
    }
    investor.dateRegistered = new DateTime.now().toIso8601String();
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addInvestor(investor);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveInvestor(investor);

    var wallet = await _getWallet();
    wallet.investor = NameSpace + 'Investor#' + investor.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.investor = NameSpace + '.Investor#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpAuditor(Auditor auditor, User admin) async {
    var qs = await _firestore
        .collection('auditors')
        .where('name', isEqualTo: auditor.name)
        .where('country', isEqualTo: auditor.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpAuditor ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpAuditor ERROR auditor already exists');
      return ErrorEntityAlreadyExists;
    }
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addAuditor(auditor);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveAuditor(auditor);

    var wallet = await _getWallet();
    wallet.auditor = NameSpace + 'Auditor#' + auditor.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.auditor = NameSpace + '.Auditor#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpProcurementOffice(
      ProcurementOffice office, User admin) async {
    var qs = await _firestore
        .collection('procurementOffices')
        .where('name', isEqualTo: office.name)
        .where('country', isEqualTo: office.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpProcurementOffice ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print(
          'SignUp.signUpProcurementOffice ERROR ProcurementOffice already exists');
      return ErrorEntityAlreadyExists;
    }
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addProcurementOffice(office);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveProcurementOffice(office);

    var wallet = await _getWallet();
    wallet.procurementOffice =
        NameSpace + 'ProcurementOffice#' + office.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.procurementOffice = NameSpace + '.ProcurementOffice#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpBank(Bank bank, User admin) async {
    var qs = await _firestore
        .collection('bank')
        .where('name', isEqualTo: bank.name)
        .where('country', isEqualTo: bank.country)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpBank ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpBank ERROR bank already exists');
      return ErrorEntityAlreadyExists;
    }
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addBank(bank);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveBank(bank);

    var wallet = await _getWallet();
    wallet.bank = NameSpace + 'Bank#' + bank.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.bank = NameSpace + '.Bank#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpOneConnect(OneConnect oneConnect, User admin) async {
    var qs = await _firestore
        .collection('oneConnect')
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUpOneConnect ERROR $e');
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUpOneConnect ERROR OneConnect already exists');
      return ErrorEntityAlreadyExists;
    }
    DataAPI dataAPI = DataAPI(url);
    var key = await dataAPI.addOneConnect(oneConnect);
    if (key == '0') {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveOneConnect(oneConnect);

    var wallet = await _getWallet();
    wallet.oneConnect = NameSpace + 'OneConnect#' + oneConnect.participantId;
    await dataAPI.addWalletToFirestoreForStellar(wallet);

    admin.oneConnect = NameSpace + '.OneConnect#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  /// add user to firebase and blockchain
  Future<int> signUp(User user) async {
    assert(user.email != null);
    assert(user.password != null);
    assert(user.firstName != null);
    assert(user.lastName != null);
    assert(user.isAdministrator != null);

    if (!hasOwner(user)) {
      return ErrorMissingOrInvalidData;
    }
    var qs = await _firestore
        .collection('users')
        .where('firstName', isEqualTo: user.firstName)
        .where('lastName', isEqualTo: user.lastName)
        .where('email', isEqualTo: user.email)
        .getDocuments()
        .catchError((e) {
      print('SignUp.signUp ERROR $e');
      return ErrorFireStore;
    });
    if (qs.documents.isNotEmpty) {
      print('SignUp.signUp ERROR user already exists');
      return ErrorUserAlreadyExists;
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
    user.uid = fbUser.uid;

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

    user = await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((e) {
      print('SignUp._createUser ERROR $e');
      return null;
    });

    if (user != null) {
      print('SignUp.createUser done.  new user on firebase: '
          '${user.email} uid: ${user.uid} ---- Yay!');
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
