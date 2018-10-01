import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUp {
  static const NameSpace = 'resource:com.oneconnect.biz.';
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

  static String publicKey =
          'GDN4SBSKZI4EUYIOXK5HCFHCZGZYEZTGEUX26V6MVI2BINMDUGR6E5EZ',
      privateKey = 'SCVBNGSMPV3KESG23ZQTSVFKTSP6YIJE7ONBBGSS6SH6IQ7XKSUOVOIO';
  RemoteConfig remoteConfig;
  Future<Null> _setupRemoteConfig() async {
    if (privateKey != null) {
      return null;
    }

    try {
      if (remoteConfig == null) {
        print(
            'SignUp.setupRemoteConfig ############ getting RemoteConfig settings and fetching');
        remoteConfig = await RemoteConfig.instance;
        var settings = RemoteConfigSettings(debugMode: true);
        await remoteConfig.setConfigSettings(settings);
        await remoteConfig.fetch(expiration: Duration(minutes: 5));
        await remoteConfig.activateFetched();
      }

      publicKey = remoteConfig.getString('account_id');
      privateKey = remoteConfig.getString('private_key');
      print('SignUp.setupRemoteConfig STELLAR KEYS: $publicKey $privateKey ');
    } catch (e) {
      print('SignUp._setupRemoteConfig\n\n --------------- ERROR $e \n\n');
      //throw Exception('Remote Config failed');
    }
  }

  Future<int> signUpGovtEntity(GovtEntity govtEntity, User admin) async {
    await _setupRemoteConfig();
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
    govtEntity.dateRegistered = getUTCDate();
    DataAPI3 dataAPI = DataAPI3();
    var key = await dataAPI.addGovtEntity(govtEntity);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveGovtEntity(govtEntity);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var result = await _doWalletCall(
        govtEntity.name, govtEntity.participantId, privateKey, GovtEntityType);

    if (result != '0') {
      print('SignUp.signUpGovtEntity  wallet done');
    } else {
      print('SignUp.signUpGovtEntity ERROR ERROR - wallet failed');
    }

//    admin.govtEntity = NameSpace + 'GovtEntity#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future _doWalletCall(
      String name, String participantId, String seed, int type) async {
    var result = await createWallet(
        name: name, participantId: participantId, type: type, seed: seed);
    if (result == '0') {
      await SharedPrefs.removeWallet();
    }

    return result;
  }

  Future<int> signUpSupplier(Supplier supplier, User admin) async {
    await _setupRemoteConfig();
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
    DataAPI3 dataAPI = DataAPI3();
    supplier.dateRegistered = getUTCDate();
    var key = await dataAPI.addSupplier(supplier);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }
    await SharedPrefs.saveSupplier(supplier);
    admin.supplier = NameSpace + 'Supplier#${supplier.participantId}';
    admin.isAdministrator = 'true';

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        supplier.name, supplier.participantId, privateKey, SupplierType);
    if (res != '0') {
      print('SignUp.signUpSupplier  wallet done');
    } else {
      print('SignUp.signUpSupplier ERROR ERROR - wallet failed');
    }
    return await signUp(admin);
  }

  Future<int> signUpInvestor(Investor investor, User user) async {
    await _setupRemoteConfig();
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
    investor.dateRegistered = getUTCDate();
    DataAPI3 dataAPI = DataAPI3();
    var result = await dataAPI.addInvestor(investor);
    if (result > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveInvestor(investor);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        investor.name, investor.participantId, privateKey, InvestorType);
    if (res != '0') {
      print('SignUp.signUpInvestor wallet done');
    } else {
      print('SignUp.signUpInvestor ERROR ERROR - wallet failed');
    }
//    user.investor = NameSpace + 'Investor#' + key;
    user.isAdministrator = 'true';
    return await signUp(user);
  }

  Future<int> signUpAuditor(Auditor auditor, User admin) async {
    await _setupRemoteConfig();
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
    DataAPI3 dataAPI = DataAPI3();
    var key = await dataAPI.addAuditor(auditor);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveAuditor(auditor);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        auditor.name, auditor.participantId, privateKey, AuditorType);
    if (res != '0') {
      print('SignUp.signUpAuditor wallet done');
    } else {
      print('SignUp.signUpAuditor ERROR ERROR - wallet failed');
    }

//    admin.auditor = NameSpace + 'Auditor#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpProcurementOffice(
      ProcurementOffice office, User admin) async {
    await _setupRemoteConfig();
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
    DataAPI3 dataAPI = DataAPI3();
    var key = await dataAPI.addProcurementOffice(office);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveProcurementOffice(office);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        office.name, office.participantId, privateKey, ProcurementOfficeType);
    if (res != '0') {
      print('SignUp.signUpProcurementOffice wallet done');
    } else {
      print('SignUp.signUpProcurementOffice ERROR ERROR - wallet failed');
    }
//    admin.procurementOffice = NameSpace + 'ProcurementOffice#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpBank(Bank bank, User admin) async {
    await _setupRemoteConfig();
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
    DataAPI3 dataAPI = DataAPI3();
    var key = await dataAPI.addBank(bank);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveBank(bank);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        bank.name, bank.participantId, privateKey, BankType);
    if (res != '0') {
      print('SignUp.signUpBank wallet done');
    } else {
      print('SignUp.signUpBank ERROR ERROR - wallet failed');
    }

//    admin.bank = NameSpace + 'Bank#' + key;
    admin.isAdministrator = 'true';
    return await signUp(admin);
  }

  Future<int> signUpOneConnect(OneConnect oneConnect, User admin) async {
    await _setupRemoteConfig();
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
    DataAPI3 dataAPI = DataAPI3();
    var key = await dataAPI.addOneConnect(oneConnect);
    if (key > DataAPI3.Success) {
      return ErrorBlockchain;
    }

    await SharedPrefs.saveOneConnect(oneConnect);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }
    var res = await _doWalletCall(
        oneConnect.name, oneConnect.participantId, privateKey, OneConnectType);
    if (res != '0') {
      print('SignUp.signUpOneConnect wallet done');
    } else {
      print('SignUp.signUpOneConnect ERROR ERROR - wallet failed');
    }

//    admin.oneConnect = NameSpace + 'OneConnect#' + key;
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
    user.dateRegistered = getUTCDate();

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
