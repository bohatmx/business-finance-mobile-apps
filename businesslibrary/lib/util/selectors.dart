import 'dart:math';

import 'package:businesslibrary/api/list_api.dart';
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
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  privateSectorType.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///////////////

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
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  country.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
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
    suppliers = await ListAPI.getSuppliers();
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
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                  itemCount: suppliers == null ? 0 : suppliers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new InkWell(
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
    );
  }
}

class SupplierCard extends StatelessWidget {
  final Supplier supplier;

  SupplierCard(this.supplier);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                color: getRandomColor(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  supplier.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<Color> _colors = List();
Random _rand = Random(new DateTime.now().millisecondsSinceEpoch);
Color getRandomColor() {
  print('getRandomColor ..........');
  _colors.clear();
  _colors.add(Colors.blue);
  _colors.add(Colors.grey);
  _colors.add(Colors.black);
  _colors.add(Colors.pink);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.amber);
  _colors.add(Colors.indigo);
  _colors.add(Colors.lightBlue);
  _colors.add(Colors.lime);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.brown);
  _colors.add(Colors.cyan);

  _rand = Random(new DateTime.now().millisecondsSinceEpoch);
  int index = _rand.nextInt(_colors.length - 1);
  return _colors.elementAt(index);
}
