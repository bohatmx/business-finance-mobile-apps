import 'dart:async';
import 'dart:convert';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/auto_start_stop.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor-unsettled-summary.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ListAPI {
  static final Firestore _firestore = Firestore.instance;

  static Future<AutoTradeStart> getAutoTradeStart() async {
    AutoTradeStart start;
    var qs = await _firestore
        .collection('autoTradeStarts')
        .orderBy('dateEnded', descending: true)
        .limit(1)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeStart $e');
      return null;
    });
    print('ListAPI.getAutoTradeStart found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    start = AutoTradeStart.fromJson(qs.documents.first.data);

    return start;
  }

  static Future<Wallet> getWallet(String ownerType, String name) async {
    print('ListAPI.getWallet ownerType: $ownerType name: $name');
    var qs = await _firestore
        .collection('wallets')
        .where(ownerType, isEqualTo: name)
        .getDocuments();
    Wallet wallet = Wallet.fromJson(qs.documents.first.data);
    if (wallet.secret == null) {
      var decrypted =
          await decrypt(wallet.stellarPublicKey, wallet.encryptedSecret);
      wallet.secret = decrypted;
    }
    await SharedPrefs.saveWallet(wallet);
    return wallet;
  }

  static Future<List<User>> getGovtUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.govtEntity != null) {
        list.add(user);
      }
    });
    print('ListAPI.getGovtUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getInvestorUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.investor != null) {
        list.add(user);
      }
    });
    print('ListAPI.getInvestorUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getSupplierUsers() async {
    List<User> ulist = await getUsers();
    List<User> list = List();
    ulist.forEach((user) {
      if (user.supplier != null) {
        list.add(user);
      }
    });
    print('ListAPI.getSupplierUsers found: ${list.length} ');
    return list;
  }

  static Future<List<User>> getUsers() async {
    List<User> list = List();
    var qs =
        await _firestore.collection('users').getDocuments().catchError((e) {
      print('ListAPI.getUsers $e');
      return list;
    });
    print(
        'ListAPI.getUsers ########## found in QuerySnapshot: ${qs.documents.length} ');
    qs.documents.forEach((doc) {
      list.add(new User.fromJson(doc.data));
    });

    print('ListAPI.getUsers ########## found in list: ${list.length} ');
    return list;
  }

  static Future<OfferBag> getOfferWithBids(String offerId) async {
    List<InvoiceBid> list = List();
    OfferBag bag;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('offerId', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return list;
    });
    if (qs.documents.isNotEmpty) {
      var offer = Offer.fromJson(qs.documents.first.data);
      var snap = await qs.documents.first.reference
          .collection('invoiceBids')
          .getDocuments();

      snap.documents.forEach((doc) {
        var bid = InvoiceBid.fromJson(doc.data);
        list.add(bid);
      });
      print('ListAPI.getInvoiceBidsByOffer found ${list.length} invoice bids');
      bag = OfferBag(offer: offer, invoiceBids: list);
    }

    return bag;
  }

  static Future<InvoiceAcceptance> getLastInvoiceAcceptance(
      String supplierDocRef) async {
    InvoiceAcceptance acceptance;

    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocRef)
        .collection('invoiceAcceptances')
        .orderBy('date', descending: true)
        .limit(1)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getLastInvoiceAcceptance $e');
      return acceptance;
    });
    if (qs.documents.isNotEmpty) {
      acceptance = InvoiceAcceptance.fromJson(qs.documents.first.data);
    }
    if (acceptance != null) {
      print('ListAPI.getLastInvoiceAcceptance found ${acceptance.toJson()}');
    }
    return acceptance;
  }

  static Future<InvoiceAcceptance> getInvoiceAcceptanceByInvoice(
      String supplierDocRef, String invoice) async {
    InvoiceAcceptance acceptance;

    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocRef)
        .collection('invoiceAcceptances')
        .where('invoice', isEqualTo: invoice)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return acceptance;
    });
    if (qs.documents.isNotEmpty) {
      acceptance = InvoiceAcceptance.fromJson(qs.documents.first.data);
    }
    if (acceptance != null) {
      print(
          'ListAPI.getInvoiceAcceptanceByInvoice found ${acceptance.toJson()}');
    }
    return acceptance;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByOffer(String offerId) async {
    List<InvoiceBid> list = List();

    var qs = await _firestore
        .collection('invoiceOffers')
        .where('offerId', isEqualTo: offerId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferInvoiceBids $e');
      return list;
    });
    if (qs.documents.isNotEmpty) {
      var offer = Offer.fromJson(qs.documents.first.data);
      var snap = await qs.documents.first.reference
          .collection('invoiceBids')
          .getDocuments();

      snap.documents.forEach((doc) {
        var bid = InvoiceBid.fromJson(doc.data);
        list.add(bid);
      });
    }
    print('ListAPI.getInvoiceBidsByOffer found ${list.length} invoice bids');
    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidsByInvestor(
      String documentReference) async {
    print(
        'ListAPI.getInvoiceBidsByInvestor ========= documentReference: $documentReference');
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('investors')
        .document(documentReference)
        .collection('invoiceBids')
        .where('isSettled', isEqualTo: false)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorInvoiceBids $e');
      return list;
    });

    print('ListAPI.getInvestorInvoiceBids found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvoiceBid.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvoiceBid>> getInvoiceBidByInvestorOffer(
      Offer offer, Investor investor) async {
    assert(offer.documentReference != null);
    print(
        'ListAPI.getInvoiceBidByInvestorOffer =======> offer.documentReference: ${offer.documentReference} '
        'offer.offerId: ${offer.offerId} participantId: ${investor.participantId}');
    List<InvoiceBid> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .document(offer.documentReference)
        .collection('invoiceBids')
        .where('offer',
            isEqualTo: 'resource:com.oneconnect.biz.Offer#${offer.offerId}')
        .where('investor',
            isEqualTo:
                'resource:com.oneconnect.biz.Investor#${investor.participantId}')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceBidByInvestorOffer $e');
      return list;
    });

    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer: qs.documents isEmpty ----------');
    } else {
      print(
          'ListAPI.getInvoiceBidByInvestorOffer - we have a document here!!!!!!!');
    }
    qs.documents.forEach((doc) {
      var invoiceBid = InvoiceBid.fromJson(doc.data);
      invoiceBid.documentReference = doc.documentID;
      list.add(invoiceBid);
    });
    print(
        'ListAPI.getInvoiceBidByInvestorOffer ######## found objects: ${list.length} ');
    return list;
  }

  static Future<OfferBag> getOfferById(String id) async {
    Offer offer;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('offerId', isEqualTo: id)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });
    print('ListAPI.getOfferById found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    offer = Offer.fromJson(qs.documents.first.data);

    var qs1 = await _firestore
        .collection('invoiceOffers')
        .document(qs.documents.first.documentID)
        .collection('invoiceBids')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferById $e');
      return null;
    });

    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print('ListAPI.getOfferById found invoice bids: ${qs1.documents.length} ');
    var bag = OfferBag(offer: offer, invoiceBids: bids);
    return bag;
  }

  static Future<OfferBag> getOfferByInvoice(String invoiceId) async {
    Offer offer;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('invoice',
            isEqualTo: 'resource:com.oneconnect.biz.Invoice#$invoiceId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });
    print(
        'ListAPI.getOfferByInvoice ++++++++++++++++ found offers: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return null;
    }
    offer = Offer.fromJson(qs.documents.first.data);

    var qs1 = await _firestore
        .collection('invoiceOffers')
        .document(qs.documents.first.documentID)
        .collection('invoiceBids')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOfferByInvoice $e');
      return null;
    });

    List<InvoiceBid> bids = List();
    qs1.documents.forEach((doc) {
      bids.add(InvoiceBid.fromJson(doc.data));
    });
    print(
        'ListAPI.getOfferByInvoice @@@@@@@@@@@@@ found invoice bids: ${qs1.documents.length} ');

    var bag = OfferBag(offer: offer, invoiceBids: bids);
    bag.doPrint();
    return bag;
  }

  static Future<List<Offer>> getOffersByPeriod(
      DateTime startTime, DateTime endTime) async {
    print(
        'ListAPI.getOffersByPeriod startTime: ${startTime.toIso8601String()}  endTime: ${endTime.toIso8601String()}');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('startTime', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('startTime', isLessThanOrEqualTo: endTime.toIso8601String())
        .orderBy('startTime', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersByPeriod $e');
      return list;
    });
    print('ListAPI.getOffersByPeriod found: ${qs.documents.length} ');
    if (qs.documents.isEmpty) {
      return list;
    }
    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySector(
      String privateSectorType, DateTime startTime, DateTime endTime) async {
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('date', isGreaterThanOrEqualTo: startTime.toIso8601String())
        .where('date', isLessThanOrEqualTo: endTime.toIso8601String())
        .where('privateSectorType', isEqualTo: privateSectorType)
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierOffers $e');
      return list;
    });

    print('ListAPI.getSupplierOffers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOffersBySupplier(String supplierId) async {
    print('ListAPI.getOffersBySupplier ---------------supplierId: $supplierId');
    List<Offer> list = List();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('supplier',
            isEqualTo: 'resource:com.oneconnect.biz.Supplier#$supplierId')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOffersBySupplier $e');
      return list;
    });

    print('ListAPI.getOffersBySupplier found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<Offer> checkOfferByInvoice(String invoiceId) async {
    print('ListAPI.checkOfferByInvoice ---------------supplierId: $invoiceId');
    Offer offer;
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('invoice',
            isEqualTo: 'resource:com.oneconnect.biz.Invoice#$invoiceId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.checkOfferByInvoice $e');
      return offer;
    });

    print('ListAPI.checkOfferByInvoice found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
    });

    return offer;
  }

  static Future<List<Offer>> getOpenOffersBySupplier(String supplierId) async {
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('isOpen', isEqualTo: true)
        .where('supplier',
            isEqualTo: 'resource:com.oneconnect.biz.Supplier#$supplierId')
        .where('endTime', isGreaterThan: now)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOpenOffersBySupplier $e');
      return list;
    });

    print(
        'ListAPI.getOpenOffersBySupplier +++++++ open offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getOpenOffers() async {
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('isOpen', isEqualTo: true)
        .where('endTime', isGreaterThan: now)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getOpenOffers $e');
      return list;
    });

    print(
        'ListAPI.getOpenOffers +++++++ >>> offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  static Future<List<Offer>> getExpiredOffers() async {
    List<Offer> list = List();
    var now = getUTCDate();
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('isOpen', isEqualTo: true)
        .where('endTime', isLessThan: now)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getExpiredOffers $e');
      return list;
    });

    print(
        'ListAPI.getExpiredOffers ------- offers found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      var offer = Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      list.add(offer);
    });

    return list;
  }

  ///check if auto trade is running
  static Future<bool> checkLatestAutoTradeStart() async {
    try {
      var qs = await _firestore
          .collection('autoTradeStarts')
          .where('dateEnded', isNull: true)
          .getDocuments()
          .catchError((e) {
        print('DataAPI.addAutoTradeStart ERROR adding to Firestore $e');
        return '0';
      });
      if (qs.documents.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('DataAPI.addAutoTradeStart ERROR $e');
      return false;
    }
  }

  static Future<List<PurchaseOrder>> getCustomerPurchaseOrders(
      String documentId) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('govtEntities')
        .document(documentId)
        .collection('purchaseOrders')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      m.documentReference = doc.documentID;
      list.add(m);
    });
    print(
        'ListAPI.getCustomerPurchaseOrders &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<List<Invoice>> getCustomerInvoices(String documentId) async {
    List<Invoice> list = List();
    var querySnapshot = await _firestore
        .collection('govtEntities')
        .document(documentId)
        .collection('invoices')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCustomerInvoices  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new Invoice.fromJson(doc.data);
      m.documentReference = doc.documentID;
      list.add(m);
    });
    print('ListAPI.getCustomerInvoices &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<List<PurchaseOrder>> getSupplierPurchaseOrders(
      String supplierDocRef) async {
    List<PurchaseOrder> list = List();
    var querySnapshot = await _firestore
        .collection('suppliers')
        .document(supplierDocRef)
        .collection('purchaseOrders')
        .orderBy('date', descending: true)
        .limit(100)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierPurchaseOrders  ERROR $e');
      return list;
    });
    querySnapshot.documents.forEach((doc) {
      var m = new PurchaseOrder.fromJson(doc.data);
      m.documentReference = doc.documentID;
      list.add(m);
    });
    print(
        'ListAPI.getSupplierPurchaseOrders &&&&&&&&&&& found: ${list.length} ');
    return list;
  }

  static Future<DashboardData> getSupplierDashboardData(
      String supplierId, String documentId) async {
    print('ListAPI.getSupplierDashboardData ..........');
    var data = DashboardParms(id: supplierId, documentId: documentId);

    try {
      DashboardData result =
          await _doDashboardHTTP(getFunctionsURL() + 'supplierDashboard', data);
      prettyPrint(result.toJson(), '### Supplier Dashboard Data:');
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<DashboardData> getInvestorDashboardData(
      String investorId, String documentId) async {
    print('ListAPI.getDashboardData ..........');
    var data = DashboardParms(id: investorId, documentId: documentId);

    DashboardData result =
        await _doDashboardHTTP(getFunctionsURL() + 'investorDashboard', data);
    if (result != null) {
      prettyPrint(result.toJson(), '### Dashboard Data:');
    }
    return result;
  }

  static Future<DashboardData> getCustomerDashboardData(
      String documentId) async {
    print('ListAPI.getCustomerDashboardData ..........');
    var data = DashboardParms(documentId: documentId);

    DashboardData result =
        await _doDashboardHTTP(getFunctionsURL() + 'customerDashboard', data);
    prettyPrint(result.toJson(), '### Dashboard Data from function call:');
    return result;
  }

  static Future<OpenOfferSummary> getOpenOffersWithPaging(
      {int lastDate, int pageLimit}) async {
    OpenOfferSummary summary = await _doOpenOffersHTTP(
        getFunctionsURL() + 'getOpenOffersWithPaging', lastDate, pageLimit);
    if (summary.offers != null) {
      print(
          'ListAPI.getOpenOffersWithPaging &&&&&&&&&&& found: ${summary.offers.length} \n\n');
    }
    return summary;
  }

  static Future<PurchaseOrderSummary> getSupplierPurchaseOrdersWithPaging(
      {int startKey, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getFunctionsURL() + 'getPurchaseOrdersWithPaging',
        date: startKey,
        pageLimit: pageLimit,
        collection: 'suppliers',
        documentId: documentId);

    return summary;
  }

  static Future<PurchaseOrderSummary> getCustomerPurchaseOrdersWithPaging(
      {int lastDate, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getFunctionsURL() + 'getPurchaseOrdersWithPaging',
        date: lastDate,
        pageLimit: pageLimit,
        collection: 'govtEntities',
        documentId: documentId);

    return summary;
  }

  static Future<PurchaseOrderSummary> getCustomerInvoicessWithPaging(
      {int lastDate, int pageLimit, String documentId}) async {
    PurchaseOrderSummary summary = await _doPurchaseOrderHTTP(
        mUrl: getFunctionsURL() + 'getPurchaseOrdersWithPaging',
        date: lastDate,
        pageLimit: pageLimit,
        collection: 'govtEntities',
        documentId: documentId);

    return summary;
  }

  static Future<OpenOfferSummary> _doOpenOffersHTTP(
      String mUrl, int date, int pageLimit) async {
    OpenOfferSummary summary = OpenOfferSummary();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> map;
    if (date != null) {
      map = {'date': date, 'pageLimit': pageLimit};
    } else {
      map = {'pageLimit': pageLimit};
    }
    print('ListAPI._doOpenOffersHTTP ------- parameters: $map');
    var start = DateTime.now();
    try {
      var client = new http.Client();
      var resp = await client
          .post(
        mUrl,
        body: json.encode(map),
        headers: headers,
      )
          .whenComplete(() {
        client.close();
      });
      print(
          'ListAPI._doOpenOffersHTTP .... ## Query via Cloud Functions: status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        summary = OpenOfferSummary.fromJson(json.decode(resp.body));
        print(
            'ListAPI._doOpenOffersHTTP summary, offers: ${summary.offers.length}');
      } else {
        print(resp.body);
      }
    } catch (e) {
      print('ListAPI._doOpenOffersHTTP $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI._doOpenOffersHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<PurchaseOrderSummary> _doPurchaseOrderHTTP(
      {String mUrl,
      int date,
      int pageLimit,
      String documentId,
      String collection}) async {
    PurchaseOrderSummary summary;
    ;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    Map<String, dynamic> map;
    if (date != null) {
      map = {
        'date': date,
        'pageLimit': pageLimit,
        'collection': collection,
        'documentId': documentId
      };
    } else {
      map = {
        'pageLimit': pageLimit,
        'collection': collection,
        'documentId': documentId
      };
    }
    print('ListAPI._doPurchaseOrderHTTP ------- parameters: $map');
    var start = DateTime.now();
    try {
      var client = new http.Client();
      var resp = await client
          .post(
        mUrl,
        body: json.encode(map),
        headers: headers,
      )
          .whenComplete(() {
        client.close();
      });
      print(
          'ListAPI._doPurchaseOrderHTTP .... ## Query via Cloud Functions: status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        //print(resp.body);
        summary = PurchaseOrderSummary.fromJson(json.decode(resp.body));
        print(
            'ListAPI._doPurchaseOrderHTTP summary,: ${summary.purchaseOrders.length} purchase orders found');
      } else {
        print(resp.body);
      }
    } catch (e) {
      print('ListAPI._doPurchaseOrderHTTP $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI._doPurchaseOrderHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<OpenOfferSummary> getOpenOffersSummary() async {
    OpenOfferSummary summary = OpenOfferSummary();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var mUrl = getFunctionsURL() + 'getOpenOffersSummary';
    Map<String, dynamic> map;
    map = {'debug': isInDebugMode};

    var start = DateTime.now();
    try {
      var client = new http.Client();
      var resp = await client
          .post(
        mUrl,
        body: json.encode(map),
        headers: headers,
      )
          .whenComplete(() {
        client.close();
      });
      print(
          'ListAPI.getOpenOffersSummary .... ## Query via Cloud Functions: status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        summary = OpenOfferSummary.fromJson(json.decode(resp.body));
        print('ListAPI.getOpenOffersSummary summary: ${summary.toJson()}');
      } else {
        print(resp.body);
      }
    } catch (e) {
      print('ListAPI.getOpenOffersSummary $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI.getOpenOffersSummary ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<InvestorUnsettledBidSummary> getInvestorUnsettledBidSummary(
      String investorId) async {
    InvestorUnsettledBidSummary summary;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var mUrl = getFunctionsURL() + 'getInvestorsSummary';
    Map<String, dynamic> map;
    map = {'investorId': investorId};

    var start = DateTime.now();
    try {
      var client = new http.Client();
      var resp = await client
          .post(
        mUrl,
        body: json.encode(map),
        headers: headers,
      )
          .whenComplete(() {
        client.close();
      });
      print(
          'ListAPI.getInvestorUnsettledBidSummary .... ## Query via Cloud Functions: status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        summary = InvestorUnsettledBidSummary.fromJson(json.decode(resp.body));
        prettyPrint(summary.toJson(),
            'ListAPI.getInvestorUnsettledBidSummary summary:');
      } else {
        print(resp.body);
      }
    } catch (e) {
      print('ListAPI.getInvestorUnsettledBidSummary $e');
    }
    var end = DateTime.now();
    print(
        'ListAPI.getInvestorUnsettledBidSummary ### elapsed: ${end.difference(start).inSeconds} seconds');
    return summary;
  }

  static Future<DashboardData> _doDashboardHTTP(
      String mUrl, DashboardParms dashParms) async {
    DashboardData data;
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var start = DateTime.now();
    try {
      var client = new http.Client();
      var resp = await client
          .post(
        mUrl,
        body: json.encode(dashParms.toJson()),
        headers: headers,
      )
          .whenComplete(() {
        client.close();
      });
      print(
          'ListAPI.doHTTP .... ################ Query via Cloud Functions: status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        print(resp.body);
        data = DashboardData.fromJson(json.decode(resp.body));
        var end = DateTime.now();
        print(
            '\n\nListAPI._doHTTP ### elapsed: ${end.difference(start).inSeconds} seconds');
        return data;
      } else {
        throw Exception('Dashboard data query failed');
      }
    } catch (e) {
      print('ListAPI._doHTTP $e');
      throw e;
    }

    return data;
  }

  static Future<List<Invoice>> getInvoices(
      String documentId, String collection) async {
    print('ListAPI.getInvoices ............. documentId: $documentId');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoices $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoices - no docs found');
      return list;
    }
    qs.documents.forEach((doc) {
      list.add(new Invoice.fromJson(doc.data));
    });

    if (list.isNotEmpty) {
      print(
          'ListAPI.getInvoices ################## found: ${list.length} from ${list.elementAt(0).supplierName}');
    }
    return list;
  }

  static Future<List<Invoice>> getInvoicesOpenForOffers(
      String documentId, String collection) async {
    print(
        'ListAPI.getInvoicesOpenForOffers ............. documentId: $documentId in $collection');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('isOnOffer', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(1000)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOpenForOffers $e');
      return list;
    });

    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOpenForOffers - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOpenForOffers ################## found: ${list.length}');
//    list.forEach((inv) {
//      prettyPrint(inv.toJson(),
//          'getInvoicesOpenForOffers INVOICE NUMBER: ${inv.invoiceNumber}');
//    });
    return list;
  }

  static Future<List<Invoice>> getInvoicesOnOffer(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesOnOffer ............. documentId: $documentId');
    //type '(dynamic) => List<Invoice>' is not a subtype of type '(Object) => FutureOr<QuerySnapshot>'
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('offer', isGreaterThan: '')
//        .orderBy('date', descending: true)
        .limit(100)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesOnOffer $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesOnOffer - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    return list;
  }

  static Future<List<Invoice>> getInvoicesSettled(
      String documentId, String collection) async {
    print('ListAPI.getInvoicesSettled ............. documentId: $documentId');
    List<Invoice> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('invoices')
        .where('isSettled', isEqualTo: 'true')
        .orderBy('date', descending: true)
        .limit(1000)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesSettled $e');
      return list;
    });
    if (qs.documents.isEmpty) {
      print('ListAPI.getInvoicesSettled - no docs found');
      return list;
    }

    qs.documents.forEach((doc) {
      var inv = Invoice.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      list.add(inv);
    });
    print(
        'ListAPI.getInvoicesOnOffer ################## found: ${list.length}');
    list.forEach((inv) {
      prettyPrint(inv.toJson(),
          'getInvoicesSettled INVOICE NUMBER: ${inv.invoiceNumber}');
    });
    return list;
  }

  static Future<Invoice> getInvoice(
      String poNumber, String invoiceNumber, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoice ............. poNumber: $poNumber invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('purchaseOrderNumber', isEqualTo: poNumber)
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoice $e');
      return null;
    });
    print('ListAPI.getInvoice ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<List<Invoice>> getInvoicesByPurchaseOrder(
      String purchaseOrderId, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoicesByPurchaseOrder ............. deliveryNoteId: $purchaseOrderId  ');
    List<Invoice> invoices = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('purchaseOrder',
            isEqualTo:
                'resource:com.oneconnect.biz.PurchaseOrder#$purchaseOrderId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoicesByPurchaseOrder $e');
      return invoices;
    });
    print(
        'ListAPI.getInvoicesByPurchaseOrder ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        var invoice = Invoice.fromJson(doc.data);
        invoice.documentReference = qs.documents.first.documentID;
        invoices.add(invoice);
      });
    }

    return invoices;
  }

  static Future<Invoice> getInvoiceByDeliveryNote(
      String deliveryNoteId, String supplierDocumentRef) async {
    print(
        'ListAPI.getInvoiceByDeliveryNote ............. deliveryNoteId: $deliveryNoteId  ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('deliveryNote',
            isEqualTo:
                'resource:com.oneconnect.biz.DeliveryNote#$deliveryNoteId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvoiceByDeliveryNote $e');
      return null;
    });
    print(
        'ListAPI.getInvoiceByDeliveryNote ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Invoice> getSupplierInvoiceByNumber(
      String invoiceNumber, String supplierDocumentRef) async {
    print(
        'ListAPI.getSupplierInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getSupplierInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Invoice> getGovtInvoiceByNumber(
      String invoiceNumber, String govtDocumentRef) async {
    print(
        'ListAPI.getGovtInvoiceByNumber .............  invoiceNumber: $invoiceNumber ');
    Invoice invoice;
    var qs = await _firestore
        .collection('govtEntities')
        .document(govtDocumentRef)
        .collection('invoices')
        .where('invoiceNumber', isEqualTo: invoiceNumber)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    print(
        'ListAPI.getGovtInvoiceByNumber ............. fouund: ${qs.documents.length}');
    if (qs.documents.isNotEmpty) {
      invoice = Invoice.fromJson(qs.documents.first.data);
      invoice.documentReference = qs.documents.first.documentID;
    }

    return invoice;
  }

  static Future<Offer> findOfferByInvoice(String invoice) async {
    var qs = await _firestore
        .collection('invoiceOffers')
        .where('invoice',
            isEqualTo: 'resource:com.oneconnect.biz.Invoice#$invoice')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtInvoiceByNumber $e');
      return null;
    });
    if (qs.documents.isNotEmpty) {
      var offer = Offer.fromJson(qs.documents.first.data);
      return offer;
    } else {
      return null;
    }
  }

  static Future<List<DeliveryNote>> getDeliveryNotes(
      String documentId, String collection) async {
    print('ListAPI.getDeliveryNotes .......  documentId: $documentId');
    List<DeliveryNote> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryNotes')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNotes $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryNote.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryNote> getDeliveryNoteById(
      String deliveryNoteId, String documentId, String collection) async {
    print(
        'ListAPI.getDeliveryNoteById .......  documentId: $documentId deliveryNoteId: $deliveryNoteId');
    DeliveryNote dn;
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryNotes')
        .where('deliveryNoteId', isEqualTo: deliveryNoteId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNoteById $e');
      return dn;
    });

    if (qs.documents.isNotEmpty) {
      dn = DeliveryNote.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryNoteById ############ found: ${qs.documents.length}');
    return dn;
  }

  static Future<Supplier> getSupplierById(String participantId) async {
    Supplier supplier;
    var qs = await _firestore
        .collection('suppliers')
        .where('participantId', isEqualTo: participantId)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryNoteById $e');
      return supplier;
    });

    if (qs.documents.isNotEmpty) {
      supplier = Supplier.fromJson(qs.documents.first.data);
      supplier.documentReference = qs.documents.first.documentID;
    }

    print(
        'ListAPI.getDeliveryNoteById ############ found: ${qs.documents.length}');
    return supplier;
  }

  static Future<List<SupplierContract>> getSupplierContracts(
      String supplierDocumentRef) async {
    print(
        'ListAPI.getSupplierContracts .......  documentId: $supplierDocumentRef');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print('ListAPI.getSupplierContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<SupplierContract>> getSupplierGovtContracts(
      String supplierDocumentRef, String govtEntity) async {
    print(
        'ListAPI.getSupplierGovtContracts .......  supplierDocumentRef: $supplierDocumentRef govtEntity: $govtEntity');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .where('govtEntity', isEqualTo: govtEntity)
//        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierGovtContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print(
        'ListAPI.getSupplierGovtContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<SupplierContract>> getSupplierCompanyContracts(
      String supplierDocumentRef, String participantId) async {
    print(
        'ListAPI.getSupplierCompanyContracts .......  documentId: $supplierDocumentRef');
    List<SupplierContract> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .document(supplierDocumentRef)
        .collection('supplierContracts')
        .where('company',
            isEqualTo: 'resource:com.oneconnect.biz.Company#$participantId}')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSupplierCompanyContracts $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new SupplierContract.fromJson(doc.data));
    });

    print(
        'ListAPI.getSupplierCompanyContracts ############ found: ${list.length}');
    return list;
  }

  static Future<List<GovtEntity>> getGovtEntitiesByCountry(
      String country) async {
    print('ListAPI.getGovtEntities .......  country: $country');
    List<GovtEntity> list = List();
    var qs = await _firestore
        .collection('govtEntities')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getGovtEntities $e');
      return list;
    });

    qs.documents.forEach((doc) {
      var m = GovtEntity.fromJson(doc.data);
      m.documentReference = doc.documentID;
      list.add(m);
    });

    print('ListAPI.getGovtEntities ############ found: ${list.length}');
    return list;
  }

  static Future<List<Supplier>> getSuppliersByCountry(String country) async {
    print('ListAPI.getSuppliersByCountry .......  country: $country');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSuppliersByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Supplier.fromJson(doc.data));
    });

    print('ListAPI.getSuppliersByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<Company>> getCompaniesByCountry(String country) async {
    print('ListAPI.getCompaniesByCountry .......  country: $country');
    List<Company> list = List();
    var qs = await _firestore
        .collection('companies')
        .where('country', isEqualTo: country)
        .orderBy('name', descending: false)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getCompaniesByCountry $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new Company.fromJson(doc.data));
    });

    print('ListAPI.getCompaniesByCountry ############ found: ${list.length}');
    return list;
  }

  static Future<List<DeliveryAcceptance>> getDeliveryAcceptances(
      String documentId, String collection) async {
    print('ListAPI.getDeliveryAcceptances .......  documentId: $documentId');
    List<DeliveryAcceptance> list = List();
    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryAcceptances')
        .orderBy('date', descending: true)
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptances $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new DeliveryAcceptance.fromJson(doc.data));
    });

    print('ListAPI.getDeliveryNotes ############ found: ${list.length}');
    return list;
  }

  static Future<DeliveryAcceptance> getDeliveryAcceptanceForNote(
      String deliveryNoteId, String documentId, String collection) async {
    print(
        'ListAPI.getDeliveryAcceptanceForNote .......  documentId: $documentId deliveryNoteId: $deliveryNoteId');
    DeliveryAcceptance da;

    var qs = await _firestore
        .collection(collection)
        .document(documentId)
        .collection('deliveryAcceptances')
        .where('deliveryNote',
            isEqualTo:
                'resource:com.oneconnect.biz.DeliveryNote#$deliveryNoteId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getDeliveryAcceptanceForNote $e');
      return da;
    });

    if (qs.documents.isNotEmpty) {
      da = DeliveryAcceptance.fromJson(qs.documents.first.data);
    }

    print(
        'ListAPI.getDeliveryAcceptanceForNote ############ found: ${qs.documents.length}');
    return da;
  }

  static Future<List<Supplier>> getSuppliers() async {
    print('ListAPI.getSuppliers .......  ');
    List<Supplier> list = List();
    var qs = await _firestore
        .collection('suppliers')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSuppliers $e');
      return list;
    });

    qs.documents.forEach((doc) {
      var m = Supplier.fromJson(doc.data);
      m.documentReference = doc.documentID;
      list.add(m);
    });

    print('ListAPI.getSuppliers ############ found: ${list.length}');
    return list;
  }

  static Future<List<InvestorProfile>> getInvestorProfiles() async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorProfiles $e');
      return list;
    });

    if (qs.documents.isNotEmpty) {
      qs.documents.forEach((doc) {
        list.add(new InvestorProfile.fromJson(doc.data));
      });
    }

    return list;
  }

  static Future<InvestorProfile> getInvestorProfile(
      String participantId) async {
    InvestorProfile profile;
    var qs = await _firestore
        .collection('investorProfiles')
        .where('investor',
            isEqualTo: 'resource:com.oneconnect.biz.Investor#$participantId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestorProfiles $e');
      return null;
    });

    if (qs.documents.isNotEmpty) {
      profile = InvestorProfile.fromJson(qs.documents.first.data);
      prettyPrint(profile.toJson(), 'getInvestorProfile');
    }

    return profile;
  }

  static Future<AutoTradeOrder> getAutoTradeOrder(String participantId) async {
    AutoTradeOrder order;
    var qs = await _firestore
        .collection('autoTradeOrders')
        .where('participantId',
            isEqualTo: 'resource:com.oneconnect.biz.Investor#$participantId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeOrder $e');
      return null;
    });

    if (qs.documents.isNotEmpty) {
      order = AutoTradeOrder.fromJson(qs.documents.first.data);
      prettyPrint(order.toJson(), 'ListAPI.getAutoTradeOrder ');
    }

    return order;
  }

  static Future<List<AutoTradeOrder>> getAutoTradeOrders() async {
    List<AutoTradeOrder> list = List();
    var qs = await _firestore
        .collection('autoTradeOrders')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getAutoTradeOrders $e');
      return list;
    });

    qs.documents.forEach((doc) {
      list.add(new AutoTradeOrder.fromJson(doc.data));
    });

    print('ListAPI.getAutoTradeOrders ############ found: ${list.length}');
    return list;
  }

  static Future<List<PrivateSectorType>> getPrivateSectorTypes() async {
    List<PrivateSectorType> list = List();
    var qs = await _firestore
        .collection('privateSectorTypes')
        .orderBy('type')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getPrivateSectorTypes $e');
      return list;
    });

    print('ListAPI.getPrivateSectorTypes found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new PrivateSectorType.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<InvestorProfile>> getProfile(String participantId) async {
    List<InvestorProfile> list = List();
    var qs = await _firestore
        .collection('investorProfiles')
        .where('investor',
            isEqualTo: 'resource:com.oneconnect.biz.Investor#$participantId')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getProfile $e');
      return list;
    });

    print('ListAPI.getProfile found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new InvestorProfile.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Sector>> getSectors() async {
    List<Sector> list = List();
    var qs = await _firestore
        .collection('sectors')
        .orderBy('sectorName')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getSectors $e');
      return list;
    });

    print('ListAPI.getSectors found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Sector.fromJson(doc.data));
    });

    return list;
  }

  static Future<List<Investor>> getInvestors() async {
    List<Investor> list = List();
    var qs = await _firestore
        .collection('investors')
        .orderBy('name')
        .getDocuments()
        .catchError((e) {
      print('ListAPI.getInvestors $e');
      return list;
    });

    print('ListAPI.getInvestors found: ${qs.documents.length} ');

    qs.documents.forEach((doc) {
      list.add(new Investor.fromJson(doc.data));
    });

    return list;
  }
}

