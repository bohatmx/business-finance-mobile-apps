import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';
import 'package:investor/ui/sector_list_page.dart';
import 'package:investor/ui/supplier_list_page.dart';

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
    _getCachedData();
  }

  int numberOfSuppliers = 0, numberOfSectors = 0;
  void _getCachedData() async {
    print('_ProfilePageState._getCachedData ................................');
    investor = await SharedPrefs.getInvestor();

    profile = await SharedPrefs.getInvestorProfile();
    if (profile == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Profile does not exist',
          listener: this,
          actionLabel: 'close');
    } else {
      controllerMaxInvestable.text = '${profile.maxInvestableAmount}';
      controllerMaxInvoice.text = '${profile.maxInvoiceAmount}';
      maxInvestableAmount = profile.maxInvestableAmount;
      maxInvoiceAmount = profile.maxInvoiceAmount;
      if (profile.suppliers != null) {
        numberOfSuppliers = profile.suppliers.length;
      }
      if (profile.sectors != null) {
        numberOfSectors = profile.sectors.length;
      }

      setState(() {});
      AppSnackbar.showSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Profile found',
          textColor: Styles.lightGreen,
          backgroundColor: Styles.black);
    }
  }

  @override
  onActionPressed(int action) {
    switch (action) {
      case 3:
        _showAutoTradeDialog();
        break;
      case 4:
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  _showAutoTradeDialog() async {
    var order = await SharedPrefs.getAutoTradeOrder();
    if (order != null) {
      Navigator.pop(context);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Auto Trade Confirmation",
                style: Styles.greyLabelMedium,
              ),
              content: Container(
                height: 200.0,
                child: Text(
                    'Do you  want to set up an Auto Trade Order?  The network will make automatic invoice offers on your behalf if you want to.'),
              ),
              actions: <Widget>[
                FlatButton(onPressed: _onNoAutoTrade, child: Text('NO')),
                FlatButton(onPressed: _onAutoTrade, child: Text('YES')),
              ],
            ));
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
    print('_ProfilePageState._onSubmit ........................');
    if (controllerMaxInvestable.text.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter maximum investible amount',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (controllerMaxInvoice.text.isEmpty) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter maximum invoice amount ',
          listener: this,
          actionLabel: 'OK');
      return;
    }
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
      );
    }
    try {
      profile.maxInvestableAmount = double.parse(controllerMaxInvestable.text);
      profile.maxInvoiceAmount = double.parse(controllerMaxInvoice.text);
    } catch (e) {
      print('_ProfilePageState._onSubmit $e');
    }
    List<String> sectorStrings = List();

    if (selectedSectors != null) {
      selectedSectors.forEach((sec) {
        sectorStrings.add('resource:com.oneconnect.biz.Sector#${sec.sectorId}');
      });
      profile.sectors = sectorStrings;
    }

    List<String> suppStrings = List();
    if (selectedSuppliers != null) {
      selectedSuppliers.forEach((sec) {
        suppStrings
            .add('resource:com.oneconnect.biz.Supplier#${sec.participantId}');
      });
      profile.suppliers = suppStrings;
    }

    var api = DataAPI(getURL());
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Saving profile ...',
        textColor: Styles.white,
        backgroundColor: Styles.black);
    var res;
    if (profile.profileId == null) {
      res = await api.addInvestorProfile(profile);
    } else {
      res = await api.updateInvestorProfile(profile);
    }
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
  }

  List<DropdownMenuItem<Sector>> sectorItems = List();
  List<DropdownMenuItem<Supplier>> supplierItems = List();

  String email;
  double maxInvestableAmount, maxInvoiceAmount;
  TextEditingController controllerMaxInvestable =
      TextEditingController(text: '87.08');
  TextEditingController controllerMaxInvoice =
      TextEditingController(text: '66.99');

  Widget _getForm() {
    if (investor == null) {
      print('_ProfilePageState._getForm %%%% investor is null');
    } else {
      print('_ProfilePageState._getForm: investor is OK');
    }
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelStyle: Styles.blackMedium,
                  labelText: 'Max Investable Amount',
                ),
                maxLength: 20,
                controller: controllerMaxInvestable,
                style: Styles.blackBoldLarge,
                onChanged: _onInvestableAmountChanged,
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelStyle: Styles.blackMedium,
                  labelText: 'Max Single Offer Amount',
                ),
                maxLength: 16,
                controller: controllerMaxInvoice,
                style: Styles.pinkBoldMedium,
                onChanged: _onInvoiceAmountChanged,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            'Investment Filters',
            style: Styles.greyLabelMedium,
          ),
        ),
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: _goToSectorList,
              child: Text(
                'Select Sectors',
                style: Styles.blueMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                selectedSectors == null
                    ? '$numberOfSectors'
                    : '${selectedSectors.length}',
                style: Styles.tealBoldReallyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(' selected'),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: _goToSuppliersList,
              child: Text(
                'Select Suppliers',
                style: Styles.blueMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                selectedSuppliers == null
                    ? '$numberOfSuppliers'
                    : '${selectedSuppliers.length}',
                style: Styles.pinkBoldReallyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Text(' selected'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(28.0),
          child: RaisedButton(
            onPressed: _onSubmit,
            elevation: 16.0,
            color: profile.profileId == null ? Styles.pink : Styles.purple,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                profile.profileId == null ? 'Submit Profile' : 'Update Profile',
                style: Styles.whiteMedium,
              ),
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

  List<Supplier> selectedSuppliers;
  List<Sector> selectedSectors;

  void _goToSectorList() async {
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
        date: DateTime.now().toIso8601String(),
        maxInvestableAmount: maxInvestableAmount,
        maxInvoiceAmount: maxInvoiceAmount,
        email: email,
      );
      profile.suppliers = List<String>();
      profile.sectors = List<String>();
    }

    selectedSectors = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new SectorListPage(
              profile: profile,
            ),
      ),
    );
    setState(() {});
    print(
        '_ProfilePageState._onSectors BACK froom SectorListPage selectedSectors: ${selectedSectors.length}');
  }

  void _goToSuppliersList() async {
    if (profile == null) {
      profile = InvestorProfile(
        name: investor.name,
        investor:
            'resource:com.oneconnect.biz.Investor#${investor.participantId}',
        date: DateTime.now().toIso8601String(),
        maxInvestableAmount: maxInvestableAmount,
        maxInvoiceAmount: maxInvoiceAmount,
        email: email,
      );
      profile.suppliers = List<String>();
      profile.sectors = List<String>();
    }

    selectedSuppliers = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new SupplierListPage(
              profile: profile,
            ),
      ),
    );
    setState(() {});
    print(
        '_ProfilePageState._onSuppliers BACK froom SupplierListPage selectedSuppliers: ${selectedSuppliers.length}');
  }

  void _onInvestableAmountChanged(String value) {
    maxInvestableAmount = double.parse(value);
    print(
        '_ProfilePageState._onInvestableAmountChanged maxInvestableAmount: $maxInvestableAmount');
  }

  void _onInvoiceAmountChanged(String value) {
    maxInvoiceAmount = double.parse(value);
    print(
        '_ProfilePageState._onInvoiceAmountChanged maxInvoiceAmount:  $maxInvoiceAmount');
  }

  void _onNoAutoTrade() {
    Navigator.pop(context);
  }

  void _onAutoTrade() async {
    Navigator.pop(context);
    var user = await SharedPrefs.getUser();
    var order = AutoTradeOrder(
      date: DateTime.now().toIso8601String(),
      investorName: investor.name,
      investorProfile:
          'resource:com.oneconnect.biz.InvestorProfile#${profile.profileId}',
      investor:
          'resource:com.oneconnect.biz.Investor#${investor.participantId}',
      user: 'resource:com.oneconnect.biz.User#${user.userId}',
    );
    var api = DataAPI(getURL());
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Saving Auto Trade Order',
        textColor: Styles.yellow,
        backgroundColor: Styles.black);
    var res = await api.addAutoTradeOrder(order);
    if (res == '0') {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Failed to add Auto Trade Order',
          listener: this,
          actionLabel: 'CLOSE');
    } else {
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Auto Trade Order saved',
          textColor: Styles.yellow,
          backgroundColor: Styles.black,
          listener: this,
          icon: Icons.done_all,
          action: 4);
    }
  }
}
