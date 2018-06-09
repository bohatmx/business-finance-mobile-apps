import 'package:crudder/crud.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: new MyHomePage(title: 'Finance Blockchain Demo'),
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
  String _key;

  void _addGovtEntity() async {
    var list = await CrudDriver.getGovtEntities();
    print(
        '_MyHomePageState._incrementCounter - list from package: ${list.length}');

    // await CrudDriver.addGovtEntity();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              _key == null
                  ? 'Push the button to get a key:'
                  : 'Latest key generated',
            ),
            new Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 20.0, top: 40.0),
              child: new Text(
                _key == null ? '' : '$_key',
                style:
                    new TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addGovtEntity,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
