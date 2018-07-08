import 'package:crudderv3/generator.dart';
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
  @override
  initState() {
    super.initState();
  }

  void _generateBids() async {
    await Generator.generateBids();
    setState(() {
      _counter++;
    });
  }

  void _generate() async {
    await Generator.cleanUp();
    setState(() {
      _counter++;
    });
    await Generator.generateEntities();
    setState(() {
      _counter++;
    });
    await Generator.generateSuppliers();
    setState(() {
      _counter++;
    });

    await Generator.generateInvestors();
    setState(() {
      _counter++;
    });
    await Generator.generateProcurementOffice();
    setState(() {
      _counter++;
    });
    await Generator.generateBank();
    setState(() {
      _counter++;
    });
    await Generator.generateAuditor();
    setState(() {
      _counter++;
    });
    await Generator.generateCompanies();
    setState(() {
      _counter++;
    });
    await Generator.generateOneConnect();
    setState(() {
      _counter++;
    });

    await Generator.generatePurchaseOrders();
    setState(() {
      _counter++;
      opacity = 1.0;
    });
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
      body: new Center(
        child: Container(
          color: Colors.blueGrey.shade50,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                elevation: 4.0,
                child: new Padding(
                  padding: const EdgeInsets.only(
                      top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Phase Complete',
                        style: TextStyle(
                            fontSize: 28.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$_counter',
                        style: TextStyle(
                            fontSize: 60.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.teal),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Container(
                          width: 200.0,
                          child: Opacity(
                            opacity: opacity == null ? 0.0 : 1.0,
                            child: RaisedButton(
                              elevation: 8.0,
                              onPressed: _generateBids,
                              color: Colors.pink.shade200,
                              child: new Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Generate Bids',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.blueGrey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Count should get to 10. Then wait a bit ...',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.indigo.shade50,
      floatingActionButton: new FloatingActionButton(
        onPressed: _generate,
        tooltip: 'Generate Data',
        child: Text(
          'Start',
          style: TextStyle(fontSize: 14.0, color: Colors.white),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
