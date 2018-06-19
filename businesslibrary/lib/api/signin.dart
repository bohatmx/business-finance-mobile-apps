import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _firestore = Firestore.instance;

  static const ErrorSignIn = 1,
      Success = 0,
      ErrorUserNotInDatabase = 2,
      ErrorDatabase = 3,
      ErrorNoOwningEntity = 4;

  ///Existing user signs into BFN  and cahes data to SharedPrefs
  static Future<int> signIn(String email, String password) async {
    print('SignIn.signIn ++++++++++++++++ Firebase  $email $password +++++++');
    print('SignIn.signIn: ***** 7:56 AM version ****');

    FirebaseUser fbUser;
    try {
      fbUser = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((e) {
        print('SignIn.signIn: ------------ fucking *&%*fukIUHUB^!!  ERROR! $e');
        return ErrorSignIn;
      });

      if (fbUser == null) {
        return ErrorSignIn;
      }
    } catch (e) {
      print(
          'SignIn.signIn:------------->>> FIREBASE AUTHENTICATION ERROR - $e');
      return ErrorSignIn;
    }
    //get user from Firestore
    print('SignIn.signIn: ......... get user from Firestore');
    var querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print('SignIn.signIn ERROR $e');
      return ErrorDatabase;
    });
    User user;
    querySnapshot.documents.forEach((doc) {
      user = new User.fromJson(doc.data);
      user.documentReference = doc.documentID;
    });

    if (user == null) {
      print('SignIn.signIn ERROR  user not found in Firestore ---------------');
      return ErrorSignIn;
    }
    print('SignIn.signIn: so far, so good, about  to save user ');
    await SharedPrefs.saveUser(user);
    return await getOwningEntity(user);
  }

  static Future<int> getOwningEntity(User user) async {
    print(
        'SignIn.getOwningEntity: .... .....  ${user.firstName} ${user.lastName}');
    if (user.govtEntity != null) {
      var partId = user.govtEntity.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('govtEntities')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      GovtEntity govtEntity;
      qSnap.documents.forEach((doc) {
        govtEntity = new GovtEntity.fromJson(doc.data);
        govtEntity.documentReference = doc.documentID;
      });
      if (govtEntity == null) {
        print('SignIn.signIn ERROR  govtEntity not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveGovtEntity(govtEntity);
      return Success;
    }

    if (user.supplier != null) {
      var partId = user.supplier.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('suppliers')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Supplier supplier;
      qSnap.documents.forEach((doc) {
        supplier = new Supplier.fromJson(doc.data);
        supplier.documentReference = doc.documentID;
      });
      if (supplier == null) {
        print('SignIn.signIn ERROR  supplier not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveSupplier(supplier);
      return Success;
    }
    if (user.company != null) {
      var partId = user.company.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('companies')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Company company;
      qSnap.documents.forEach((doc) {
        company = new Company.fromJson(doc.data);
        company.documentReference = doc.documentID;
      });
      if (company == null) {
        print('SignIn.signIn ERROR  company not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveCompany(company);
      return Success;
    }
    if (user.auditor != null) {
      var partId = user.auditor.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('auditors')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Auditor auditor;
      qSnap.documents.forEach((doc) {
        auditor = new Auditor.fromJson(doc.data);
        auditor.documentReference = doc.documentID;
      });
      if (auditor == null) {
        print('SignIn.signIn ERROR  auditor not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveAuditor(auditor);
      return Success;
    }
    if (user.procurementOffice != null) {
      var partId = user.procurementOffice.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('procurementOffices')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      ProcurementOffice office;
      qSnap.documents.forEach((doc) {
        office = new ProcurementOffice.fromJson(doc.data);
        office.documentReference = doc.documentID;
      });
      if (office == null) {
        print('SignIn.signIn ERROR  office not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveProcurementOffice(office);
      return Success;
    }
    if (user.investor != null) {
      var partId = user.investor.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('investors')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      Investor investor;
      qSnap.documents.forEach((doc) {
        investor = new Investor.fromJson(doc.data);
        investor.documentReference = doc.documentID;
      });
      if (investor == null) {
        print('SignIn.signIn ERROR  investor not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveInvestor(investor);
      return Success;
    }
    if (user.oneConnect != null) {
      var partId = user.oneConnect.split("#").elementAt(1);
      var qSnap = await _firestore
          .collection('oneConnect')
          .where('participantId', isEqualTo: partId)
          .getDocuments()
          .catchError((e) {
        return ErrorNoOwningEntity;
      });
      OneConnect one;
      qSnap.documents.forEach((doc) {
        one = new OneConnect.fromJson(doc.data);
      });
      if (one == null) {
        print('SignIn.signIn ERROR  OneConnect not found in Firestore');
        return ErrorSignIn;
      }
      await SharedPrefs.saveOneConnect(one);
      return Success;
    }

    return ErrorDatabase;
  }
}
