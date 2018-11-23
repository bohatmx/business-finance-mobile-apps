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
import 'package:scoped_model/scoped_model.dart';

class SupplierAppModel extends Model {
  List<DeliveryNote> _deliveryNotes = List();
  List<PurchaseOrder> _purchaseOrders = List();
  List<Invoice> _invoices = List();
  List<DeliveryAcceptance> _deliveryAcceptances = List();
  List<Offer> _offers = List();
  List<InvoiceBid> _invoiceBids = List();
  List<InvestorInvoiceSettlement> _settlements = List();
  List<InvoiceAcceptance> _invoiceAcceptances = List();
  Supplier _supplier;
  User _user;
  SupplierAppModelListener _listener;

  List<DeliveryNote> get deliveryNotes => _deliveryNotes;
  List<PurchaseOrder> get purchaseOrders => _purchaseOrders;
  List<Invoice> get invoices => _invoices;
  List<DeliveryAcceptance> get deliveryAcceptances => _deliveryAcceptances;
  List<Offer> get offers => _offers;
  List<InvoiceBid> get invoiceBids => _invoiceBids;
  List<InvestorInvoiceSettlement> get settlements => _settlements;
  List<InvoiceAcceptance> get invoiceAcceptances => _invoiceAcceptances;
  Supplier get supplier => _supplier;
  User get user => _user;
  SupplierAppModelListener get listener => _listener;
  int _pageLimit = 10;
  int get pageLimit  => _pageLimit;


  SupplierAppModel() {
    initialize();
  }
  void initialize() async {
    print('\n\n\nSupplierAppModel.initialize - ############### load model data');
    var start = DateTime.now();
    _supplier = await SharedPrefs.getSupplier();
    _user = await SharedPrefs.getUser();
    _pageLimit = await SharedPrefs.getPageLimit();
    if (_pageLimit == null) {
      _pageLimit = 10;
    }

    _purchaseOrders = await Database.getPurchaseOrders();
    _setItemNumbers(_purchaseOrders);

    print('SupplierAppModel.initialize, _purchaseOrders found in database: ${_purchaseOrders.length}');
    if (_purchaseOrders == null || _purchaseOrders.isEmpty) {
      refreshModel();
      return;
    }
    print('\n\nSupplierAppModel.initialize - ############### loading Model from cache ...');
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

    _invoiceBids = await Database.getInvoiceBids();
    _setItemNumbers(_invoiceBids);

    _settlements = await Database.getInvestorInvoiceSettlements();
    _setItemNumbers(_settlements);

    var end = DateTime.now();
    print('\n\nSupplierAppModel.initialize ######### model refreshed: elapsed time: ${end.difference(start).inMilliseconds} milliseconds. calling notifyListeners');

    notifyListeners();
  }

  void _setItemNumbers(List<Findable> list) {
    if (list == null) return;
    int num = 1;
    list.forEach((o) {
      o.itemNumber = num;
      num++;
    });
  }
  Future addPurchaseOrder(PurchaseOrder order) async {
    _purchaseOrders.insert(0, order);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
    notifyListeners();
  }
  Future addDeliveryNote(DeliveryNote note) async {
    _deliveryNotes.insert(0, note);
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
    notifyListeners();
  }
  Future addInvoice(Invoice invoice) async {
    _invoices.insert(0, invoice);
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
    notifyListeners();
  }
  Future addDeliveryAcceptance(DeliveryAcceptance acceptance) async {
    _deliveryAcceptances.insert(0, acceptance);
    await Database.saveDeliveryAcceptances(DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
    notifyListeners();
  }
  Future addInvoiceAcceptance(InvoiceAcceptance acceptance) async {
    _invoiceAcceptances.insert(0, acceptance);
    await Database.saveInvoiceAcceptances(InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
    notifyListeners();
  }
  Future addOffer(Offer offer) async {
    _offers.insert(0, offer);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    notifyListeners();
  }
  Future addInvestorInvoiceSettlement(InvestorInvoiceSettlement settlement) async {
    _settlements.insert(0, settlement);
    await Database.saveInvestorInvoiceSettlements(InvestorInvoiceSettlements(_settlements));
    _setItemNumbers(_settlements);
    notifyListeners();
  }
  Future addInvoiceBid(InvoiceBid bid) async {
    _invoiceBids.insert(0, bid);
    await Database.saveInvoiceBids(InvoiceBids(_invoiceBids));
    _setItemNumbers(_invoiceBids);
    notifyListeners();
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

  void setListener(SupplierAppModelListener listener) {
    _listener = listener;
  }

  Future refreshModel() async {
    print('SupplierAppModel.refreshModel - get fresh data from Firestore');
    var start = DateTime.now();
    _purchaseOrders =
        await ListAPI.getSupplierPurchaseOrders(_supplier.documentReference);
    await Database.savePurchaseOrders(PurchaseOrders(_purchaseOrders));
    _setItemNumbers(_purchaseOrders);
    notifyListeners();
    print('\n\n');

    _deliveryNotes = await ListAPI.getDeliveryNotes(
        _supplier.documentReference, 'suppliers');
    await Database.saveDeliveryNotes(DeliveryNotes(_deliveryNotes));
    _setItemNumbers(_deliveryNotes);
    notifyListeners();
    print('\n\n');

    _invoices =
        await ListAPI.getInvoices(_supplier.documentReference, 'suppliers');
    await Database.saveInvoices(Invoices(_invoices));
    _setItemNumbers(_invoices);
    notifyListeners();
    print('\n\n');

    _offers = await ListAPI.getOffersBySupplier(_supplier.participantId);
    await Database.saveOffers(Offers(_offers));
    _setItemNumbers(_offers);
    notifyListeners();
    print('\n\n');

    _deliveryAcceptances = await ListAPI.getDeliveryAcceptances(
        _supplier.documentReference, 'suppliers');
    await Database.saveDeliveryAcceptances(
        DeliveryAcceptances(_deliveryAcceptances));
    _setItemNumbers(_deliveryAcceptances);
    notifyListeners();
    print('\n\n');


    _invoiceAcceptances = await ListAPI.getInvoiceAcceptances(
        _supplier.documentReference, 'suppliers');
    await Database.saveInvoiceAcceptances(
        InvoiceAcceptances(_invoiceAcceptances));
    _setItemNumbers(_invoiceAcceptances);
    notifyListeners();
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
      _listener.onRefreshComplete();
    }
    notifyListeners();
    return 0;
  }
  Future refreshOffers() async{
    _offers = await ListAPI.getOffersBySupplier(_supplier.participantId);
    _setItemNumbers(_offers);
    await Database.saveOffers(Offers(_offers));
    notifyListeners();
  }
}

abstract class SupplierAppModelListener {
  onRefreshComplete();
}
