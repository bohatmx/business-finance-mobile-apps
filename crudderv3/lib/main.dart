import 'dart:async';
import 'dart:math';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudderv3/theme_util.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: getTheme(),
      home: new MyHomePage(title: 'Business Finance Network'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double opacity;
  static Firestore _fs = Firestore.instance;
  static const NameSpace = 'resource:com.oneconnect.biz.';
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  static DataAPI dataAPI;
  @override
  initState() {
    super.initState();
  }

  void _cleanFirestoreUp() async {
    await cleanUp();
    setState(() {
      _counter++;
    });
    var api = DataAPI(getURL());
    await api.addSectors();

    setState(() {
      _counter++;
    });
  }

  Future<int> cleanUp() async {
    print('Generator.cleanUp ................ ########  ................');
    var fs = Firestore.instance;
    try {
      var qs0 = await fs.collection('users').getDocuments();
      qs0.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print('Generator.cleanUp users deleted from Firestore ################');
      var qs = await fs.collection('wallets').getDocuments();
      qs.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp wallets deleted from Firestore ################');
      var qsx = await fs.collection('walletsFailed').getDocuments();
      qsx.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp walletsFailed deleted from Firestore ################');
      var qs1 = await fs.collection('oneConnect').getDocuments();
      qs1.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp oneConnect deleted from Firestore ################');
      var qs2 = await fs.collection('govtEntities').getDocuments();
      qs2.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });

        var msnap4 = await doc.reference
            .collection('deliveryAcceptances')
            .getDocuments();
        msnap4.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap6 =
            await doc.reference.collection('invoiceAcceptances').getDocuments();
        msnap6.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp govtEntities deleted from Firestore ################');
      var qs3 = await fs.collection('suppliers').getDocuments();
      qs3.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap4 =
            await doc.reference.collection('supplierContracts').getDocuments();
        msnap4.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap5 = await doc.reference
            .collection('deliveryAcceptances')
            .getDocuments();
        msnap5.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap6 =
            await doc.reference.collection('invoiceAcceptances').getDocuments();
        msnap6.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp suppliers deleted from Firestore ##############');

      var qs5 = await fs.collection('investors').getDocuments();
      qs5.documents.forEach((doc) async {
        var msnap4 =
            await doc.reference.collection('invoiceBids').getDocuments();
        msnap4.documents.forEach((x) async {
          await x.reference.delete();
        });

        await doc.reference.delete();
      });

      print(
          'Generator.cleanUp investors deleted from Firestore ######################');
      var qs6 = await fs.collection('procurementOffices').getDocuments();
      qs6.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp investors deleted from Firestore ######################');
      var qs7 = await fs.collection('companies').getDocuments();
      qs7.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap4 = await doc.reference
            .collection('deliveryAcceptances')
            .getDocuments();
        msnap4.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp companies deleted from Firestore ###############');
      var qs8 = await fs.collection('banks').getDocuments();
      qs8.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print('Generator.cleanUp banks deleted from Firestore ##############');
      var qs9 = await fs.collection('procurementOffices').getDocuments();
      qs9.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp procurementOffices deleted from Firestore   #############');
      var qs10 = await fs.collection('auditors').getDocuments();
      qs10.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print('Generator.cleanUp auditors deleted from Firestore ##############');
      var qs11 = await fs.collection('invoiceOffers').getDocuments();
      qs11.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('invoiceBids').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });

        await doc.reference.delete();
      });
      var qs12 = await fs.collection('sectors').getDocuments();
      qs12.documents.forEach((doc) async {
        doc.reference.delete();
      });

      print(
          'Generator.cleanUp invoiceOffers and invoiceBids deleted from Firestore and FirebaseStorage ##############');
    } catch (e) {
      print('Generator.cleanUp ERROR $e');
      return 1;
    }
    print('Generator.cleanUp COMPLETED........... start the real work!!');
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140.0),
          child: Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Demo Data Generation',
                  style: TextStyle(color: Colors.white, fontSize: 24.0),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Text(
                  'Generating Data Needed for BFN',
                  style: TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Card(
        elevation: 8.0,
        child: new Padding(
          padding: const EdgeInsets.only(
              top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            children: <Widget>[
              Text(
                'Phase Complete',
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_counter',
                style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.teal),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.indigo.shade50,
      floatingActionButton: new FloatingActionButton(
        onPressed: _generateSuppliers,
        tooltip: 'Generate Data',
        child: Text(
          'Start',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  static Future<int> _generateSuppliers() async {
    print('Generator.generateSuppliers ............');
    SignUp signUp = SignUp(getURL());
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
          password: 'pass123',
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
          password: 'pass123',
          email: 'ddlam@dlamini.com');
      await signUp.signUpSupplier(e2, u2);

      Supplier e5 = new Supplier(
        name: 'TrebleX Engineering',
        email: 'info@engineers.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u5 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'pass123',
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
          password: 'pass123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e6, u6);

      Supplier e7 = new Supplier(
        name: 'FX Super Logistics',
        email: 'info@fxtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u7 = new User(
          firstName: 'Samuel',
          lastName: 'Mathebula',
          password: 'pass123',
          email: 'sam@dhhtransport.com');
      await signUp.signUpSupplier(e7, u7);

      Supplier e8 = new Supplier(
        name: 'Davids Rolling Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u8 = new User(
          firstName: 'Thomas',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e8, u8);

      Supplier e9 = new Supplier(
        name: 'Pope Transport Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u9 = new User(
          firstName: 'Daniel',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e9, u9);

      Supplier e10 = new Supplier(
        name: 'Naidoo Transport Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u10 = new User(
          firstName: 'Sithwell',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e10, u10);

      Supplier e11 = new Supplier(
        name: 'Green Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u11 = new User(
          firstName: 'Evelyn',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'eve@dhhtransport.com');
      await signUp.signUpSupplier(e11, u11);

      Supplier e12 = new Supplier(
        name: 'Wendywood Transporters',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u12 = new User(
          firstName: 'Mary',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'eve@dhhtransport.com');
      await signUp.signUpSupplier(e12, u12);
      Supplier e13 = new Supplier(
        name: 'Xavier TTransport',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u13 = new User(
          firstName: 'Xavier',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'eve@dhhtransport.com');
      await signUp.signUpSupplier(e13, u13);

      Supplier e14 = new Supplier(
        name: 'Danielson Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u14 = new User(
          firstName: 'dan',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'eve@dhhtransport.com');
      await signUp.signUpSupplier(e14, u14);
      print('Generator.generateSuppliers COMPLETED');
    } catch (e) {
      print('Generator.generateSuppliers ERROR $e');
      return 1;
    }

    return 0;
  }
}
