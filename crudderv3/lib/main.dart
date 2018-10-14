import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
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
  static const NameSpace = 'resource:com.oneconnect.biz.';
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  @override
  initState() {
    super.initState();
    print('\n\n_MyHomePageState.initState ###################\n\n');
    _start();
  }

  void _start() async {
    var start = DateTime.now();
    await _cleanUp();
    setState(() {
      _counter++;
      msgList.add('Demo data cleanup is complete');
    });
    await DataAPI3.addSectors();

    setState(() {
      msgList.add('Sectors added to BFN and Firestore');
      _counter++;
    });
    await _generateSuppliers();
    setState(() {
      _counter++;
      msgList.add('Suppliers added to BFN and Firestore');
    });
    await _addCustomers();
    setState(() {
      _counter++;
      msgList.add('Customers added to BFN and Firestore');
    });
    await _addInvestors();
    var end = DateTime.now();
    var diff = end.difference(start).inMinutes;
    print(
        '\n\n_MyHomePageState._start ELAPSED SECONDS for DemoData $diff ##########\n\n');

    setState(() {
      _counter++;
      msgList.add('Investors added to BFN and Firestore');
      msgList.add('Demo data Generation complete:, elapsed minutes: $diff');
    });
    print(
        '_MyHomePageState._start  #####################################  Demo Data COMPLETED!');
  }

  List<String> msgList = List();

  _addCustomers() async {
    GovtEntity e1 = new GovtEntity(
      name: 'Pretoria Engineering',
      email: 'info@mvengineers.com',
      country: 'South Africa',
    );
    User u1 = new User(
        firstName: 'Fanyana',
        lastName: 'Maluleke',
        password: 'pass123',
        isAdministrator: true,
        email: 'fanyana@mvengineers.com');
    await SignUp.signUpGovtEntity(e1, u1);
    setState(() {
      msgList.add('Customer added: ${e1.name}');
    });

    GovtEntity e2 = new GovtEntity(
      name: 'Joburg Catering',
      email: 'info@mcaterer.com',
      country: 'South Africa',
    );
    User u2 = new User(
        firstName: 'Donald',
        lastName: 'Trump',
        password: 'pass123',
        isAdministrator: true,
        email: 'trump@mcaterer.com');
    await SignUp.signUpGovtEntity(e2, u2);
    setState(() {
      msgList.add('Customer added: ${e2.name}');
    });

    GovtEntity e3 = new GovtEntity(
      name: 'Dept of Agriculture',
      email: 'info@magric.com',
      country: 'South Africa',
    );
    User u3 = new User(
        firstName: 'Kenneth',
        lastName: 'Donnelly',
        password: 'pass123',
        isAdministrator: true,
        email: 'trump@magric.com');
    await SignUp.signUpGovtEntity(e3, u3);
    setState(() {
      msgList.add('Customer added: ${e3.name}');
    });

    GovtEntity e4 = new GovtEntity(
      name: 'Dept of Science',
      email: 'info@mscience.com',
      country: 'South Africa',
    );
    User u4 = new User(
        firstName: 'Peter',
        lastName: 'van der Merwe',
        password: 'pass123',
        isAdministrator: true,
        email: 'ken@mscience.com');
    await SignUp.signUpGovtEntity(e4, u4);
    setState(() {
      msgList.add('Customer added: ${e4.name}');
    });

    GovtEntity e5 = new GovtEntity(
      name: 'Pick n Pay',
      email: 'info@mpickp.com',
      country: 'South Africa',
    );
    User u5 = new User(
        firstName: 'Harry',
        lastName: 'Peterson',
        password: 'pass123',
        isAdministrator: true,
        email: 'harry@mpickandp.com');
    await SignUp.signUpGovtEntity(e5, u5);
    setState(() {
      msgList.add('Customer added: ${e5.name}');
    });
  }

  _addInvestors() async {
    Investor e1 = new Investor(
      name: 'Pretoria Investors Ltd',
      email: 'info@investors.com',
      country: 'South Africa',
    );
    User u1 = new User(
        firstName: 'Frank',
        lastName: 'Green',
        password: 'pass123',
        isAdministrator: true,
        email: 'green@investors.com');
    await SignUp.signUpInvestor(e1, u1);
    setState(() {
      msgList.add('Investor added: ${e1.name}');
    });

    Investor e2 = new Investor(
      name: 'Invoice Gurus Ltd',
      email: 'info@invoicegurus.com',
      country: 'South Africa',
    );
    User u2 = new User(
        firstName: 'George',
        lastName: 'Wallace',
        password: 'pass123',
        isAdministrator: true,
        email: 'george@invoicegurus.com');
    await SignUp.signUpInvestor(e2, u2);
    setState(() {
      msgList.add('Investor added: ${e2.name}');
    });

    Investor e3 = new Investor(
      name: 'Funders Inc.',
      email: 'info@funders.com',
      country: 'South Africa',
    );
    User u3 = new User(
        firstName: 'Harrison',
        lastName: 'Johnson',
        password: 'pass123',
        isAdministrator: true,
        email: 'harry@funders.com');
    await SignUp.signUpInvestor(e3, u3);
    setState(() {
      msgList.add('Investor added: ${e3.name}');
    });

    Investor e4 = new Investor(
      name: 'InvestorsGalore LLC',
      email: 'info@galore.com',
      country: 'South Africa',
    );
    User u4 = new User(
        firstName: 'Mike',
        lastName: 'Michaelson',
        password: 'pass123',
        isAdministrator: true,
        email: 'mike@galore.com');
    await SignUp.signUpInvestor(e4, u4);
    setState(() {
      msgList.add('Investor added: ${e4.name}');
    });

    Investor e5 = new Investor(
      name: 'CashFlow Kings',
      email: 'info@mcash.com',
      country: 'South Africa',
    );
    User u5 = new User(
        firstName: 'Daniel',
        lastName: 'Berger',
        password: 'pass123',
        isAdministrator: true,
        email: 'danb@mcash.com');
    await SignUp.signUpInvestor(e5, u5);
    setState(() {
      msgList.add('Investor added: ${e5.name}');
    });
  }

  _removeUsers() async {
    var fs = Firestore.instance;
    var now = getUTCDate();
    var data = {'now': now, 'desc': 'Trigger deletion of auth users'};
    var res = await fs.collection('usersDeleteTriggers').add(data);
    print(res);
    setState(() {
      msgList.add(
          'Users being removed from Firestore, will pause 15 seconds to let the process finish');
    });
    print(
        '\n\n\n_MyHomePageState.cleanUp ... sleeping for 15 seconds .......${DateTime.now().toIso8601String()}');
    sleep(Duration(seconds: 15));
  }

  Future<int> _cleanUp() async {
    print(
        '\n\n\nGenerator.cleanUp ................ ########  ................\n\n');
    setState(() {
      msgList.add('Firestore and Auth user clean up started');
    });
    await _removeUsers();
    print(
        '_MyHomePageState.cleanUp ... slept for 15 seconds. waking up: ....${DateTime.now().toIso8601String()}\n\n\n');
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
      /////
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
        var msnapx =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnapx.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2a = await doc.reference
            .collection('deliveryAcceptances')
            .getDocuments();
        msnap2a.documents.forEach((x) async {
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
      print('Generator.cleanUp suppliers deleted from Firestore #############');

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
      var qs13 = await fs.collection('autoTradeOrders').getDocuments();
      qs13.documents.forEach((doc) async {
        doc.reference.delete();
      });
      var qs14 = await fs.collection('investorProfiles').getDocuments();
      qs14.documents.forEach((doc) async {
        doc.reference.delete();
      });
      var qs15 = await fs.collection('autoTradeStarts').getDocuments();
      qs15.documents.forEach((doc) async {
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Phase Complete',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              '$_counter',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue.shade900),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              'of',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '5',
                              style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _getListView());
  }

  Future<int> _generateSuppliers() async {
    print('Generator.generateSuppliers ............');

    try {
      Supplier e1 = new Supplier(
        name: 'Mkhize Electrical',
        email: 'info@mkhize.com',
        country: 'South Africa',
      );
      User u1 = new User(
          firstName: 'David',
          lastName: 'Mkhize',
          password: 'pass123',
          isAdministrator: true,
          email: 'dmkhize@mkhize.com');
      await SignUp.signUpSupplier(e1, u1);
      setState(() {
        msgList.add('Supplier added: ${e1.name}');
      });

      Supplier e2 = new Supplier(
        name: 'Dlamini Contractors',
        email: 'info@dlamini.com',
        country: 'South Africa',
      );
      User u2 = new User(
          firstName: 'Moses',
          lastName: 'Dlamini',
          password: 'pass123',
          isAdministrator: true,
          email: 'ddlam@dlamini.com');
      await SignUp.signUpSupplier(e2, u2);
      setState(() {
        msgList.add('Supplier added: ${e2.name}');
      });

      Supplier e5 = new Supplier(
        name: 'TrebleX Engineering',
        email: 'info@engineers.com',
        country: 'South Africa',
      );
      User u5 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'pass123',
          isAdministrator: true,
          email: 'danielkk@engineers.com');
      await SignUp.signUpSupplier(e5, u5);
      setState(() {
        msgList.add('Supplier added: ${e5.name}');
      });

      Supplier e6 = new Supplier(
        name: 'DHH Transport Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
      );
      User u6 = new User(
          firstName: 'Peter',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'petejohn@dhhtransport.com');
      await SignUp.signUpSupplier(e6, u6);
      setState(() {
        msgList.add('Supplier added: ${e6.name}');
      });

      Supplier e7 = new Supplier(
        name: 'FX Super Logistics',
        email: 'info@fxtransport.com',
        country: 'South Africa',
      );
      User u7 = new User(
          firstName: 'Samuel',
          lastName: 'Mathebula',
          password: 'pass123',
          isAdministrator: true,
          email: 'sam@fxtransport.com');
      await SignUp.signUpSupplier(e7, u7);
      setState(() {
        msgList.add('Supplier added: ${e7.name}');
      });

      Supplier e8 = new Supplier(
        name: 'Davids Rolling Logistics',
        email: 'info@rolliin.com',
        country: 'South Africa',
      );
      User u8 = new User(
          firstName: 'Thomas',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'tom@rolliin.com');
      await SignUp.signUpSupplier(e8, u8);
      setState(() {
        msgList.add('Supplier added: ${e8.name}');
      });

      Supplier e9 = new Supplier(
        name: 'Pope Transport Logistics',
        email: 'info@pope.com',
        country: 'South Africa',
      );
      User u9 = new User(
          firstName: 'Daniel',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'xman@pope.com');
      await SignUp.signUpSupplier(e9, u9);
      setState(() {
        msgList.add('Supplier added: ${e9.name}');
      });

      Supplier e10 = new Supplier(
        name: 'Naidoo Transport Logistics',
        email: 'info@naidoo.com',
        country: 'South Africa',
      );
      User u10 = new User(
          firstName: 'Sithwell',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'pete@naidoo.com');
      await SignUp.signUpSupplier(e10, u10);
      setState(() {
        msgList.add('Supplier added: ${e10.name}');
      });

      Supplier e11 = new Supplier(
        name: 'Green Logistics',
        email: 'info@greenlogs.com',
        country: 'South Africa',
      );
      User u11 = new User(
          firstName: 'Evelyn',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'eve@greenlogs.com');
      await SignUp.signUpSupplier(e11, u11);
      setState(() {
        msgList.add('Supplier added: ${e11.name}');
      });

      Supplier e12 = new Supplier(
        name: 'Wendywood Transporters',
        email: 'info@wendywood.com',
        country: 'South Africa',
      );
      User u12 = new User(
          firstName: 'Mary',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'mary@wendywood.com');
      await SignUp.signUpSupplier(e12, u12);
      setState(() {
        msgList.add('Supplier added: ${e12.name}');
      });
      Supplier e13 = new Supplier(
        name: 'Xavier TTransport',
        email: 'info@xavier.com',
        country: 'South Africa',
      );
      User u13 = new User(
          firstName: 'Xavier',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'xavier@xavier.com');
      await SignUp.signUpSupplier(e13, u13);
      setState(() {
        msgList.add('Supplier added: ${e13.name}');
      });

      Supplier e14 = new Supplier(
        name: 'Danielson Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
      );
      User u14 = new User(
          firstName: 'dan',
          lastName: 'Johnson',
          password: 'pass123',
          isAdministrator: true,
          email: 'danj@logs.com');
      await SignUp.signUpSupplier(e14, u14);
      print('Generator.generateSuppliers COMPLETED');
      setState(() {
        msgList.add('Supplier added: ${e14.name}');
      });
    } catch (e) {
      print('Generator.generateSuppliers ERROR $e');
      return 1;
    }

    return 0;
  }

  _getListView() {
    return ListView.builder(
        itemCount: msgList.length,
        itemBuilder: (context, position) {
          Color color = Colors.black;
          if (msgList[position].contains('Supplier')) {
            color = Colors.pink;
          }
          if (msgList[position].contains('Investor')) {
            color = Colors.indigo;
          }
          if (msgList[position].contains('Customer')) {
            color = Colors.brown.shade900;
          }
          if (msgList[position].contains('elapsed')) {
            color = Colors.teal.shade900;
          }
          if (msgList[position].contains('Auth')) {
            color = Colors.purple.shade900;
          }
          return MessageCard(
            message: msgList[position],
            color: color,
          );
        });
  }
}

class MessageCard extends StatelessWidget {
  final String message;
  final Color color;

  MessageCard({this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 4.0, left: 12.0, right: 12.0, bottom: 12.0),
          child: Text(
            message,
            style: TextStyle(color: color, fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
