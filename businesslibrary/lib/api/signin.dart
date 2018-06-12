import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
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

  static Future<int> signIn(String email, String password) async {
    var fbbUser = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      print('SignIn.signIn ERROR $e');
      return ErrorSignIn;
    });
    if (fbbUser == null) {
      return ErrorSignIn;
    }
    //get user from Firestore
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
    });
    await SharedPrefs.saveUser(user);
    return await getOwningEntity(user);
  }

  static Future<int> getOwningEntity(User user) async {
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
      });
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
      });
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
      });
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
      });
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
      });
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
      });
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
      Supplier supplier;
      qSnap.documents.forEach((doc) {
        supplier = new Supplier.fromJson(doc.data);
      });
      await SharedPrefs.saveSupplier(supplier);
      return Success;
    }

    return ErrorDatabase;
  }
}
