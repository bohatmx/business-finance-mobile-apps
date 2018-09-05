import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  InvestorProfile profile;
  Investor investor;
  List<Supplier> suppliers;
  List<Sector> sectors;

  @override
  initState() {
    super.initState();
    _getLookups();
  }

  void _getCachedData() async {
    print('_ProfilePageState._getCachedData ................................');
    investor = await SharedPrefs.getInvestor();
    profile = await SharedPrefs.getInvestorProfile();

    //prettyPrint(investor.toJson(), 'investor from cache ................');
    // print('_ProfilePageState._getCachedData ########################### ...');
    controller1.text = '1000.00';
    controller1.text = '50.00';
    setState(() {});
  }

  void _getLookups() async {
    _getCachedData();

    sectors = await ListAPI.getSectors();
    suppliers = await ListAPI.getSuppliers();

    setState(() {});
  }

  @override
  onActionPressed(int action) {
    switch (action) {
      case 3:
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Investor Profile',
          style: Styles.whiteBoldMedium,
        ),
        bottom: _getBottom(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4.0,
          child: _getForm(),
        ),
      ),
    );
  }

  _onSubmit() async {
    if (_formKey.currentState.validate()) {
      print('_ProfilePageState._onSubmit ********* VALID Form:');

      var p = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
        date: DateTime.now().toIso8601String(),
        maxInvestableAmount: maxInvesttale,
        maxInvoiceAmount: maxInvoiice,
        email: email,
      );
      List<String> sectorStrings = List();
      selectedSectors.forEach((sec) {
        sectorStrings.add('resource:com.oneconnect.biz.Sector#${sec.sectorId}');
      });
      p.sectors = sectorStrings;

      List<String> suppStrings = List();
      selectedSuppliers.forEach((sec) {
        suppStrings
            .add('resource:com.oneconnect.biz.Supplier#${sec.participantId}');
      });
      p.suppliers = suppStrings;
      var api = DataAPI(getURL());
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Saving profiile ...',
          textColor: Styles.white,
          backgroundColor: Styles.black);
      var res = await api.addInvestorProfile(p);
      if (res == '0') {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Profile failed',
            listener: this,
            actionLabel: 'CLOSE');
      } else {
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Profile saved',
            textColor: Styles.lightGreen,
            backgroundColor: Styles.black,
            actionLabel: 'OK',
            listener: this,
            icon: Icons.done_all,
            action: 3);
      }
    } else {
      return;
    }
  }

  /*
  String profileId;
  String name;
  String cellphone;
  String email, date;
  double maxInvestableAmount, maxInvoiceAmount;
  String investor;
  List<String> sectors, suppliers;
   */
  List<DropdownMenuItem<Sector>> sectorItems = List();
  List<DropdownMenuItem<Supplier>> supplierItems = List();
  Widget _getSectorDropDown() {
    sectorItems.clear();
    if (sectors == null) return Container();
    sectors.forEach((sector) {
      var item = DropdownMenuItem<Sector>(
        value: sector,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.teal,
              ),
            ),
            Text('${sector.sectorName}'),
          ],
        ),
      );
      sectorItems.add(item);
    });
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: FlatButton(
              onPressed: _showSelectedSectors,
              child: Text(
                selectedSectors == null ? '0' : '${selectedSectors.length}',
                style: Styles.tealBoldLarge,
              ),
            ),
          ),
          DropdownButton<Sector>(
            items: sectorItems,
            hint: Text(
              'Select Sectors',
              style: Styles.blueMedium,
            ),
            onChanged: _onSectorSelected,
          ),
        ],
      ),
    );
  }

  Widget _getSupplierDropDown() {
    supplierItems.clear();
    if (suppliers == null) return Container();
    suppliers.forEach((supplier) {
      var item = DropdownMenuItem<Supplier>(
        value: supplier,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.pink,
              ),
            ),
            Text(
              '${supplier.name}',
              style: Styles.blackBoldSmall,
            ),
          ],
        ),
      );
      supplierItems.add(item);
    });
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, top: 10.0, right: 10.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: FlatButton(
              onPressed: _showSelectedSuppliers,
              child: Text(
                selectedSuppliers == null ? '0' : '${selectedSuppliers.length}',
                style: Styles.pinkBoldLarge,
              ),
            ),
          ),
          DropdownButton<Supplier>(
            items: supplierItems,
            hint: Text(
              'Select Suppliers',
              style: Styles.blueMedium,
            ),
            onChanged: _onSupplierSelected,
          ),
        ],
      ),
    );
  }

  String email;
  double maxInvesttale, maxInvoiice;
  TextEditingController controller1 = TextEditingController(text: '87.08');
  TextEditingController controller2 = TextEditingController(text: '66.99');

  Widget _getForm() {
    if (investor == null) {
      print('_ProfilePageState._getForm %%%% investor is null');
    } else {
      print('_ProfilePageState._getForm: investor is OK');
    }
    return ListView(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
//                TextFormField(
//                  keyboardType: TextInputType.emailAddress,
////                  controller: controller,
//                  decoration: InputDecoration(
//                    labelStyle: Styles.blackMedium,
//                    labelText: 'Email Address',
//                  ),
//                  initialValue: profile == null ? '' : profile.email,
//
//                  validator: (value) {
//                    if (value.isEmpty) {
//                      return 'Please enter your email address';
//                    } else {
//                      email = value;
//                      print('_ProfilePageState._getForm email: $email');
//                    }
//                  },
//                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelStyle: Styles.blackMedium,
                    labelText: 'Max Investable Amount',
                  ),
                  maxLength: 20,
                  controller: controller1,
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelStyle: Styles.blackMedium,
                    labelText: 'Max Invoice Amount',
                  ),
                  maxLength: 16,
                  controller: controller2,
                ),
              ],
            ),
          ),
        ),
        _getSectorDropDown(),
        _getSupplierDropDown(),
        Padding(
          padding: const EdgeInsets.all(28.0),
          child: RaisedButton(
            onPressed: _onSubmit,
            elevation: 8.0,
            color: Styles.pink,
            child: Text(
              'Submit Profile',
              style: Styles.whiteMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: new Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    investor == null ? 'Organisation' : investor.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Supplier> selectedSuppliers = List();
  List<Sector> selectedSectors = List();

  void _onSupplierSelected(Supplier value) {
    print('_ProfilePageState._onSupplierSelected selected: ${value.toJson()}');

    print('Suppliers selected: ${selectedSuppliers.length}');
    setState(() {
      selectedSuppliers.add(value);
    });
  }

  void _onSectorSelected(Sector value) {
    print('_ProfilePageState._onSectorSelected selected: ${value.toJson()}');

    print('Sector selected: ${selectedSectors.length}');
    setState(() {
      selectedSectors.add(value);
    });
  }

  _showSelectedSectors() {
    if (selectedSectors.isEmpty) return;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Tap to Remove Sector",
                style: Styles.greyLabelMedium,
              ),
              content: Container(
                height: 200.0,
                child: ListView.builder(
                    itemCount:
                        selectedSectors == null ? 0 : selectedSectors.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () {
                          _onDeleteSector(selectedSectors.elementAt(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              '${selectedSectors.elementAt(index).sectorName}'),
                        ),
                      );
                    }),
              ),
            ));
  }

  _showSelectedSuppliers() {
    if (selectedSuppliers.isEmpty) return;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Tap to Remove Supplier",
                style: Styles.greyLabelMedium,
              ),
              content: Container(
                height: 200.0,
                child: ListView.builder(
                    itemCount: selectedSuppliers == null
                        ? 0
                        : selectedSuppliers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () {
                          _onDeleteSupplier(selectedSuppliers.elementAt(index));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              '${selectedSuppliers.elementAt(index).name}'),
                        ),
                      );
                    }),
              ),
            ));
  }

  _onDeleteSector(Sector sec) {
    selectedSectors.remove(sec);
    Navigator.pop(context);
    setState(() {});
    print(
        '_ProfilePageState._onDeleteSector - deleted sector: ${sec.toJson()}');
  }

  _onDeleteSupplier(Supplier supplier) {
    selectedSuppliers.remove(supplier);
    Navigator.pop(context);
    setState(() {});
    print(
        '_ProfilePageState._onDeleteSupplier - deleted supplier: ${supplier.toJson()}');
  }
}
