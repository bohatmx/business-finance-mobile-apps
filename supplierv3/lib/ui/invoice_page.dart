import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/snackbar_util.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:flutter/material.dart';

class NewInvoicePage extends StatefulWidget {
  final DeliveryAcceptance deliveryAcceptance;

  NewInvoicePage(this.deliveryAcceptance);

  @override
  _NewInvoicePageState createState() => _NewInvoicePageState();
}

///
class _NewInvoicePageState extends State<NewInvoicePage>
    implements SnackBarListener {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  DeliveryAcceptance deliveryAcceptance;
  List<DeliveryAcceptance> deliveryAcceptances;
  User _user;
  String invoiceNumber;
  Invoice invoice;
  Supplier supplier;
  double tax, totalAmount, amount;
  List<SupplierContract> contracts;
  List<DropdownMenuItem<String>> items = List();

  @override
  void initState() {
    super.initState();
    _getCachedPrefs();
    _getDeliveryAcceptances();
  }

  _getDeliveryAcceptances() async {
    deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        supplier.documentReference, 'suppliers');
    print(
        '_NewInvoicePageState._getDeliveryAcceptances deliveryAcceptances: ${deliveryAcceptances.length}');
  }

  _getCachedPrefs() async {
    _user = await SharedPrefs.getUser();
    supplier = await SharedPrefs.getSupplier();
    _getContracts();
  }

  static const NameSpace = 'resource:com.oneconnect.biz.';
  void _onSubmit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      totalAmount = amount + tax;
      invoice = Invoice(
        invoiceNumber: invoiceNumber,
        user: NameSpace + 'User#' + _user.userId,
        govtEntity: deliveryAcceptance.govtEntity,
        company: deliveryAcceptance.company,
        supplier: deliveryAcceptance.supplier,
        govtDocumentRef: deliveryAcceptance.govtDocumentRef,
        companyDocumentRef: deliveryAcceptance.companyDocumentRef,
        supplierDocumentRef: deliveryAcceptance.supplierDocumentRef,
        purchaseOrder: deliveryAcceptance.purchaseOrder,
        deliveryNote: deliveryAcceptance.deliveryNote,
        supplierName: supplier.name,
        customerName: deliveryAcceptance.customerName,
        purchaseOrderNumber: deliveryAcceptance.purchaseOrderNumber,
        amount: amount,
        valueAddedTax: tax,
        totalAmount: totalAmount,
        isOnOffer: false,
        isSettled: false,
        date: new DateTime.now().toIso8601String(),
      );

      if (contract != null) {
        invoice.supplierContract =
            NameSpace + 'SupplierContract#${contract.contractId}';
        invoice.contractURL = contract.contractURL;
      }
      AppSnackbar.showSnackbarWithProgressIndicator(
          scaffoldKey: _scaffoldKey,
          message: 'Submitting Invoice ...',
          textColor: Colors.white,
          backgroundColor: Colors.black);

      //check for possible duplicate
      var xx = await ListAPI.getInvoice(invoice.purchaseOrderNumber,
          invoice.invoiceNumber, invoice.supplierDocumentRef);
      if (xx != null) {
        print('DataAPI.registerInvoice - possible DUPLICATE invoice');
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Error. Possible duplicate invoice',
            listener: this,
            actionLabel: 'Check');
        return;
      }

      DataAPI api = DataAPI(getURL());
      var result = await api.registerInvoice(invoice);
      if (result == '0') {
        isSuccess = false;
        AppSnackbar.showErrorSnackbar(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice submission failed',
            listener: this,
            actionLabel: "ERROR ");
      } else {
        isSuccess = true;
        AppSnackbar.showSnackbarWithAction(
            scaffoldKey: _scaffoldKey,
            message: 'Invoice submitted OK',
            textColor: Colors.white,
            icon: Icons.done,
            listener: this,
            actionLabel: 'DONE',
            action: 0,
            backgroundColor: Colors.black);
      }
    }
  }

  _getContracts() async {
    print('_NewInvoicePageState._getContracts ..........');
    prettyPrint(deliveryAcceptance.toJson(), 'deliveryAcceptance:');
    if (deliveryAcceptance.govtEntity != null) {
      contracts = await ListAPI.getSupplierGovtContracts(
          supplier.documentReference, deliveryAcceptance.govtEntity);
    } else {
      contracts = await ListAPI.getSupplierCompanyContracts(
          supplier.documentReference, deliveryAcceptance.company);
    }
    if (contracts.isNotEmpty) {
      _buildContractsDropDown();
    } else {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _scaffoldKey,
          message: 'No contracts  on file',
          listener: this,
          actionLabel: 'Upload?');
    }
  }

  _buildContractsDropDown() {
    contracts.forEach((c) {
      var item6 = DropdownMenuItem<String>(
        value: c.contractURL,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.apps,
                color: Colors.blue,
              ),
            ),
            Text('${c.customerName} - ${c.estimatedValue}'),
          ],
        ),
      );
      items.add(item6);
    });
  }

  bool isSuccess = false;
  String contractURL;
  @override
  Widget build(BuildContext context) {
    deliveryAcceptance = widget.deliveryAcceptance;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Create Invoice',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  deliveryAcceptance == null
                      ? 'Customer Name Here'
                      : deliveryAcceptance.customerName,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new Card(
            elevation: 6.0,
            child: new Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: ListView(
                children: <Widget>[
                  DropdownButton<String>(
                    items: items,
                    onChanged: _onContractTapped,
                    elevation: 16,
                    hint: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Supplier Contract',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      contract == null
                          ? ''
                          : '${contract.customerName} - ${contract.estimatedValue}',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextFormField(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Invoice Number',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the Invoice Number';
                        }
                      },
                      onSaved: (val) => invoiceNumber = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 28,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the invoice amount';
                        }
                      },
                      onSaved: (val) => amount = double.parse(val),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple),
                      decoration: InputDecoration(
                        labelText: 'Value Added Tax',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the VAT amount';
                        }
                      },
                      onSaved: (val) => tax = double.parse(val),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                        left: 28.0, right: 20.0, top: 10.0),
                    child: RaisedButton(
                      elevation: 8.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: _onSubmit,
                      child: new Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Submit Invoice',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 4.0,
                      left: 12.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('PO Number:')),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Text(
                            deliveryAcceptance == null
                                ? ''
                                : deliveryAcceptance.purchaseOrderNumber,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('Customer:')),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            deliveryAcceptance == null
                                ? ''
                                : deliveryAcceptance.customerName,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, top: 4.0),
                    child: Row(
                      children: <Widget>[
                        Container(width: 70.0, child: Text('Supplier:')),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            supplier == null ? '' : supplier.name,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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

  @override
  onActionPressed(int action) {
    print('_NewInvoicePageState.onActionPressed');
    if (isSuccess) {
      Navigator.pop(context);
    }
  }

  void _getContract() {
    print('_NewInvoicePageState._getContract ...');
  }

  SupplierContract contract;
  void _onContractTapped(String value) {
    contracts.forEach((c) {
      if (value == c.contractURL) {
        contract = c;
        setState(() {});
        return;
      }
    });
  }
}

class InvoiceDetailsPage extends StatelessWidget {
  final Invoice invoice;

  InvoiceDetailsPage(this.invoice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        bottom: PreferredSize(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: .0),
                  child: Text(
                    invoice.customerName,
                    style: getTitleTextWhite(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 48.0, top: 10.0, bottom: 20.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Invoice Number',
                        style: getTextWhiteSmall(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          invoice.invoiceNumber,
                          style: getTextWhiteMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            preferredSize: Size.fromHeight(60.0)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: <Widget>[
              Text('More coming ....'),
            ],
          ),
        ),
      ),
    );
  }
}
