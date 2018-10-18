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
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _firestore = Firestore.instance;
  static GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

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
  static RemoteConfig remoteConfig;
  static Future<Null> _setupRemoteConfig() async {
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

  static Future<int> signUpGovtEntity(GovtEntity govtEntity, User admin) async {
    await _setupRemoteConfig();
    var qs = await _firestore
        .collection('govtEntities')
        .where('name', isEqualTo: govtEntity.name)
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
    govtEntity.participantId = DataAPI.getKey();
    admin.govtEntity =
        'resource:com.oneconnect.biz.GovtEntity#${govtEntity.participantId}';

    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addGovtEntity(govtEntity, admin);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addGovtEntity(govtEntity, admin);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    await SharedPrefs.saveUser(admin);
    await SharedPrefs.saveGovtEntity(govtEntity);
    print(
        '\n\n\n\n########## SignUp.signUpGovtEntity ${govtEntity.name} COMPLETE #############\n\n\n\n');
    return 0;
  }

  static Future<int> signUpSupplier(Supplier supplier, User admin) async {
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
    admin.supplier =
        'resource:com.oneconnect.biz.Supplier#${supplier.participantId}';
//    FirebaseUser fbUser = await _createUser(admin.email, admin.password);
//    if (fbUser == null) {
//      return ErrorCreatingFirebaseUser;
//    }
    supplier.dateRegistered = getUTCDate();
//    admin.uid = fbUser.uid;
    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addSupplier(supplier, admin);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addSupplier(supplier, admin);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    await SharedPrefs.saveSupplier(supplier);
    await SharedPrefs.saveUser(admin);
    print(
        '\n\n\n\n########## SignUp.signUpSupplier ${supplier.name} COMPLETE #############\n\n\n\n');

    return DataAPI3.Success;
  }

  static Future<int> signUpInvestor(Investor investor, User admin) async {
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
    admin.investor =
        'resource:com.oneconnect.biz.Investor#${investor.participantId}';
//    FirebaseUser fbUser = await _createUser(admin.email, admin.password);
//    if (fbUser == null) {
//      return ErrorCreatingFirebaseUser;
//    }
//    admin.uid = fbUser.uid;
    if (USE_LOCAL_BLOCKCHAIN) {
      var result = await DataAPI.addInvestor(investor, admin);
      if (result == '0') {
        return ErrorBlockchain;
      }
    } else {
      var result = await DataAPI3.addInvestor(investor, admin);
      if (result > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }
    await SharedPrefs.saveInvestor(investor);
    await _createUser(admin.email, admin.password);
    await SharedPrefs.saveUser(admin);
    print(
        '\n\n\n\n########## SignUp.signUpInvestor ${investor.name} COMPLETE #############\n\n\n\n');
    return DataAPI3.Success;
  }

  static Future<int> signUpAuditor(Auditor auditor, User admin) async {
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
    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addAuditor(auditor);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addAuditor(auditor);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    return DataAPI3.Success;
  }

  static Future<int> signUpProcurementOffice(
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
    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addProcurementOffice(office);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addProcurementOffice(office);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    await SharedPrefs.saveProcurementOffice(office);

    //create Stellar wallet
    if (isInDebugMode) {
      privateKey = null;
    }

    return await _signUp(admin);
  }

  static Future<int> signUpBank(Bank bank, User admin) async {
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
    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addBank(bank);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addBank(bank);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    await SharedPrefs.saveBank(bank);
    return await _signUp(admin);
  }

  static Future<int> signUpOneConnect(OneConnect oneConnect, User admin) async {
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
    if (USE_LOCAL_BLOCKCHAIN) {
      var key = await DataAPI.addOneConnect(oneConnect);
      if (key == '0') {
        return ErrorBlockchain;
      }
    } else {
      var key = await DataAPI3.addOneConnect(oneConnect);
      if (key > DataAPI3.Success) {
        return ErrorBlockchain;
      }
    }

    await SharedPrefs.saveOneConnect(oneConnect);
    return await _signUp(admin);
  }

  /// add user to firebase auth and firestore
  static Future<int> _signUp(User user) async {
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

    var mref =
        await _firestore.collection('users').add(user.toJson()).catchError((e) {
      print(e);
      return ErrorCreatingFirebaseUser;
    });
    print(mref);
    user.documentReference = mref.documentID;
    await SharedPrefs.saveUser(user);
    return Success;
  }

  static Future<FirebaseUser> _createUser(String email, String password) async {
    print(
        '\n\nSignUp.createUser ========= starting to create new user .... ===');
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
      print(
          '\n\nSignUp.createUser done. ##########  new auth user on firebase: '
          '${user.email} uid: ${user.uid} ---- Yay!\n\n\n\n');
    }

    return user;
  }

  static Future<FirebaseUser> signInWithEmail(
      String email, String password) async {
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

  static Future<FirebaseUser> signInWithGoogle() async {
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

class UserBag {
  GovtEntity govtEntity;
  User user;
  bool debug;
  String apiSuffix;
}
