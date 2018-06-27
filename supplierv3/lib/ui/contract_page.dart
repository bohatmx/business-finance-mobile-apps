import 'dart:convert';
import 'dart:math';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supplierv3/storage_api.dart';

class ContractPage extends StatefulWidget {
  final SupplierContract contract;

  ContractPage(this.contract);

  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage>
    implements SnackBarListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel('com.oneconnect.files/pdf');
  SupplierContract contract;
  List<SupplierContract> contracts;
  List<GovtEntity> entities;
  Supplier supplier;
  User user;
  String title;
  GovtEntity entity;
  List<DropdownMenuItem<String>> items = List();
  List<DropdownMenuItem<String>> fileItems = List();
  DateTime startTime, endTime;
  List paths;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  String path, url;

  var fileName;
  @override
  void initState() {
    super.initState();
    _getCached();
    _getFiles();
  }

  _getCached() async {
    supplier = await SharedPrefs.getSupplier();
    user = await SharedPrefs.getUser();

    _getEntities();
  }

  _getEntities() async {
    entities = await ListAPI.getGovtEntitiesByCountry(supplier.country);
    if (entities.length < 70) {
      _buildDropDownItems();
    }
  }

  void _getFiles() async {
    print('_ContractPageState._getFiles **********************************');
    try {
      final String result = await platform.invokeMethod('getBatteryLevel');
      Map map = json.decode(result);
      paths = map['paths'];
      if (paths.isNotEmpty) {
        _buildFileItems();
      } else {
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: "No contract PDF files found",
            listener: this,
            actionLabel: 'Close');
        setState(() {
          opacity = 0.0;
        });
        _showNoFilesDialog();
      }

      print('_ContractPageState._getFiles PDF FILES: $result');
    } on PlatformException catch (e) {
      print('_DashboardState._getFiles $e');
    }
  }

  bool isBusy = false;
  _showNoFilesDialog() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Contract Files",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              content: Container(
                height: 80.0,
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
                      "No contract PDF files found on device. Press Close to exit",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
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

  _uploadFile() async {
    if (isBusy) {
      return;
    }
    isBusy = true;
    print('_ContractPageState._uploadFile  - $path');
    Navigator.pop(context);
    AppSnackbar.showSnackbarWithProgressIndicator(
        scaffoldKey: _scaffoldKey,
        message: 'Uploading document. Please wait',
        textColor: Colors.white,
        backgroundColor: Colors.black);

    url = await StorageAPI.uploadFile('contracts', path);
    print('_ContractPageState._uploadFile url: $url');
    if (url == '0') {
      isBusy = false;
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Contract upload failed',
          listener: this,
          actionLabel: 'Close');
    } else {
      _uploadContract();
    }
  }

  void _uploadContract() async {
    print('_ContractPageState._uploadContract ############### '
        '.........  url: $url');
    SupplierContract c = SupplierContract(
      estimatedValue: contractValue,
      startDate: startTime.toIso8601String(),
      endDate: endTime.toIso8601String(),
      customerName: entity.name,
      supplierName: supplier.name,
      supplierDocumentRef: supplier.documentReference,
      govtEntity:
          'resource:com.oneconnect.biz.GovtEntity#' + entity.participantId,
      contractURL: url,
      user: 'resource:com.oneconnect.biz.User#' + user.userId,
      date: new DateTime.now().toIso8601String(),
      supplier:
          'resource:com.oneconnect.biz.Supplier#' + supplier.participantId,
    );

    DataAPI api = DataAPI(getURL());
    var res = await api.addSupplierContract(c);
    isBusy = false;
    if (res == '0') {
      isDone = false;
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Contract upload failed',
          listener: this,
          actionLabel: 'Close');
    } else {
      isDone = true;
      AppSnackbar.showSnackbarWithAction(
          scaffoldKey: _scaffoldKey,
          message: 'Contract uploaded',
          textColor: Colors.white,
          backgroundColor: Colors.black,
          actionLabel: 'Done',
          listener: this,
          icon: Icons.done);
      setState(() {
        fileName = null;
        entity = null;
        contractValue = null;
        startTime = null;
        endTime = null;
      });
    }
  }

  Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  bool isDone;
  _buildFileItems() {
    paths.forEach((path) {
      var item = DropdownMenuItem<String>(
        value: path,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: _getRandomColor(),
              ),
            ),
            Text(_getName(path)),
          ],
        ),
      );
      fileItems.add(item);
    });
  }

  String _getName(String path) {
    int index = path.lastIndexOf('/');
    String name = path.substring(index + 1);
    return name;
  }

  List<Color> colors = List();
  double opacity = 1.0;

  Color _getRandomColor() {
    rand = new Random(new DateTime.now().millisecondsSinceEpoch);
    colors.add(Colors.teal);
    colors.add(Colors.black);
    colors.add(Colors.grey);
    colors.add(Colors.pink);
    colors.add(Colors.blue);
    colors.add(Colors.purple);
    colors.add(Colors.deepOrange);
    colors.add(Colors.indigo);
    colors.add(Colors.green);

    var index = rand.nextInt(colors.length - 1);
    return colors.elementAt(index);
  }

  _buildDropDownItems() {
    entities.forEach((e) {
      var item = DropdownMenuItem(
        value: e.name,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.pink,
              ),
            ),
            Text('${e.name}'),
          ],
        ),
      );
      items.add(item);
    });
  }

  _getStartTime() async {
    startTime = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );

    setState(() {});
  }

  var style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  _getEndTime() async {
    endTime = await showDatePicker(
      context: context,
      firstDate: new DateTime.now(),
      lastDate: new DateTime.now().add(Duration(days: 365 * 5)),
      initialDate: DateTime.now().add(Duration(seconds: 10)),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setTitle();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title == null ? '' : title),
        elevation: 16.0,
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    supplier == null ? '' : supplier.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(30.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: DropdownButton<String>(
                      items: items,
                      onChanged: _onEntityTapped,
                      elevation: 16,
                      hint: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Text(
                          'Government Entity',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text(
                      entity == null ? '' : entity.name,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 120.0,
                          child: RaisedButton(
                            elevation: 4.0,
                            onPressed: _getStartTime,
                            child: Text(
                              'Start Date',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            startTime == null
                                ? ''
                                : getFormattedDate(startTime.toIso8601String()),
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        child: RaisedButton(
                          elevation: 4.0,
                          onPressed: _getEndTime,
                          child: Text(
                            'End Date',
                            style: TextStyle(
                              color: Colors.pink,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          endTime == null
                              ? ''
                              : getFormattedDate(endTime.toIso8601String()),
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: TextField(
                      style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 28.0),
                      decoration: InputDecoration(
                        labelText: 'Contract Value',
                        hintText: 'Enter Contract Value',
//                      errorText: 'Please enter contract  value',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      onChanged: _contractValueChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Container(
                      width: 400.0,
                      child: DropdownButton<String>(
                        items: fileItems,
                        onChanged: _onFileTapped,
                        elevation: 16,
                        hint: Text(
                          'Contract PDF',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 30.0),
                    child: Text(
                      fileName == null ? 'File not selected yet' : fileName,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Opacity(
                    opacity: opacity,
                    child: RaisedButton(
                      elevation: 8.0,
                      onPressed: _confirm,
                      color: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Upload Contract',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setTitle() {
    contract = widget.contract;
    if (widget.contract == null) {
      title = 'Upload New Contract';
    } else {
      title = 'Edit Existing Contract';
    }
  }

  void _onEntityTapped(String value) {
    entities.forEach((e) {
      if (e.name == value) {
        entity = e;
        setState(() {});
        return;
      }
    });
  }

  String contractValue;
  void _contractValueChanged(String value) {
    contractValue = value;
    print(
        '_ContractPageState._contractValueChanged contractValue: $contractValue');
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    try {
      double.parse(s);
      return true;
    } on FormatException {
      return false;
    }
  }

  void _confirm() {
    print('_ContractPageState.confirm');

    if (endTime.isBefore(startTime)) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'The dates are not correct',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (fileName == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select a file first',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (contractValue == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please enter contract value',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (entity == null) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Please select government entity',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    if (!isNumeric(contractValue)) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'Amount entered is incorrect',
          listener: this,
          actionLabel: 'Close');
      return;
    }
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(
                "Contract Uploading",
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
                        'Contract Document',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Do you want  to uupload this contract document to the Business Finance Network?",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: _uploadFile,
                  child: Text(
                    'YES',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 16.0),
                  child: FlatButton(
                    onPressed: _onCancel,
                    child: Text(
                      'NO',
                      style: TextStyle(color: Colors.pink, fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ));
  }

  void _onFileTapped(String value) {
    print('_ContractPageState._onFileTapped file : $value');
    path = value;
    var index = path.lastIndexOf("/");
    if (index > -1) {
      setState(() {
        fileName = path.substring(index + 1);
      });
    }
  }

  void _onCancel() {
    print('_ContractPageState._onCancel');
  }

  @override
  onActionPressed(int action) {
    print('_ContractPageState.onActionPressed ............');
    if (isDone) {
      Navigator.pop(context);
    }
  }
}
