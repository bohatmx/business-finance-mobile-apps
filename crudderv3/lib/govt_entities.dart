import 'dart:async';

import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudderv3/util.dart';

class GovtUtil {
  static Future<int> cleanUp() async {
    print('GovtUtil.cleanUp ................');
    var fs = Firestore.instance;
    try {
      var qs = await fs.collection('users').getDocuments();
      qs.documents.forEach((doc) {
        doc.reference.delete();
      });
      var qs2 = await fs.collection('govtEntities').getDocuments();
      qs2.documents.forEach((doc) {
        doc.reference.delete();
      });
      var qs3 = await fs.collection('suppliers').getDocuments();
      qs3.documents.forEach((doc) {
        doc.reference.delete();
      });
    } catch (e) {
      print('GovtUtil.cleanUp ERROR $e');
      return 1;
    }
    print('GovtUtil.cleanUp COMPLETED');
    return 0;
  }

  static Future<int> generateEntities() async {
    print('GovtUtil.generateEntities ......................');
    SignUp signUp = SignUp(Util.getURL());
    try {
      GovtEntity e1 = new GovtEntity(
        name: 'Department of Home Affairs',
        email: 'info@water.gov.za',
        country: 'South Africa',
        govtEntityType: 'NATIONAL',
      );
      User u1 = new User(
          firstName: 'Thabo',
          lastName: 'Nkosi',
          password: 'mpassword123',
          email: 'thabo.nkosi@water.gov.za');
      await signUp.signUpGovtEntity(e1, u1);

      GovtEntity e2 = new GovtEntity(
        name: 'Department of Public Works',
        email: 'info@publicworks.gov.za',
        country: 'South Africa',
        govtEntityType: 'NATIONAL',
      );
      User u2 = new User(
          firstName: 'Ntombi',
          lastName: 'Mathebula',
          password: 'mpassword123',
          email: 'ntombi.m@publicworks.gov.za');
      await signUp.signUpGovtEntity(e2, u2);
    } catch (e) {
      print('GovtUtil.cleanUp ERROR $e');
      return 1;
    }
    print('GovtUtil.generateEntities COMPLETED');
    return 0;
  }

  static Future<int> generateSuppliers() async {
    print('GovtUtil.generateSuppliers ............');
    SignUp signUp = SignUp(Util.getURL());
    try {
      Supplier e1 = new Supplier(
        name: 'Mkhize Electrical',
        email: 'info@mkhize.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u1 = new User(
          firstName: 'David',
          lastName: 'Mkhize',
          password: 'mpassword123',
          email: 'dmkhize@mkhize.com');
      await signUp.signUpSupplier(e1, u1);

      Supplier e2 = new Supplier(
        name: 'Dlamini Contractors',
        email: 'info@dlamini.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u2 = new User(
          firstName: 'Moses',
          lastName: 'Dlamini',
          password: 'mpassword123',
          email: 'ddlam@dlamini.com');
      await signUp.signUpSupplier(e2, u2);

      Supplier e3 = new Supplier(
        name: 'Frannie Event Management',
        email: 'info@femevent.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u3 = new User(
          firstName: 'Moses',
          lastName: 'Dlamini',
          password: 'mpassword123',
          email: 'mosesd@femevent.com');
      await signUp.signUpSupplier(e3, u3);

      Supplier e4 = new Supplier(
        name: 'Soweto Social Management',
        email: 'info@femevent.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u4 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'mpassword123',
          email: 'dkhoza@femevent.com');
      await signUp.signUpSupplier(e4, u4);

      Supplier e5 = new Supplier(
        name: 'TrebleX Engineering',
        email: 'info@engineers.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u5 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'mpassword123',
          email: 'danielkk@engineers.com');
      await signUp.signUpSupplier(e5, u5);

      Supplier e6 = new Supplier(
        name: 'DHH Transport Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u6 = new User(
          firstName: 'Peter',
          lastName: 'Johnson',
          password: 'mpassword123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e6, u6);

      Supplier e7 = new Supplier(
        name: 'ZamaZama Transport Logistics',
        email: 'info@zamatransport.com',
        country: 'South Africa',
        privateSectorType: 'Industrial',
      );
      User u7 = new User(
          firstName: 'Susan',
          lastName: 'Oakley-Smith',
          password: 'mpassword123',
          email: 'susanoak@zamatransport.com');
      await signUp.signUpSupplier(e7, u7);
    } catch (e) {
      print('GovtUtil.generateSuppliers ERROR $e');
      return 1;
    }
    print('GovtUtil.generateSuppliers COMPLETED');
    return 0;
  }
}
