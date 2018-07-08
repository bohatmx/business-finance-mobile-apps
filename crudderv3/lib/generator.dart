import 'dart:async';
import 'dart:math';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/signup.dart';
import 'package:businesslibrary/api/storage_api.dart';
import 'package:businesslibrary/data/auditor.dart';
import 'package:businesslibrary/data/bank.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/oneconnect.dart';
import 'package:businesslibrary/data/procurement_office.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/supplier_contract.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:businesslibrary/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletData {
  String participantId, name;
  int type;

  WalletData({this.participantId, this.name, this.type});
}

class Generator {
  static Firestore _fs = Firestore.instance;
  static const NameSpace = 'resource:com.oneconnect.biz.';
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  static DataAPI dataAPI;

  static List<WalletData> walletDataList = List();
  // ignore: missing_return
  static Future<int> generateWallets() async {
    dataAPI = DataAPI(getURL());
    var qs = await _fs.collection('govtEntities').getDocuments();
    qs.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: GovtEntityType);
      walletDataList.add(data);
    });
    var qs0 = await _fs.collection('suppliers').getDocuments();
    qs0.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: SupplierType);
      walletDataList.add(data);
    });

    var qs1 = await _fs.collection('investors').getDocuments();
    qs1.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: InvestorType);
      walletDataList.add(data);
    });
    var qs2 = await _fs.collection('companies').getDocuments();
    qs2.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: CompanyType);
      walletDataList.add(data);
    });

    var qs3 = await _fs.collection('auditors').getDocuments();
    qs3.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: AuditorType);
      walletDataList.add(data);
    });
    var qs4 = await _fs.collection('procurementOffices').getDocuments();
    qs4.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: ProcurementOfficeType);
      walletDataList.add(data);
    });
    var qs5 = await _fs.collection('banks').getDocuments();
    qs5.documents.forEach((doc) {
      var data = new WalletData(
          participantId: doc.data['participantId'],
          name: doc.data['name'],
          type: BankType);
      walletDataList.add(data);
    });

    print(
        'Generator.generateWallets ###### processing ${walletDataList.length} wallets .....');
    index = 0;
    _processWallet();
  }

  // ignore: missing_return
  static Future<int> _processWallet() async {
    if (walletDataList.isEmpty) {
      return 1;
    }
    var data = walletDataList.elementAt(index);
    await createWallet(
        name: data.name, participantId: data.participantId, type: data.type);
    index++;
    if (index < walletDataList.length) {
      _processWallet();
    } else {
      print(
          'Generator.processWallet DONE ####### wallets put on Firestore #######');
    }
  }

  static Future<int> generatePurchaseOrders() async {
    print('\n\n\nGenerator.generatePurchaseOrders ....................');
    List<GovtEntity> govtEntities = List();
    var qs = await _fs.collection('govtEntities').getDocuments();
    qs.documents.forEach((doc) {
      var g = new GovtEntity.fromJson(doc.data);
      govtEntities.add(g);
    });
    List<Supplier> suppliers = List();
    var qss = await _fs.collection('suppliers').getDocuments();
    qss.documents.forEach((doc) {
      var g = new Supplier.fromJson(doc.data);
      suppliers.add(g);
    });
    List<User> users = List();
    var qsu = await _fs.collection('users').getDocuments();
    qsu.documents.forEach((doc) {
      var g = new User.fromJson(doc.data);
      users.add(g);
    });
    ////
    print('\n\nGenerator.generatePurchaseOrders ######################### '
        'entities: ${govtEntities.length} suppliers: ${suppliers.length} users: ${users.length}\n\n');

    List<User> govtUsers = getGovtUsers(users);

    govtUsers.forEach((user) async {
      var entity = getEntity(user.govtEntity, govtEntities);
      if (entity != null) {
        var result =
            await _processEntityPurchaseOrders(entity, user, suppliers);
        if (result > 0) {
          print('Generator.generatePurchaseOrders )))))))))) ERROR ))))))))');
          return result;
        } else {
          print(
              'Generator.generatePurchaseOrders just processed an entitys PO - @@@@');
        }
      } else {
        print('Generator.generatePurchaseOrders Houston,  we have a problem.');
      }
    });

    print('\n\nGenerator.generatePurchaseOrders )))))))))))))) COMPLETED!\n\n');
    return 0;
  }

  static GovtEntity getEntity(String key, List<GovtEntity> list) {
    print('Generator.getEntity key: $key list: ${list.length}');
    GovtEntity ge;
    list.forEach((entity) {
      var xx = key.split("#").elementAt(1);
      if (xx == entity.participantId) {
        ge = entity;
      }
    });

    return ge;
  }

  static List<User> getGovtUsers(List<User> users) {
    List<User> m = List();
    users.forEach((user) {
      if (user.govtEntity != null) {
        m.add(user);
      }
    });
    return m;
  }

  static Future<int> _processEntityPurchaseOrders(
      GovtEntity entity, User user, List<Supplier> list) async {
    print(
        '\n\nGenerator._processEntityPurchaseOrders purchase order for GovtEntity:  ${entity.name}  user ${user.firstName} ${user.lastName}');
    list.forEach((supplier) async {
      await _addSupplierContract(entity, user, supplier);
      var result = await _addSupplierPurchaseOrders(entity, user, supplier);
      if (result > 0) {
        print('Generator._processEntityPurchaseOrders ERROR FOUND - quit');
        return result;
      }
    });
    return 0;
  }

  static Future<int> _addSupplierContract(
      GovtEntity entity, User user, Supplier supplier) async {
    print(
        '\n\nGenerator._addSupplierContract ......... for:  ${supplier.name} - documentRef: ${supplier.documentReference} \n\n');
    DateTime today = new DateTime.now();
    dataAPI = DataAPI(getURL());

    SupplierContract contract = SupplierContract(
      customerName: entity.name,
      supplierName: supplier.name,
      user: NameSpace + 'User#' + user.userId,
      supplier: NameSpace + 'Supplier#' + supplier.participantId,
      govtEntity: NameSpace + 'GovtEntity#' + entity.participantId,
      date: new DateTime.now().toIso8601String(),
      startDate: today.toIso8601String(),
      endDate: today.add(new Duration(days: 365)).toIso8601String(),
      estimatedValue: _getRandomContractValue(),
      description:
          'The best government contract ever agreed upon.  Lots of money to be made by  ${supplier.name}',
    );

    var key = await dataAPI.addSupplierContract(contract);
    if (key == '0') {
      return 9;
    }
    return 0;
  }

  static Future<int> _addSupplierPurchaseOrders(
      GovtEntity entity, User user, Supplier supplier) async {
    print(
        '\n\n\nGenerator._addSupplierContract for  Supplier:  ${supplier.name} ');
    DateTime today = new DateTime.now();
    dataAPI = DataAPI(getURL());

    PurchaseOrder po = PurchaseOrder();
    po.govtEntity = NameSpace + 'GovtEntity#' + entity.participantId;
    po.supplier = NameSpace + 'Supplier#' + supplier.participantId;
    po.user = NameSpace + 'User#' + user.userId;
    po.supplierName = supplier.name;
    po.reference = 'reference placeholder';
    po.amount = _getRandomAmount();
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.date = today.subtract(new Duration(days: 180)).toIso8601String();
    po.govtDocumentRef = entity.documentReference;
    po.supplierDocumentRef = supplier.documentReference;
    po.purchaserName = entity.name;

    var key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    //////
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.amount = _getRandomAmount();
    po.date = today.subtract(new Duration(days: 120)).toIso8601String();
    key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    ////////
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.amount = _getRandomAmount();
    po.date = today.subtract(new Duration(days: 90)).toIso8601String();
    key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    ////////
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.amount = _getRandomAmount();
    po.date = today.subtract(new Duration(days: 60)).toIso8601String();
    key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    //////
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.amount = _getRandomAmount();
    po.date = today.subtract(new Duration(days: 30)).toIso8601String();
    key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    /////
    po.purchaseOrderNumber = _getRandomPONumber(entity);
    po.amount = _getRandomAmount();
    po.date = today.toIso8601String();
    key = await dataAPI.registerPurchaseOrder(po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders purchase order done: $key');
    key = await _addDeliveryNote(entity, user, supplier, po);
    if (key == '0') {
      return 9;
    }
    print('Generator._addSupplierPurchaseOrders delivery note done: $key');
    print(
        '\n\nGenerator._addSupplierPurchaseOrders *********** COMPLETED for SUPPLIER ${supplier.name}');
    return 0;
  }

  static Future<String> _addDeliveryNote(
      GovtEntity entity, User user, Supplier supplier, PurchaseOrder po) async {
    prettyPrint(po.toJson(), 'Generator._addDeliveryNote for po');
    DeliveryNote dn = DeliveryNote();
    dn.user = NameSpace + 'User#' + user.userId;
    dn.date = po.date;
    dn.supplierName = supplier.name;
    dn.govtEntity = NameSpace + 'GovtEntity#' + entity.participantId;
    dn.supplier = NameSpace + 'Supplier#' + supplier.participantId;
    dn.purchaseOrder = NameSpace + 'PurchaseOrder#' + po.purchaseOrderId;
    dn.remarks = 'remarks placeholder';
    dn.supplierDocumentRef = supplier.documentReference;
    dn.govtDocumentRef = entity.documentReference;
    dn.supplierName = supplier.name;
    dn.customerName = entity.name;
    dn.purchaseOrderNumber = po.purchaseOrderNumber;

    var key = await dataAPI.registerDeliveryNote(dn);
    if (key == '0') {
      return key;
    }
    print('Generator._addDeliveryNote ******************** ${dn.toJson()}');
    prettyPrint(po.toJson(), 'Generator._addDeliveryNote note:');
    key = await _addInvoice(entity, supplier, user, po, dn);
    return key;
  }

  static Future<String> _addInvoice(GovtEntity entity, Supplier supplier,
      User user, PurchaseOrder po, DeliveryNote dn) async {
    double tax = po.amount * 0.15;
    var total = po.amount + tax;
    print(
        '\n\nGenerator._addInvoice for ${entity.name} from ${supplier.name} po: ${po.purchaseOrderNumber} \n\n');
    Invoice inv = Invoice();
    inv.govtEntity = NameSpace + 'GovtEntity#' + entity.participantId;
    inv.supplier = NameSpace + 'Supplier#' + supplier.participantId;
    inv.user = NameSpace + 'User#' + user.userId;
    inv.purchaseOrder = NameSpace + 'PurchaseOrder#' + po.purchaseOrderId;
    inv.deliveryNote = NameSpace + 'DeliveryNote#' + dn.deliveryNoteId;
    inv.amount = po.amount;
    inv.valueAddedTax = tax;
    inv.totalAmount = total;
    inv.date = po.date;
    inv.supplierName = supplier.name;
    inv.supplierDocumentRef = supplier.documentReference;
    inv.reference = 'reference placeholder';
    inv.invoiceNumber = _getRandomInvoiceNumber(supplier);
    inv.purchaseOrderNumber = po.purchaseOrderNumber;
    inv.customerName = entity.name;
    inv.isSettled = false;
    inv.isOnOffer = false;

    var key = await dataAPI.registerInvoice(inv);
    if (key == '0') {
      print('Generator._addInvoice ERROR bbad invoice?');
      return key;
    }
    prettyPrint(inv.toJson(), 'Generator._addInvoice');
    _addOffer(inv, user, po, supplier, entity);
    return key;
  }

  static Future<String> _addOffer(Invoice invoice, User user, PurchaseOrder po,
      Supplier supplier, GovtEntity entity) async {
    print(
        'Generator._addOffer invoice: ${invoice.invoiceNumber} --------------\n\n');
    double disc = _getRandomDiscount();
    var offerAmt = invoice.amount * (disc / 100);
    print(
        'Generator._addOffer \n\ninvoiceAmt: ${invoice.amount} discount: $disc offerAmt: $offerAmt \n\n');
    Offer offer = new Offer(
        supplier: NameSpace + 'Supplier#' + supplier.participantId,
        invoice: NameSpace + 'Invoice#' + invoice.invoiceId,
        user: NameSpace + 'User#' + user.userId,
        purchaseOrder: NameSpace + 'PurchaseOrder#' + po.purchaseOrderId,
        offerAmount: offerAmt,
        invoiceAmount: invoice.amount,
        supplierName: supplier.name,
        customerName: entity.name,
        discountPercent: disc,
        startTime: new DateTime.now().toIso8601String(),
        endTime: new DateTime.now()
            .add(new Duration(days: _getRandomOfferDays()))
            .toIso8601String(),
        date: new DateTime.now().toIso8601String(),
        participantId: supplier.participantId,
        privateSectorType: supplier.privateSectorType);

    var key = await dataAPI.makeOffer(offer);
    prettyPrint(offer.toJson(), 'Generator._addOffer: ');
    return key;
  }

  static List<Investor> investors = List();
  // ignore: missing_return
  static Future<int> generateBids() async {
    print('\n\nGenerator.generateBids ################################# \n\n');
    dataAPI = new DataAPI(getURL());
    var qs0 = await _fs.collection('investors').getDocuments();

    qs0.documents.forEach((doc) {
      var inv = new Investor.fromJson(doc.data);
      inv.documentReference = doc.documentID;
      investors.add(inv);
    });
    doubles.add(1.2);
    doubles.add(1.3);
    doubles.add(1.4);
    doubles.add(1.5);
    doubles.add(1.6);
    doubles.add(1.25);
    doubles.add(1.35);
    doubles.add(1.15);
    doubles.add(1.28);

    var qs = await _fs.collection('invoiceOffers').getDocuments();
    print('Generator.generateBids qs: ${qs.documents.length} offers found ...');
    qs.documents.forEach((doc) async {
      var offer = new Offer.fromJson(doc.data);
      offer.documentReference = doc.documentID;
      offers.add(offer);
    });
    processInvestor1();
    print(
        '\n\n\nGenerator.generateBids generated bids for ${qs.documents.length} invoice offers ######### \n\n');
  }

  static List<Offer> offers = List();
  static int index = 0;
  static void processInvestor1() async {
    Investor inv1 = investors.elementAt(0);
    await _makeBid(offers.elementAt(index), inv1);
    index++;
    if (index == offers.length) {
      index = 0;
      processInvestor2();
      return;
    }
    processInvestor1();
  }

  static void processInvestor2() async {
    Investor inv1 = investors.elementAt(1);
    await _makeBid(offers.elementAt(index), inv1);
    index++;
    if (index == offers.length) {
      print(
          '\n\nGenerator.processInvestor2 ##################### DONE generating bids ##########\n\n\n');
      return;
    }
    processInvestor2();
  }

  static List<double> doubles = List();
  static Future<int> _makeBid(Offer offer, Investor inv) async {
    double offerDiscount = offer.discountPercent;
    int index = rand.nextInt(doubles.length - 1);
    double investorDiscount = offerDiscount * doubles.elementAt(index);
    double offerAmt = offer.offerAmount;
    double investorAmt = (offerAmt * (100.0 - investorDiscount)) / 100;
    print(
        'Generator._makeBid offerAmt  $offerAmt offerDiscount: $offerDiscount investorDiscount: $investorDiscount investorAmt: $investorAmt \n\n');

    InvoiceBid bid = new InvoiceBid(
      investor: NameSpace + 'Investor#' + inv.participantId,
      offer: NameSpace + 'Offer#' + offer.offerId,
      discountPercent: offer.discountPercent,
      reservePercent: '$investorDiscount',
      startTime: offer.startTime,
      endTime: offer.endTime,
      amount: investorAmt,
      participantId: inv.participantId,
    );

    var key = await dataAPI.makeInvoiceBid(bid, offer);
    if (key == '0') {
      return 1;
    } else {
      prettyPrint(bid.toJson(), 'Generator._makeBid');
      return 0;
    }
  }

  static String _getRandomPONumber(GovtEntity e) {
    var string =
        '${e.name.substring(0,0)}${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}-${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}';

    return string;
  }

  static String _getRandomInvoiceNumber(Supplier e) {
    var string =
        '${e.name.substring(0,0)}${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}-${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}${ rand.nextInt(9)}'
        '${ rand.nextInt(9)}';

    return string;
  }

  static String _getRandomContractValue() {
    var x = rand.nextInt(100);
    double amt = x * 100000.00;

    return amt.toStringAsFixed(2);
  }

  static double _getRandomAmount() {
    var x = rand.nextInt(1000);
    if (x == 0) {
      x = 339;
    }
    double amt = x * 1000.00;
    if (x > 80) {
      amt = amt * 10;
    }

    return amt;
  }

  static double _getRandomDiscount() {
    var x = rand.nextInt(80);
    if (x < 50) {
      x = 80;
    }
    double amt = x * 1.0;
    return amt;
  }

  static int _getRandomOfferDays() {
    var x = rand.nextInt(21);
    if (x < 5) {
      x = 14;
    }
    return x;
  }

  static Future<int> cleanUp() async {
    print('Generator.cleanUp ................ ########  ................');
    var fs = Firestore.instance;
    try {
      var qs0 = await fs.collection('users').getDocuments();
      qs0.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print('Generator.cleanUp users deleted from Firestore ################');
      var qs = await fs.collection('wallets').getDocuments();
      qs.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp wallets deleted from Firestore ################');
      var qsx = await fs.collection('walletsFailed').getDocuments();
      qsx.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp walletsFailed deleted from Firestore ################');
      var qs1 = await fs.collection('oneConnect').getDocuments();
      qs1.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp oneConnect deleted from Firestore ################');
      var qs2 = await fs.collection('govtEntities').getDocuments();
      qs2.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp govtEntities deleted from Firestore ################');
      var qs3 = await fs.collection('suppliers').getDocuments();
      qs3.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap4 =
            await doc.reference.collection('supplierContracts').getDocuments();
        msnap4.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp suppliers deleted from Firestore ##############');

      var qs5 = await fs.collection('investors').getDocuments();
      qs5.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp investors deleted from Firestore ######################');
      var qs6 = await fs.collection('procurementOffices').getDocuments();
      qs6.documents.forEach((doc) async {
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp investors deleted from Firestore ######################');
      var qs7 = await fs.collection('companies').getDocuments();
      qs7.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp companies deleted from Firestore ###############');
      var qs8 = await fs.collection('banks').getDocuments();
      qs8.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print('Generator.cleanUp banks deleted from Firestore ##############');
      var qs9 = await fs.collection('procurementOffices').getDocuments();
      qs9.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print(
          'Generator.cleanUp procurementOffices deleted from Firestore   #############');
      var qs10 = await fs.collection('auditors').getDocuments();
      qs10.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('purchaseOrders').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap2 =
            await doc.reference.collection('deliveryNotes').getDocuments();
        msnap2.documents.forEach((x) async {
          await x.reference.delete();
        });
        var msnap3 = await doc.reference.collection('invoices').getDocuments();
        msnap3.documents.forEach((x) async {
          await x.reference.delete();
        });
        await doc.reference.delete();
      });
      print('Generator.cleanUp auditors deleted from Firestore ##############');
      var qs11 = await fs.collection('invoiceOffers').getDocuments();
      qs11.documents.forEach((doc) async {
        var msnap =
            await doc.reference.collection('invoiceBids').getDocuments();
        msnap.documents.forEach((x) async {
          await x.reference.delete();
        });

        await doc.reference.delete();
      });

      await StorageAPI.deleteFolder('contracts');

      print(
          'Generator.cleanUp invoiceOffers and invoiceBids deleted from Firestore and FirebaseStorage ##############');
    } catch (e) {
      print('Generator.cleanUp ERROR $e');
      return 1;
    }
    print('Generator.cleanUp COMPLETED........... start the real work!!');
    return 0;
  }

  static Future<int> generateEntities() async {
    print('Generator.generateEntities ......................');
    SignUp signUp = SignUp(getURL());
    try {
      GovtEntity e1 = new GovtEntity(
        name: 'Dept of Home Affairs',
        email: 'info@water.gov.za',
        country: 'South Africa',
        govtEntityType: 'NATIONAL',
      );
      User u1 = new User(
          firstName: 'Thabo',
          lastName: 'Nkosi',
          password: 'pass123',
          email: 'thabo.nkosi@water.gov.za');
      int key = await signUp.signUpGovtEntity(e1, u1);
      if (key > 0) {
        return key;
      }

      GovtEntity e2 = new GovtEntity(
        name: 'Dept of Public Works',
        email: 'info@publicworks.gov.za',
        country: 'South Africa',
        govtEntityType: 'NATIONAL',
      );
      User u2 = new User(
          firstName: 'Ntombi',
          lastName: 'Mathebula',
          password: 'pass123',
          email: 'ntombi.m@publicworks.gov.za');
      key = await signUp.signUpGovtEntity(e2, u2);
      if (key > 0) {
        return key;
      }

      print('Generator.generateEntities ########################## COMPLETED');
    } catch (e) {
      print('Generator.generateEntities ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateSuppliers() async {
    print('Generator.generateSuppliers ............');
    SignUp signUp = SignUp(getURL());
    try {
      Supplier e1 = new Supplier(
        name: 'Mkhize Electrical',
        email: 'info@mkhize.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u1 = new User(
          firstName: 'David',
          lastName: 'Mkhize',
          password: 'pass123',
          email: 'dmkhize@mkhize.com');
      await signUp.signUpSupplier(e1, u1);

      Supplier e2 = new Supplier(
        name: 'Dlamini Contractors',
        email: 'info@dlamini.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u2 = new User(
          firstName: 'Moses',
          lastName: 'Dlamini',
          password: 'pass123',
          email: 'ddlam@dlamini.com');
      await signUp.signUpSupplier(e2, u2);

      Supplier e3 = new Supplier(
        name: 'Frannie Event Management',
        email: 'info@femevent.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u3 = new User(
          firstName: 'Moses',
          lastName: 'Dlamini',
          password: 'pass123',
          email: 'mosesd@femevent.com');
      await signUp.signUpSupplier(e3, u3);

      Supplier e4 = new Supplier(
        name: 'Soweto Social Management',
        email: 'info@femevent.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u4 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'pass123',
          email: 'dkhoza@femevent.com');
      await signUp.signUpSupplier(e4, u4);

      Supplier e5 = new Supplier(
        name: 'TrebleX Engineering',
        email: 'info@engineers.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u5 = new User(
          firstName: 'Daniel',
          lastName: 'Khoza',
          password: 'pass123',
          email: 'danielkk@engineers.com');
      await signUp.signUpSupplier(e5, u5);

      Supplier e6 = new Supplier(
        name: 'DHH Transport Logistics',
        email: 'info@dhhtransport.com',
        country: 'South Africa',
        privateSectorType: 'Engineering',
      );
      User u6 = new User(
          firstName: 'Peter',
          lastName: 'Johnson',
          password: 'pass123',
          email: 'petejohn@dhhtransport.com');
      await signUp.signUpSupplier(e6, u6);

      Supplier e7 = new Supplier(
        name: 'Zamas Logistics',
        email: 'info@zamatransport.com',
        country: 'South Africa',
        privateSectorType: 'Industrial',
      );
      User u7 = new User(
          firstName: 'Susan',
          lastName: 'Oakley-Smith',
          password: 'pass123',
          email: 'susanoak@zamatransport.com');
      await signUp.signUpSupplier(e7, u7);
      print('Generator.generateSuppliers COMPLETED');
    } catch (e) {
      print('Generator.generateSuppliers ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateInvestors() async {
    print('Generator.generateInvestors ......................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      Investor e1 = new Investor(
          name: 'FinanceCapital Pty Ltd',
          email: 'info@fincap.com',
          country: 'South Africa',
          cellphone: '086 789 4534');
      User u1 = new User(
          firstName: 'Robert',
          lastName: 'van der Merwe',
          password: 'pass123',
          email: 'robert.vdm@fincap.com');
      await signUp.signUpInvestor(e1, u1);

      Investor e2 = new Investor(
        name: 'Invoice Brokers Pty Ltd',
        email: 'info@invbrokers.co.za',
        country: 'South Africa',
        cellphone: '073  456 7899',
      );
      User u2 = new User(
          firstName: 'Rogers',
          lastName: 'Smith-Kline',
          password: 'pass123',
          email: 'rogers.m@invbrokers.co.za');
      await signUp.signUpInvestor(e2, u2);
      print('Generator.generateInvestors COMPLETED');
    } catch (e) {
      print('Generator.generateInvestors ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateProcurementOffice() async {
    print('Generator.generateProcurementOffice ......................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      ProcurementOffice e1 = new ProcurementOffice(
          name: 'Treasury Procurement Office',
          email: 'info@treasury.gov.za',
          country: 'South Africa',
          cellphone: '086 789 4534');
      User u1 = new User(
          firstName: 'Thamsanqa',
          lastName: 'Maluleke',
          password: 'pass123',
          email: 'thami.mal@treasury.gov.za');
      await signUp.signUpProcurementOffice(e1, u1);
      print('Generator.generateProcurementOffice COMPLETED');
    } catch (e) {
      print('Generator.generateProcurementOffice ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateBank() async {
    print('Generator.generateBank ......................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      Bank e1 = new Bank(
          name: 'Number One Bank',
          email: 'info@bankone.com',
          country: 'South Africa',
          cellphone: '081 555 4534');
      User u1 = new User(
          firstName: 'Maryanne',
          lastName: 'Poppins',
          password: 'pass123',
          email: 'marypopl@bankone.com');
      await signUp.signUpBank(e1, u1);
      print('Generator.generateBank COMPLETED');
    } catch (e) {
      print('Generator.generateBank ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateAuditor() async {
    print('Generator.generateAuditor ......................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      Auditor e1 = new Auditor(
          name: 'Great Auditors Inc.',
          email: 'info@auditors.com',
          country: 'South Africa',
          cellphone: '081 555 7745');
      User u1 = new User(
          firstName: 'Johan',
          lastName: 'de Klerk',
          password: 'pass123',
          email: 'johanl@auditors.com');
      await signUp.signUpAuditor(e1, u1);
      print('Generator.generateAuditor COMPLETED');
    } catch (e) {
      print('Generator.generateAuditor ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateCompanies() async {
    print('Generator.generateCompanies ......................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      Company e1 = new Company(
          name: 'The Successful Company',
          email: 'info@success.co.za',
          country: 'South Africa',
          privateSectorType: 'Industrial',
          cellphone: '098 687 5544');
      User u1 = new User(
          firstName: 'Lesego',
          lastName: 'Grootboom',
          password: 'pass123',
          email: 'lesgo@success.co.za');
      await signUp.signUpCompany(e1, u1);

      Company e2 = new Company(
          name: 'Group Seven Construction',
          email: 'info@group7.com',
          country: 'South Africa',
          privateSectorType: 'Construction',
          cellphone: '097 667 5655');
      User u2 = new User(
          firstName: 'James',
          lastName: 'Beach',
          password: 'pass123',
          email: 'jamesb@group7.com');
      await signUp.signUpCompany(e2, u2);
      print('Generator.generateCompanies COMPLETED');
    } catch (e) {
      print('Generator.generateCompanies ERROR $e');
      return 1;
    }

    return 0;
  }

  static Future<int> generateOneConnect() async {
    print('Generator.generateOneConnect .....................\n\n');
    SignUp signUp = SignUp(getURL());
    try {
      OneConnect e1 = new OneConnect(
          name: 'OneConnect Business Finance',
          email: 'info@oneconnect.co.za',
          country: 'South Africa',
          cellphone: '081 333 4534');
      User u1 = new User(
          firstName: 'Mpho',
          lastName: 'Khunou',
          password: 'pass123',
          email: 'mpho@oneconnect.co.za');
      await signUp.signUpOneConnect(e1, u1);
      print('Generator.generateOneConnect COMPLETED');
    } catch (e) {
      print('Generator.generateOneConnect ERROR $e');
      return 1;
    }

    return 0;
  }
}
