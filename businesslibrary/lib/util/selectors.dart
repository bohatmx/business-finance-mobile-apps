import 'package:businesslibrary/api/firestore_list_api.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:flutter/material.dart';

class SectorSelectorPage extends StatefulWidget {
  @override
  _SectorSelectorPageState createState() => _SectorSelectorPageState();
}

class _SectorSelectorPageState extends State<SectorSelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<PrivateSectorType> types;
  @override
  initState() {
    super.initState();
    _getTypes();
  }

  _getTypes() async {
    types = await Lookups.getTypes();
    if (types.isEmpty) {
      await Lookups.storePrivateSectorTypes();
      types = await Lookups.getTypes();
    }

    print('SectorSelectorPage._getTypes types found: ${types.length}');
    setState(() {});
  }

  String sectorType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sector Types'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: types == null ? 0 : types.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var xType = types.elementAt(index);
                            print(
                                'SectorSelectorPage.build about to pop ${xType.type}');
                            Navigator.pop(context, xType);
                          },
                          child: new SectorCard(types.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectorCard extends StatelessWidget {
  final PrivateSectorType privateSectorType;

  SectorCard(this.privateSectorType);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        height: 40.0,
        child: Card(
          elevation: 1.0,
          child: ListTile(
            leading: Icon(Icons.apps),
            title: Text(
              privateSectorType.type,
            ),
          ),
        ),
      ),
    );
  }
}

class CountrySelectorPage extends StatefulWidget {
  @override
  _CountrySelectorPageState createState() => _CountrySelectorPageState();
}

class _CountrySelectorPageState extends State<CountrySelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Country> countries;
  @override
  initState() {
    super.initState();
    _getCountries();
  }

  _getCountries() async {
    countries = await Lookups.getCountries();
    if (countries.isEmpty) {
      await Lookups.storeCountries();
      countries = await Lookups.getCountries();
    }
    print(
        'CountrySelectorPage._getTypes types found:countries ${countries.length}');
    setState(() {});
  }

  String countryName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Countries'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: countries == null ? 0 : countries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var xType = countries.elementAt(index);
                            print(
                                'CountrySelectorPage.build about to pop ${xType.name}');
                            Navigator.pop(context, xType);
                          },
                          child: new CountryCard(countries.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountryCard extends StatelessWidget {
  final Country country;

  CountryCard(this.country);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        height: 40.0,
        child: Card(
          elevation: 1.0,
          child: ListTile(
            leading: Icon(Icons.location_on),
            title: Text(
              country.name,
            ),
          ),
        ),
      ),
    );
  }
}

///////
class SupplierSelectorPage extends StatefulWidget {
  @override
  _SupplierSelectorPageState createState() => _SupplierSelectorPageState();
}

class _SupplierSelectorPageState extends State<SupplierSelectorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<Supplier> suppliers;
  @override
  initState() {
    super.initState();
    _getSuppliers();
  }

  _getSuppliers() async {
    suppliers = await FirestoreListAPI.getSuppliers();
    print(
        'SupplierSelectorPage._getTypes types found:suppliers ${suppliers.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Supplier List'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Card(
          elevation: 4.0,
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new ListView.builder(
                    itemCount: suppliers == null ? 0 : suppliers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                          onTap: () {
                            var supp = suppliers.elementAt(index);
                            print(
                                'SupplierSelectorPage.build about to pop ${supp.name}');
                            Navigator.pop(context, supp);
                          },
                          child: new SupplierCard(suppliers.elementAt(index)));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplierCard extends StatelessWidget {
  final Supplier supplier;

  SupplierCard(this.supplier);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Container(
        height: 40.0,
        child: Card(
          elevation: 1.0,
          child: ListTile(
            leading: Icon(Icons.apps),
            title: Text(
              supplier.name,
            ),
          ),
        ),
      ),
    );
  }
}
