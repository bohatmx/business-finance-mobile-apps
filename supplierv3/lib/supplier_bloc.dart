import 'dart:async';

import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/invoice_settlement.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/Finders.dart';
import 'package:businesslibrary/util/database.dart';

class SupplierModelBloc implements SupplierBlocListener {
  final StreamController<SupplierApplicationModel> _appModelController =
      StreamController<SupplierApplicationModel>();
  final StreamController<String> _errorController = StreamController<String>();
  final SupplierApplicationModel _appModel = SupplierApplicationModel();

  SupplierModelBloc() {
    print(
        '\n\nSupplierModelBloc - CONSTRUCTOR - set listener and initialize app model');
    _appModel.setListener(this);
    _appModel.initialize();
  }

  get appModel => _appModel;

  refreshModel() async {
    try {
      await _appModel.refreshModel();
      _appModelController.sink.add(_appModel);
    } catch (e) {
      print('SupplierModelBloc.refreshModel - ${e.message}');
    }
  }

  closeStream() {
    _appModelController.close();
    _errorController.close();
  }

  get appModelStream => _appModelController.stream;

  @override
  onComplete() {
    print(
        '\n\nSupplierModelBloc.onComplete ########## adding model to stream sink ......... ');
    _appModelController.sink.add(_appModel);
  }

  @override
  onError(String message) {
    _errorController.sink.add(message);
  }
}

final supplierModelBloc = SupplierModelBloc();

abstract class SupplierBlocListener {
  onComplete();
  onError(String message);
}

class SupplierApplicationModel {
  List<DeliveryNote> _deliveryNotes = List();
  List<PurchaseOrder> _purchaseOrders = List();
  List<Invoice> _invoices = List();
  List<DeliveryAcceptance> _deliveryAcceptances = List();
  List<Offer> _offers = List();
  List<InvoiceBid> _unsettledInvoiceBids = List();
  List<InvoiceBid> _settledInvoiceBids = List();
  List<InvestorInvoiceSettlement> _settlements = List();
  List<InvoiceAcceptance> _invoiceAcceptances = List();
  Supplier _supplier;
  User _user;
  SupplierBlocListener _listener;

  List<DeliveryNote> get deliveryNotes => _deliveryNotes;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<Invoice> get invoices => _invoices;
  List<DeliveryAcceptance> get deliveryAcceptances => _deliveryAcceptances;
  List<Offer> get offers => _offers;
  List<InvoiceBid> get unsettledInvoiceBids => _unsettledInvoiceBids;
  List<InvoiceBid> get settledInvoiceBids => _settledInvoiceBids;
  List<InvestorInvoiceSettlement> get settlements => _settlements;
  List<InvoiceAcceptance> get invoiceAcceptances => _invoiceAcceptances;
  Supplier get supplier => _supplier;
  User get user => _user;
  SupplierBlocListener get listener => _listener;
  int _pageLimit = 10;
  int get pageLimit => _pageLimit;

  void setListener(SupplierBlocListener sbListener) {
    _listener = sbListener;
  }

  void initialize() async {
    print(
        '\n\n\nSupplierAppModel.initialize - ############### load model data from cache');
    var start = DateTime.now();
    _supplier = await SharedPrefs.getSupplier();
    _user = await SharedPrefs.getUser();
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }

    _purchaseOrders = await Database.getPurchaseOrders();
    _setItemNumbers(_purchaseOrders);

    if (_purchaseOrders == null || _purchaseOrders.isEmpty) {
      refreshModel();
      return;
    }

    print(
        'SupplierAppModel.initialize, _purchaseOrders found in database: ${_purchaseOrders.length}');
    print(
        '\n\nSupplierAppModel.initialize - ############### loading Model from cache ...');
    _deliveryNotes = await Database.getDeliveryNotes();
    _setItemNumbers(_deliveryNotes);

    _deliveryAcceptances = await Database.getDeliveryAcceptances();
    _setItemNumbers(_deliveryAcceptances);

    _invoices = await Database.getInvoices();
    _setItemNumbers(_invoices);

    _invoiceAcceptances = await Database.getInvoiceAcceptances();
    _setItemNumbers(_invoiceAcceptances);

    _offers = await Database.getOffers();
    _setItemNumbers(_offers);

    _unsettledInvoiceBids = await Database.getUnsettledInvoiceBids();
    _setItemNumbers(_unsettledInvoiceBids);

    _settlements = await Database.getInvestorInvoiceSettlements();
    _setItemNumbers(_settlements);

