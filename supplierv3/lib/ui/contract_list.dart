import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:flutter/material.dart';
import 'package:supplierv3/ui/contract_page.dart';

class ContractList extends StatefulWidget {
  @override
  _ContractListState createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<SupplierContract> contracts;
  Supplier supplier;
  User user;
  @override
  void initState() {
    super.initState();

    _getCachedPrefs();
  }

  _getCachedPrefs() async {
    user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();

    contracts = await ListAPI.getSupplierContracts(supplier.documentReference);
    if (contracts == null || contracts.isEmpty) {
      _showNoContractsDialog();
    } else {
      double total = 0.00;
      contracts.forEach((ct) {
        double val = double.parse(ct.estimatedValue);
        total += val;
      });
      totalValue = getFormattedAmount('$total', context);
    }
    setState(() {});
  }

  _showNoContractsDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Contract Documents",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 120.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                      child: Text(
                        'Contract Documents',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "There are no contracts uploaded to the Business Finance Network?",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  String totalValue;
  TextStyle getWhiteText() {
    return TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    );
  }

  TextStyle getBoldWhiteText() {
    return TextStyle(
        color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w900);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supplier  Contracts'),
        bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    supplier == null ? '' : supplier.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Total Value:',
                          style: getWhiteText(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            totalValue == null ? '0.00' : totalValue,
                            style: getBoldWhiteText(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(100.0)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddNewContract,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getCachedPrefs,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: contracts == null ? 0 : contracts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () {
                          _confirm(contracts.elementAt(index));
                        },
                        child: SupplierContractCard(
                          supplierContract: contracts.elementAt(index),
                          context: context,
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddNewContract() async {
    var res = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ContractPage(null)),
    );
    if (res != null && res) {
      _getCachedPrefs();
    }
  }

  void _confirm(SupplierContract contract) {
    prettyPrint(contract.toJson(), '_ContractListState._confirm:');
  }
}

class SupplierContractCard extends StatelessWidget {
  final SupplierContract supplierContract;
  final BuildContext context;

  SupplierContractCard({this.supplierContract, this.context});

  @override
  Widget build(BuildContext context) {
    amount = _getFormattedAmt();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 3.0,
        color: Colors.indigo.shade50,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.event),
                ),
                Text(
                  getFormattedLongestDate(supplierContract.date),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      supplierContract.customerName,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, bottom: 10.0, top: 20.0),
              child: Row(
                children: <Widget>[
                  Text('Value'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      amount == null ? '0.00' : amount,
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, bottom: 20.0),
              child: Row(
                children: <Widget>[
                  Text('Expiry Date'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      supplierContract == null
                          ? 'No Date'
                          : getFormattedDate(supplierContract.endDate),
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String amount;
  String _getFormattedAmt() {
    amount = getFormattedAmount(supplierContract.estimatedValue, context);
    print('SupplierContractCard._getFormattedAmt $amount');
    return amount;
  }
}
