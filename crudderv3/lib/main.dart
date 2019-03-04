import 'dart:async';
import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/FCM.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:crudderv3/generator.dart';
import 'package:crudderv3/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'BFN Crudder',
      debugShowCheckedModeBanner: false,
      theme: getTheme(),
      home: new MyHomePage(title: 'Business Finance Network 1.0'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    implements GenListener, SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _phaseCounter = 0;
  double opacity;
  static const NameSpace = 'resource:com.oneconnect.biz.';
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  bool isBusy = false;
  String btnText = "Generate Working Data", phases = FIVE;
  bool isBrandNew = false;
  int recordCounter = 0;
  FCM _fcm = FCM();

  @override
  initState() {
    super.initState();
  }

  Future testChaincode() async {
    setState(() {
      msgList.add('💦  💦  💦  💦  CHAINCODE CALLS ..');
    });
    List offers = await DataAPI3.testChainCode('getAllOffers');
    setState(() {
      msgList.add('😍 😍 😍  Found  ${offers.length} offers');
    });

    List invoices = await DataAPI3.testChainCode('getAllInvoices');
    setState(() {
      msgList.add('😍 😍 😍  Found  ${invoices.length} invoices');
    });
    List notes = await DataAPI3.testChainCode('getAllDeliveryNotes');
    setState(() {
      msgList.add('😍 😍 😍  Found  ${notes.length} deliveryNotes');
    });

    List result0 = await DataAPI3.testChainCode('getAllCustomers');
    setState(() {
      msgList.add('💛 💛 💛  Found  ${result0.length} customers');
    });
    print('\n 💦  💦  💦 $result0 \n 💦  💦  💦');
    List result1 = await DataAPI3.testChainCode('getAllSuppliers');
    print('\n 💦  💦  💦 $result1 \n 💦  💦  💦');
    setState(() {
      msgList.add('❤️  ❤️  ❤️  Found  ${result1.length} suppliers');
    });
    List result2 = await DataAPI3.testChainCode('getAllInvestors');
    print('\n 💦  💦  💦 $result2 \n 💦  💦  💦');
    setState(() {
      msgList.add('💚  💚  💚  Found  ${result2.length} investors');
    });
    List result3 = await DataAPI3.testChainCode('getAllSectors');
    print('\n 💦  💦  💦 $result3 \n 💦  💦  💦');
    setState(() {
      msgList.add('🙄 🙄 🙄  Found  ${result3.length} sectors');
    });
    List result4 = await DataAPI3.testChainCode('getAllCountries');
    print('\n 💦  💦  💦 $result4 \n 💦  💦  💦');
    setState(() {
      msgList.add('🔵 🔵 🔵  Found  ${result4.length} countries');
    });

    return 0;
  }

  void _generateBrandNewNetwork() async {
    Navigator.pop(context);

    if (!isBrandNew) {
      print(
          '_MyHomePageState._generateBrandNewNetwork - NETWORK ALREADY PAST Genesis. IGNORED. OUT.');
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Genesis Run already executed. Out.',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (isBusy) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Process busy or finished. May not be run twice',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }
    isBusy = true;
    var start = DateTime.now();
    print('\n\n💦 💦  💦 💦  💦 💦  💦 💦  _generateBrandNewNetwork ... ');
    setState(() {
      btnText = 'Working...Please Wait';
      phases = SIX;
      _phaseCounter++;
      msgList.add('💦 💦  Demo data cleanup is complete');
      msgList.add('💦 💦  Adding sectors ...');
    });

    await DataAPI3.addSectors();
    setState(() {
      msgList.add('💦 💦  Sectors added to BFN and Firestore');
      msgList.add('💦 💦  Adding countries ...');
      _phaseCounter++;
    });
    await DataAPI3.addCountries();
    setState(() {
      msgList.add('💦 💦  Countries added to BFN and Firestore');
      msgList.add('💦 💦  Adding customers ...');
      _phaseCounter++;
    });
    await _addCustomers();
    setState(() {
      _phaseCounter++;
      msgList.add('💦 💦  Customers added to BFN and Firestore');
      msgList.add('💦 💦  Adding suppliers ...');
    });
    await _addSuppliers();
    setState(() {
      _phaseCounter++;
      msgList.add('💦 💦  Suppliers added to BFN and Firestore');
      msgList.add('💦 💦  Adding investors ...');
    });
    await _addInvestors();

    var end = DateTime.now();
    var diffm = end.difference(start).inMinutes;
    var diffs = end.difference(start).inSeconds;
    setState(() {
      _phaseCounter++;
      msgList.add('💦 💦  Investors added to BFN and Firestore');
      msgList.add('❤️ ❤️  Done Generating data ... $diffs seconds elapsed');
    });

    isBusy = false;
    isBrandNew = false;
    btnText = 'Generate New Working Data';
    phases = SIX;
    btnColor = Colors.pink.shade800;

    print(
        '\n\n_MyHomePageState._start  ❤️ ❤️ ❤️ ❤️ ❤️ ###################### GENESIS : Demo Data COMPLETED!');
  }

  void _generateWorkingData() async {
    if (isBusy) {
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Process busy or finished. May not be run twice',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      return;
    }

    isBusy = true;
    setState(() {
      recordCounter = 0;
      _phaseCounter = 0;
      msgList.clear();
    });

    var start = DateTime.now();
//    await Generator.generateOffers(this, context);
//    await Generator.generate(this, context);
//    await Generator.doTheRest(this, context);
//    await Generator.finishItOff(this, context);
//    await Generator.reallyFinishItOff(this, context);
//    await Generator.generateProfilesAndOrders(this, context);
    await Generator.generateTemporaryProfiles(this, context);

    isBusy = false;
    var end = DateTime.now();
    var diffm = end.difference(start).inMinutes;
    var diffs = end.difference(start).inSeconds;

    setState(() {
      phases = FIVE;
      msgList.add(
          ' 🔵 🔵 🔵 Generation complete:, $diffm minutes elapsed. ($diffs seconds)');
    });
    print(
        '\n\n_MyHomePageState._start  #####################################  Demo Data COMPLETED!');
  }

  static const FIVE = '5', SIX = '5';
  List<String> msgList = List();

  double getRandomMax(double invoiceAmount) {
    int m = rand.nextInt(1000);
    if (m < 500) {
      return invoiceAmount * 500;
    }
    if (m < 800) {
      return invoiceAmount * 800;
    }
    return invoiceAmount * 1000;
  }

  double _getRandomInvoiceAmount() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(100) * 6950.00;
    } else {
      seed = rand.nextInt(100) * 765.00;
    }
    if (seed == 0.0) {
      seed = 100000.00;
    }
    return seed;
  }

  List<Customer> customers = List();
  Future _addCustomers() async {
    try {
      Customer e1 = new Customer(
        name: 'Atteridgeville MetalWorks Ltd',
        email: 'info@works.com',
        country: 'South Africa',
        allowAutoAccept: true,
      );
      User u1 = new User(
          firstName: 'Jonathan B.',
          lastName: 'Zondi',
          password: 'pass123',
          isAdministrator: true,
          email: 'jzondi@works.com');
      var result1 = await DataAPI3.addCustomer(e1, u1);
      customers.add(result1);
      setState(() {
        msgList.add('❤️  Customer added: ${e1.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }

    try {
      Customer e2 = new Customer(
        name: 'Joburg Catering',
        email: 'info@jhbcaterer.com',
        country: 'South Africa',
        allowAutoAccept: true,
      );
      User u2 = new User(
          firstName: 'Donald',
          lastName: 'Trump',
          password: 'pass123',
          isAdministrator: true,
          email: 'orangebaboon@jhbcaterer.com');
      var result2 = await DataAPI3.addCustomer(e2, u2);
      customers.add(result2);
      setState(() {
        msgList.add('❤️  Customer added: ${e2.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
      Customer e3 = new Customer(
        name: 'Dept of Agriculture',
        email: 'info@agric.gov.za',
        country: 'South Africa',
        allowAutoAccept: true,
      );
      User u3 = new User(
          firstName: 'Kenneth',
          lastName: 'Donnelly',
          password: 'pass123',
          isAdministrator: true,
          email: 'kendonnelly@agric.gov.za');
      var result3 = await DataAPI3.addCustomer(e3, u3);
      customers.add(result3);
      setState(() {
        msgList.add('❤️  Customer added: ${e3.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
      Customer e4 = new Customer(
        name: 'Dept of Science',
        email: 'info@mscience.gov.za',
        country: 'South Africa',
        allowAutoAccept: true,
      );
      User u4 = new User(
          firstName: 'Peter',
          lastName: 'van der Merwe',
          password: 'pass123',
          isAdministrator: true,
          email: 'petervdm@mscience.gov.za');
      var result4 = await DataAPI3.addCustomer(e4, u4);
      customers.add(result4);
      setState(() {
        msgList.add('❤️  Customer added: ${e4.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
      Customer e5 = new Customer(
        name: 'Select n Pay',
        email: 'info@pickandpay.com',
        country: 'South Africa',
        allowAutoAccept: true,
      );
      User u5 = new User(
          firstName: 'Harry',
          lastName: 'Peterson',
          password: 'pass123',
          isAdministrator: true,
          email: 'harry@pickandpay.com');
      var result5 = await DataAPI3.addCustomer(e5, u5);
      customers.add(result5);
      setState(() {
        msgList.add('❤️  Customer added: ${e5.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      msgList.add('❤️ ❤️ ❤️ ❤️   Customers  added: ${customers.length}');
    });
  }

  List<Investor> investors = List();
  Future _addInvestors() async {
    try {
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
      var result1 = await DataAPI3.addInvestor(e1, u1);
      investors.add(result1);
      setState(() {
        msgList.add(' 😍  Investor  added: ${e1.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result2 = await DataAPI3.addInvestor(e2, u2);
      investors.add(result2);
      setState(() {
        msgList.add(' 😍  Investor  added: ${e2.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result3 = await DataAPI3.addInvestor(e3, u3);
      investors.add(result3);
      setState(() {
        msgList.add(' 😍  Investor  added: ${e3.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result4 = await DataAPI3.addInvestor(e4, u4);
      investors.add(result4);
      setState(() {
        msgList.add(' 😍  Investor  added: ${e4.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
      Investor e5 = new Investor(
        name: 'CashFlow Kings',
        email: 'info@mcashkings.com',
        country: 'South Africa',
      );
      User u5 = new User(
          firstName: 'Daniel',
          lastName: 'Berger',
          password: 'pass123',
          isAdministrator: true,
          email: 'danb@mcashkings.com');
      var result5 = await DataAPI3.addInvestor(e5, u5);
      investors.add(result5);
      setState(() {
        msgList.add(' 😍  Investor  added: ${e5.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      msgList.add(' 😍 😍 😍 😍  Investors  added: ${investors.length}');
    });
  }

  Color btnColor = Colors.orange.shade800;
  ScrollController controller1 = ScrollController();
  bool weHaveMELTDOWN = false;
  double prefSize = 200.0;

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(prefSize),
      child: Column(
        children: <Widget>[
          weHaveMELTDOWN == false
              ? Container()
              : Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 20.0, top: 20.0),
                  child: Container(
                    color: Colors.pink.shade800,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
                      child: Text(
                          message == null
                              ? 'Testing the error message\nTesting the error message\nTesting the error message\nTesting the error message\nTesting the error message\nweHaveMELTDOWN == true\nweHaveMELTDOWN == true\nweHaveMELTDOWN == true\n'
                              : message,
                          style: Styles.whiteSmall),
                    ),
                  ),
                ),
          weHaveMELTDOWN == true
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 44.0, bottom: 12.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Execution Mode',
                        style: Styles.whiteMedium,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Switch(
                          value: isBrandNew,
                          onChanged: _onSwitch,
                          activeColor: btnColor,
                        ),
                      ),
                    ],
                  ),
                ),
          weHaveMELTDOWN == true
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: RaisedButton(
                    onPressed: _chooseMode,
                    elevation: 16.0,
                    color: btnColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        btnText,
                        style: Styles.whiteBoldMedium,
                      ),
                    ),
                  ),
                ),
          _getPhaseMessage(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'BFN Data Generator',
            style: Styles.whiteBoldMedium,
          ),
          bottom: _getBottom(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                testChaincode();
              },
            )
          ],
        ),
        backgroundColor: Colors.brown.shade100,
        body: _getListView());
  }

  String message;
  Widget _getPhaseMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 30.0, bottom: 20.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: <Widget>[
              Text(
                'Phase Complete:',
                style: Styles.blackBoldSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  '$_phaseCounter',
                  style: Styles.whiteBoldLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 12.0),
                      child: Text(
                        recordCounter == 0 ? '000' : '$recordCounter',
                        style: Styles.yellowBoldReallyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Supplier> suppliers = List();
  _addSuppliers() async {
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
      var result1 = await DataAPI3.addSupplier(e1, u1);
      suppliers.add(result1);
      setState(() {
        recordCounter++;
        msgList.add('💋  Suppliaer added: ${e1.name}');
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result2 = await DataAPI3.addSupplier(e2, u2);
      suppliers.add(result2);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e2.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result5 = await DataAPI3.addSupplier(e5, u5);
      suppliers.add(result5);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e5.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result6 = await DataAPI3.addSupplier(e6, u6);
      suppliers.add(result6);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e6.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result7 = await DataAPI3.addSupplier(e7, u7);
      suppliers.add(result7);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e7.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result8 = await DataAPI3.addSupplier(e8, u8);
      suppliers.add(result8);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e8.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result9 = await DataAPI3.addSupplier(e9, u9);
      suppliers.add(result9);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e9.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result10 = await DataAPI3.addSupplier(e10, u10);
      suppliers.add(result10);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e10.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result11 = await DataAPI3.addSupplier(e11, u11);
      suppliers.add(result11);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e11.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result12 = await DataAPI3.addSupplier(e12, u12);
      suppliers.add(result12);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e12.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result13 = await DataAPI3.addSupplier(e13, u13);
      suppliers.add(result13);
      setState(() {
        msgList.add('💋  Suppliaer added: ${e13.name}');
        recordCounter++;
      });
    } catch (e) {
      print(e);
    }
    try {
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
      var result14 = await DataAPI3.addSupplier(e14, u14);
      suppliers.add(result14);
      print('Generator.generateSuppliers COMPLETED');
      setState(() {
        msgList.add('💋  Suppliaer added: ${e14.name}');
        recordCounter++;
      });
    } catch (e) {
      print('Generator.generateSuppliers ERROR $e');
      //throw Exception('Bad juju. eh?');
    }
    setState(() {
      msgList.add('💋 💋 💋 💋   Suppliers  added: ${suppliers.length}');
    });
    return;
  }

  _getListView() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });

    return ListView.builder(
        itemCount: msgList.length,
        controller: controller1,
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
          if (msgList[position].contains('Purchase order added')) {
            color = Colors.purple.shade900;
          }
          if (msgList[position].contains('Delivery Note added')) {
            color = Colors.pink.shade900;
          }
          if (msgList[position].contains('DeliveryAcceptance added')) {
            color = Colors.blue.shade900;
          }
          if (msgList[position].contains('Invoice added')) {
            color = Colors.teal.shade900;
          }
          if (msgList[position].contains('Offer added')) {
            color = Colors.red.shade900;
          }
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 6),
            child: MessageCard(
              message: msgList[position],
              color: color,
            ),
          );
        });
  }

  @override
  onEvent(String message, bool isRecordAdded) {
    setState(() {
      if (isRecordAdded) {
        recordCounter++;
      }
      msgList.add(message);
    });
  }

  void _onSwitch(bool value) {
    print('_MyHomePageState._onSwitch value: $value');
    isBrandNew = value;
    if (isBrandNew) {
      btnText = 'Generate Brand New Network';
      phases = SIX;
      btnColor = Colors.indigo.shade800;
    } else {
      btnText = 'Generate New Working Data';
      phases = '1';
      btnColor = Colors.orange.shade800;
    }
    setState(() {});
  }

  void _chooseMode() {
    if (isBrandNew) {
      _confirmBrandNewDialog();
    } else {
      _generateWorkingData();
      //fixInvestorProfiles();
      //fixAutoTradeOrders();
    }
  }

  void _confirmBrandNewDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Confirm Brand New BFN",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 300.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Do you want to create a new BFN Network?\n\nPlease note that this will destroy all the existing Firestore data and make like a new house. It also assumes a brand new blockchain has been set up.\n\nYou cool wid dat?'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'NO',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                    onPressed: _generateBrandNewNetwork,
                    elevation: 4.0,
                    color: Colors.teal.shade400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Generate new BFN data',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ));
  }

  @override
  onPhaseComplete() {
    setState(() {
      _phaseCounter++;
    });
  }

  @override
  onActionPressed(int action) {
    // TODO: implement onActionPressed
  }

  @override
  onError(String message) {
    print(message);
    msgList.add(message);
    setState(() {
      this.message = message;
    });
  }

  @override
  onOfferMessage(Offer offer) {
    print(
        '_MyHomePageState.onOfferMessage: ############ Offer received in Crudder: ${offer.supplierName} ${offer.offerAmount}');
    return null;
  }

  @override
  onResetCounter() {
    setState(() {
      recordCounter = 0;
    });
  }
}

class MessageCard extends StatelessWidget {
  final String message;
  final Color color;

  MessageCard({this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0),
        child: ListTile(
          leading: Icon(Icons.create),
          title: Text(
            message,
            style: Styles.blackSmall,
          ),
        ),
      ),
    );
  }
}
