import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/selectors.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:flutter/material.dart';

class SupplierListPage extends StatefulWidget {
  final InvestorProfile profile;

  const SupplierListPage({this.profile});
  @override
  _SupplierListPageState createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Supplier> suppliers, selectedSuppliers = List();
  @override
  void initState() {
    super.initState();
    _getSuppliers();
  }

  void _getSuppliers() async {
    suppliers = await ListAPI.getSuppliers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('BFN Suppliers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Row(),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: suppliers == null ? 0 : suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new GestureDetector(
                        onTap: () {
                          if (suppliers.isNotEmpty) {
                            _onSelected(suppliers.elementAt(index));
                          }
                        },
                        child: new SupplierCard(suppliers.elementAt(index)));
                  }),
            ),
          ],
        ),
      ),
    );
  }

  _showRemoveDialog(Supplier supplier) {
    this.supplier = supplier;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Supplier Removal",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Styles.pink),
              ),
              content: Container(
                height: 60.0,
                child: Text(
                    'Do you want to remove ${supplier.name} from your supplier list?'),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onRemoveSupplier,
                  child: Text(
                    'REMOVE',
                    style: Styles.pinkBoldMedium,
                  ),
                ),
              ],
            ));
  }

  Supplier supplier;
  _showAddDialog(Supplier supplier) {
    this.supplier = supplier;
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Supplier Addition",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 60.0,
                child: Text(
                    'Do you want to add ${supplier.name} to your supplier list?'),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _onNoPressed,
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: _onAddSupplier,
                  child: Text('ADD SUPPLIER'),
                ),
              ],
            ));
  }

  _onSelected(Supplier supplier) {
    print('_SupplierListPageState._onSelected selectted ${supplier.name}');
    bool isFound = false;
    selectedSuppliers.forEach((supp) {
      if (supplier.participantId == supp.participantId) {
        isFound = true;
        ;
      }
    });
    if (isFound) {
      _showRemoveDialog(supplier);
    } else {
      _showAddDialog(supplier);
    }
  }

  void _onNoPressed() {
    Navigator.pop(context);
  }

  _onRemoveSupplier() {
    Navigator.pop(context);
    selectedSuppliers.remove(supplier);
    print(
        '_SupplierListPageState._onRemoveSupplier removed: ${supplier.name} selectedSuppliers: ${selectedSuppliers.length}');
    //setState(() {});
  }

  _onAddSupplier() {
    Navigator.pop(context);
    selectedSuppliers.add(supplier);
    print(
        '_SupplierListPageState._onAddSupplier added supplier: ${supplier.name} selectedSuppliers: ${selectedSuppliers.length}');
    //setState(() {});
  }

  void _test() {
    print('_SupplierListPageState._test,,,,,,,,,,,,,,,,,,,,,');
  }
}