    var end = DateTime.now();
    print(
        '\n\nSupplierAppModel.initialize ######### model refreshed: elapsed time: ${end.difference(start).inMilliseconds} milliseconds. calling notifyListeners');
  }

  void _setItemNumbers(List<Findable> list) {
    if (list == null) return;
    int num = 1;
    list.forEach((o) {
      o.itemNumber = num;
      num++;
    });
    _listener.onComplete();
  }

  Future addPurchaseOrder(PurchaseOrder order) async {
    _purchaseOrders.insert(0, order);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
  }

  Future addDeliveryNote(DeliveryNote note) async {
    _deliveryNotes.insert(0, note);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
  }

  Future addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
  }

  Future addDeliveryAcceptance(DeliveryAcceptance acceptance) async {
    _deliveryAcceptances.insert(0, acceptance);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
  }

  Future addInvoiceAcceptance(InvoiceAcceptance acceptance) async {
    _invoiceAcceptances.insert(0, acceptance);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
  }

  Future addOffer(Offer offer) async {
    _offers.insert(0, offer);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
  }

  Future addInvestorInvoiceSettlement(
      InvestorInvoiceSettlement settlement) async {
    _settlements.insert(0, settlement);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);
  }

  Future addUnsettledInvoiceBid(InvoiceBid bid) async {
    _unsettledInvoiceBids.insert(0, bid);
    await Database.saveUnsettledInvoiceBids(InvoiceBids(_unsettledInvoiceBids));
    _setItemNumbers(_unsettledInvoiceBids);
  }

  int getTotalOpenOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isOpen) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalOpenOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isOpen) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  double getTotalDeliveryNoteAmount() {
    var tot = 0.0;
    _deliveryNotes.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalClosedOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isOpen == false) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalClosedOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isOpen == false) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  int getTotalCancelledOffers() {
    var tot = 0;
    _offers.forEach((o) {
      if (o.isCancelled) {
        tot++;
      }
    });
    return tot;
  }

  double getTotalSettlementValue() {
    var tot = 0.00;
    _settlements.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  double getTotalCancelledOfferAmount() {
    var tot = 0.0;
    _offers.forEach((o) {
      if (o.isCancelled) {
        tot += o.offerAmount;
      }
    });
    return tot;
  }

  double getTotalInvoiceAmount() {
    var tot = 0.00;
    _invoices.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalInvoices() {
    return _invoices.length;
  }

  int getTotalPurchaseOrders() {
    return _purchaseOrders.length;
  }

  double getTotalPurchaseOrderAmount() {
    var tot = 0.0;
    _purchaseOrders.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  int getTotalSettlements() {
    return _settlements.length;
  }

  double getTotalSettlementAmount() {
    if (_settlements == null) return 0.0;
    var tot = 0.0;
    _settlements.forEach((o) {
      tot += o.amount;
    });
    return tot;
  }

  Future updatePageLimit(int pageLimit) async {
    _pageLimit = pageLimit;
    await SharedPrefs.savePageLimit(pageLimit);
    return null;
  }

  static const SUPPLIER_TYPE = 'supplier';
  Future refreshModel() async {
    if (_supplier == null) return null;
    print('SupplierAppModel.refreshModel - get fresh data from Firestore');
    var start = DateTime.now();
    _purchaseOrders =
        await ListAPI.getSupplierPurchaseOrders(_supplier.participantId);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);

    _deliveryNotes = await ListAPI.getDeliveryNotes(
        participantId: _supplier.participantId, participantType: SUPPLIER_TYPE);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
    print('\n\n');

    _invoices = await ListAPI.getInvoicesBySupplier(_supplier.participantId);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
    print('\n\n');

    _offers = await ListAPI.getOffersBySupplier(_supplier.participantId);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    print('\n\n');

    _deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        participantId: _supplier.participantId, participantType: SUPPLIER_TYPE);
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
    print('\n\n');

    _invoiceAcceptances = await ListAPI.getInvoiceAcceptances(
        participantId: _supplier.participantId, participantType: SUPPLIER_TYPE);
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
    print('\n\n');

    _settlements =
        await ListAPI.getSupplierInvestorSettlements(_supplier.participantId);
    await Database.saveInvestorInvoiceSettlements(
        InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);

    var end = DateTime.now();
    print(
        '\n\nSupplierAppModel.refreshModel ############ Refresh Complete, elapsed: ${end.difference(start).inSeconds} seconds');
    if (_listener != null) {
      _listener.onComplete();
    }
    return 0;
  }

  Future refreshOffers() async {
    _offers = await ListAPI.getOffersBySupplier(_supplier.participantId);
    _setItemNumbers(_offers);
    await Database.saveOffers(Offers(_offers));
  }

  Future refreshDeliveryNotes() async {
    _deliveryNotes = await ListAPI.getDeliveryNotes(
        participantId: _supplier.participantId, participantType: SUPPLIER_TYPE);
    _setItemNumbers(_deliveryNotes);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
  }
}