class OfferBag {
  Offer offer;
  List<InvoiceBid> invoiceBids = List();

  OfferBag({this.offer, this.invoiceBids});
  doPrint() {
//    prettyPrint(offer.toJson(), '######## OFFER:');
//    invoiceBids.forEach((m) {
//      prettyPrint(m.toJson(), '%%%%%%%%% BID:');
//    });
  }
}

class DashboardParms {
  String id;
  String documentId;

  DashboardParms({this.id, this.documentId});
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'documentId': documentId,
      };
}

class OpenOfferSummary {
  List<Offer> offers = List();
  int totalOpenOffers = 0;
  double totalOfferAmount = 0.00;
  int startedAfter;

  OpenOfferSummary(
      {this.offers,
      this.totalOpenOffers,
      this.totalOfferAmount,
      this.startedAfter});
  OpenOfferSummary.fromJson(Map data) {
    if (data['totalOpenOffers'] != null) {
      this.totalOpenOffers = data['totalOpenOffers'];
    } else {
      this.totalOpenOffers = 0;
    }
    if (data['totalOfferAmount'] != null) {
      this.totalOfferAmount = data['totalOfferAmount'] * 1.0;
    } else {
      this.totalOfferAmount = 0.00;
    }
    this.startedAfter = data['startedAfter'];
    if (data['offers'] != null) {
      List mOffers = data['offers'];
      offers = List();
      mOffers.forEach((o) {
        offers.add(Offer.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalOpenOffers': totalOpenOffers,
        'startedAfter': startedAfter,
        'totalOfferAmount': totalOfferAmount,
        'offers': offers,
      };
}

class PurchaseOrderSummary {
  List<PurchaseOrder> purchaseOrders = List();
  int totalPurchaseOrders = 0;
  double totalAmount = 0.00;
  int startedAfter;

  PurchaseOrderSummary(this.purchaseOrders, this.totalPurchaseOrders,
      this.totalAmount, this.startedAfter);

  PurchaseOrderSummary.fromJson(Map data) {
    this.totalPurchaseOrders = data['totalPurchaseOrders'];
    this.totalAmount = data['totalAmount'] * 1.0;
    this.startedAfter = data['startedAfter'];
    if (data['purchaseOrders'] != null) {
      List mPOs = data['purchaseOrders'];
      purchaseOrders = List();
      mPOs.forEach((o) {
        purchaseOrders.add(PurchaseOrder.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalPurchaseOrders': totalPurchaseOrders,
        'startedAfter': startedAfter,
        'totalAmount': totalAmount,
        'purchaseOrders': purchaseOrders,
      };
}

class InvoiceSummary {
  List<Invoice> invoices = List();
  int totalInvoices = 0;
  double totalAmount = 0.00;
  int startedAfter;

  InvoiceSummary(
      this.invoices, this.totalInvoices, this.totalAmount, this.startedAfter);

  InvoiceSummary.fromJson(Map data) {
    this.totalInvoices = data['totalInvoices'];
    this.totalAmount = data['totalAmount'] * 1.0;
    this.startedAfter = data['startedAfter'];
    if (data['invoices'] != null) {
      List mPOs = data['invoices'];
      invoices = List();
      mPOs.forEach((o) {
        invoices.add(Invoice.fromJson(o));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'totalInvoices': totalInvoices,
        'startedAfter': startedAfter,
        'totalAmount': totalAmount,
        'invoices': invoices,
      };
}
