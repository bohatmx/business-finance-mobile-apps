import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/auto_trade_order.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/investor_profile.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class GenListener {
  onEvent(String message, bool isRecordAdded);
  onPhaseComplete();
  onError(String message);
  onResetCounter();
}

class Generator {
  static List<Customer> customers;
  static List<Supplier> suppliers;
  static List<Unit> units = List();
  static int index = 0;
  static Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static List<Future> futures = List();
  static List<Sector> sectors = List();
  static List<User> users = List();
  static List<Investor> investors = List();
  static List<AutoTradeOrder> autoTradeOrders = List();
  static List<InvestorProfile> profiles = List();
  static DateTime start;
  static GenListener genListener;
  static BuildContext context;

  static Future generateOffers(GenListener listener, BuildContext ctx) async {
    listener.onEvent('### Starting Offer Generation ###', false);
    listener.onEvent(
        '## Checking if accepted invoices need offers generated ...', false);
    suppliers = await ListAPI.getSuppliers();
    sectors = await ListAPI.getSectors();
    genListener = listener;
    context = ctx;
    index = 0;
    offers = List();
    var cntAlready = 0, cnt = 0;
    print(
        '\n\n\n😡 😡 😡 😡 😡 😡 😡 😡 Generator.generateOffers ++++++++++++ execute for ${suppliers.length} suppliers');
    for (var supplier in suppliers) {
      invoices = await ListAPI.getInvoicesBySupplier(supplier.participantId);
      invoiceAcceptances =
          await ListAPI.getInvoiceAcceptancesBySupplier(supplier.participantId);
      print(
          '\n\n😡 😡 😡 😡  Generator.generateOffers: supplier: ${supplier.name} has ${invoices.length} invoices');
      listener.onEvent(
          '😡 😡 😡 😡 Generating offers for ${supplier.name}', false);
      for (var invoice in invoices) {
        if (invoice.isOnOffer == true) {
          cntAlready++;
          print(
              'Generator.generateOffers invoice ${invoice.invoiceNumber} already on offer: #$cntAlready');
        } else {
          InvoiceAcceptance acceptance;
          invoiceAcceptances.forEach((acc) {
            if (acc.invoice == invoice.invoiceId) {
              acceptance = acc;
            }
          });
          await _makeOffer(invoice: invoice, acceptance: acceptance);
          cnt++;
          print(
              'Generator.generateOffers offer made for ${invoice.invoiceNumber}, offer #$cnt');
        }
      }
      listener.onEvent('Completed offers for ${supplier.name}', false);
    }
    listener.onResetCounter();
    print(
        '\n\nGenerator.generateOffers made ${offers.length} offers in session');
    listener.onEvent('Done! made ${offers.length} offers in session', false);
  }

  static Future generateTemporaryProfiles(
      GenListener listener, BuildContext ctx) async {
    Firestore fs = Firestore.instance;
    genListener = listener;
    context = ctx;
    genListener.onEvent('🔵 🔵 🔵   - generateProfiles...', false);
    profiles = List();
    autoTradeOrders = List();
    investors = await ListAPI.getInvestors();
    for (var investor in investors) {
      var profile = InvestorProfile(
        email: investor.email,
        name: investor.name,
        investor: investor.participantId,
        maxInvestableAmount: _getRandomMaxInvestable(),
        minimumDiscount: _getRandomMinimumDisc(),
        maxInvoiceAmount: _getRandomMaxInvoice(),
        profileId: new DateTime.now().toIso8601String() +
            '@' +
            rand.nextInt(1000).toString(),
        cellphone: investor.cellphone,
        date: getUTCDate(),
      );
      await fs
          .collection('investorProfiles')
          .document(profile.profileId)
          .setData(profile.toJson());
      profiles.add(profile);
    }
    genListener.onEvent(
        '❤️ ❤️ ❤️  - profiles generated: ${profiles.length}', false);
    genListener.onPhaseComplete();
    genListener.onEvent('🔵 🔵 🔵   - generate AutoTradeOrders...', false);
    for (var p in profiles) {
      var order = new AutoTradeOrder(
          investor: p.investor,
          investorName: p.name,
          investorProfile: p.profileId,
          isCancelled: false,
          date: getUTCDate(),
          autoTradeOrderId: new DateTime.now().toIso8601String() +
              '@' +
              rand.nextInt(1000).toString());

      await fs
          .collection('autoTradeOrders')
          .document(order.autoTradeOrderId)
          .setData(order.toJson());
      autoTradeOrders.add(order);
    }
    genListener.onEvent(
        '❤️ ❤️ ❤️  - autoTradeOrders generated: ${autoTradeOrders.length}',
        false);
    genListener.onPhaseComplete();
  }

  static Future reallyFinishItOff(
      GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    genListener.onEvent('🔵 🔵 🔵   - finishItOff make offers...', false);
    sectors = await ListAPI.getSectors();
    genListener.onEvent(
        '🔵 🔵 🔵   - sectors to work with: ${sectors.length}', false);

    invoices = await ListAPI.getAllInvoices();
    genListener.onEvent(
        '🔵 🔵 🔵   - invoices to work with: ${invoices.length}', false);

    invoiceAcceptances = await ListAPI.getAllInvoiceAcceptances();
    genListener.onEvent(
        '🔵 🔵 🔵   - invoiceAcceptances to work with: ${invoiceAcceptances.length}',
        false);

    for (var invoice in invoices) {
      InvoiceAcceptance acceptance;
      invoiceAcceptances.forEach((s) {
        if (s.invoice == invoice.invoiceId) {
          acceptance = s;
        }
      });
      if (acceptance != null) {
        await _makeOffer(invoice: invoice, acceptance: acceptance);
      } else {
        print('\n\n👿 👿 👿 👿 👿 👿 acceptance not found for invoice');
      }
    }

    genListener.onEvent(
        '❤️  ❤️  ❤️ - offers generated: ${offers.length}', false);
    genListener.onPhaseComplete();
  }

  static Future finishItOff(GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    genListener.onEvent('🔵 🔵 🔵   - finishItOff accept invoices ...', false);
    invoices = await ListAPI.getAllInvoices();
    genListener.onEvent(
        '🔵 🔵 🔵   - invoices to work with: ${invoices.length}', false);
    for (var inv in invoices) {
      await _acceptInvoice(inv);
    }
    genListener.onEvent(
        '💦 💦 💦 💦  - invoiceAcceptances generated: ${invoiceAcceptances.length}',
        false);
    genListener.onPhaseComplete();

    for (var invoice in invoices) {
      InvoiceAcceptance acceptance;
      invoiceAcceptances.forEach((s) {
        if (s.invoice == invoice.invoiceId) {
          acceptance = s;
        }
      });
      if (acceptance != null) {
        await _makeOffer(invoice: invoice, acceptance: acceptance);
      } else {
        print('\n\n👿 👿 👿 👿 👿 👿 acceptance not found for invoice');
      }
    }

    genListener.onEvent(
        '❤️  ❤️  ❤️ - offers generated: ${offers.length}', false);
    genListener.onPhaseComplete();
  }

  static Future doTheRest(GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    genListener.onEvent('🔵 🔵 🔵   - doing the rest ....', false);
    deliveryNotes = await ListAPI.getAllDeliveryNotes();
    genListener.onEvent(
        '☕️  ☕️  - deliveryNotes found: ${deliveryNotes.length}', false);
    for (var note in deliveryNotes) {
      await _acceptDeliveryNote(note);
    }
    genListener.onEvent(
        '☕️  ☕️️  - deliveryAcceptances generated: ${deliveryAcceptances.length}',
        false);
    for (var acc in deliveryAcceptances) {
      var note;
      deliveryNotes.forEach((n) {
        if (n.deliveryNoteId == acc.deliveryNote) {
          note = n;
        }
      });
      await _registerInvoice(acc, note);
    }

    genListener.onEvent(
        '😡 😡 😡 😡 - invoices generated: ${invoices.length}', false);
    genListener.onPhaseComplete();

    for (var inv in invoices) {
      await _acceptInvoice(inv);
    }
    genListener.onEvent(
        '💦 💦 💦 💦  - invoiceAcceptances generated: ${invoiceAcceptances.length}',
        false);
    genListener.onPhaseComplete();

    for (var inv in invoices) {
      InvoiceAcceptance acceptance;
      invoiceAcceptances.forEach((s) {
        if (s.invoice == inv.invoiceId) {
          acceptance = s;
        }
      });
      //
      await _makeOffer(invoice: inv, acceptance: acceptance);
    }

    genListener.onEvent(
        '❤️  ❤️  ❤️ - offers generated: ${offers.length}', false);
    genListener.onPhaseComplete();
  }

  static Future generate(GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    print(
        '\n\n 🔵   🔵   🔵   🔵   🔵  Generator.generate business trades starting ...\n\n');
    genListener.onEvent('🔵  🔵  🔵  🔵  🔵 loading data ....', false);
    start = DateTime.now();
    customers = await ListAPI.getCustomersByCountry(country: 'ZA');
    genListener.onEvent('💦  💦  💦 ${customers.length} customers', false);

    suppliers = await ListAPI.getSuppliers();
    genListener.onEvent('💦  💦  💦 ${suppliers.length} suppliers', false);

    sectors = await ListAPI.getSectors();
    genListener.onEvent('💦  💦  💦 ${sectors.length} sectors', false);

    users = await ListAPI.getUsers();
    units = List();

    customers.forEach((customer) {
      suppliers.forEach((supplier) {
        units.add(Unit(customer, supplier));
      });
    });
    print(
        '\n\n💦  💦  💦  Generator: number of units:   🔵  🔵 ${units.length} to process\n\n');
    genListener.onEvent(
        '💦  💦  units to process: ${units.length}  🔵 🔵 ', false);

    deliveryNotes = List();
    deliveryAcceptances = List();
    invoices = List();
    offers = List();
    index = 0;
    await _startDancing();
    genListener.onEvent('💦  💦  💦   ', false);
    genListener.onEvent(
        '☕️  ☕️  - purchaseOrders found: ${purchaseOrders.length}', false);
    genListener.onEvent(
        '☕️  ☕️  - deliveryNotes generated: ${deliveryNotes.length}', false);
    genListener.onEvent(
        '☕️  ☕️️  - deliveryAcceptances generated: ${deliveryAcceptances.length}',
        false);
    genListener.onEvent(
        '☕️  ☕️  - invoices generated: ${invoices.length}', false);
    genListener.onEvent(
        '☕️  ☕️  - invoiceAcceptances generated: ${invoiceAcceptances.length}',
        false);
    genListener.onEvent('☕️  ☕️  - offers generated: ${offers.length}', false);

    genListener.onEvent('🔵 🔵️ 🔵 🔵️ - JOB COMPLETE!', false);
  }

  static Future _startDancing() async {
    for (var unit in units) {
      await _generatePurchaseOrder(unit.supplier, unit.customer);
    }
    print(
        '\n\n☕️  ☕️  ☕️  ☕️  Generator.control - purchaseOrders generated: ${purchaseOrders.length}\n\n');
    genListener.onEvent(
        '☕️  ☕️  ☕️  ☕️  - purchaseOrders generated: ${purchaseOrders.length}',
        false);
    genListener.onPhaseComplete();

    for (var po in purchaseOrders) {
      await _generateDeliveryNote(po);
    }
    print(
        '\n\n☕️  ☕️  ☕️  ☕️  - delivery notes generated: ${purchaseOrders.length}');
    genListener.onEvent(
        '☕️  ☕️  ☕️  ☕️  - delivery notes generated: ${purchaseOrders.length}',
        false);
    genListener.onPhaseComplete();

    for (var note in deliveryNotes) {
      await _acceptDeliveryNote(note);
    }
    genListener.onEvent(
        '🔵 🔵 🔵  - delivery notes accepted: ${deliveryNotes.length}', false);
    genListener.onPhaseComplete();

    for (var acc in deliveryAcceptances) {
      var note;
      deliveryNotes.forEach((n) {
        if (n.deliveryNoteId == acc.deliveryNote) {
          note = n;
        }
      });
      await _registerInvoice(acc, note);
    }

    genListener.onEvent(
        '😡 😡 😡 😡 - invoices generated: ${invoices.length}', false);
    genListener.onPhaseComplete();

    for (var inv in invoices) {
      await _acceptInvoice(inv);
    }
    genListener.onEvent(
        '💦 💦 💦 💦  - invoiceAcceptances generated: ${invoiceAcceptances.length}',
        false);
    genListener.onPhaseComplete();

    for (var inv in invoices) {
      InvoiceAcceptance acceptance;
      invoiceAcceptances.forEach((s) {
        if (s.invoice == inv.invoiceId) {
          acceptance = s;
        }
      });
      //
      await _makeOffer(invoice: inv, acceptance: acceptance);
    }

    genListener.onEvent(
        '❤️  ❤️  ❤️ - offers generated: ${offers.length}', false);
    genListener.onPhaseComplete();
  }

  static List<PurchaseOrder> purchaseOrders = List();
  static List<DeliveryNote> deliveryNotes = List();
  static List<DeliveryAcceptance> deliveryAcceptances = List();
  static List<Invoice> invoices = List();
  static List<InvoiceAcceptance> invoiceAcceptances = List();
  static List<Offer> offers = List();

  static Future _generatePurchaseOrder(
      Supplier supplier, Customer customer) async {
//    var user = users.elementAt(rand.nextInt(users.length - 1));
//    assert(user != null);
    var po = PurchaseOrder(
      purchaseOrderNumber: _getRandomPO(),
      supplier: supplier.participantId,
      customer: customer.participantId,
      amount: _getRandomPOAmount(),
      description: 'Generated Demo Purchase Order',
      supplierName: supplier.name,
      purchaserName: customer.name,
    );

    try {
      var pOrder = await DataAPI3.addPurchaseOrder(po);
      purchaseOrders.add(pOrder);
      genListener.onEvent(
          '✅ ✅ ✅ Purchase order added: ${getFormattedAmount('${po.amount}', context)} : ${po.purchaserName} to ${po.supplierName} ',
          true);
      return pOrder;
    } catch (e) {
      genListener.onError(e.toString());
      throw e;
    }
  }

  static Future _generateDeliveryNote(PurchaseOrder po) async {
//    var user = users.elementAt(rand.nextInt(users.length - 1));
//    assert(user != null);
    var note = DeliveryNote(
        supplierName: po.supplierName,
        amount: po.amount,
        purchaseOrderNumber: po.purchaseOrderNumber,
        purchaseOrder: po.purchaseOrderId,
        vat: po.amount * 0.15,
        supplier: po.supplier,
        customerName: po.purchaserName,
        totalAmount: po.amount * 1.15,
        customer: po.customer);
    try {
      var resultNote = await DataAPI3.addDeliveryNote(note);
      deliveryNotes.add(resultNote);
      genListener.onEvent(
          '☕️  ☕️  ☕️  ☕️ Delivery Note added: ${getFormattedAmount('${note.totalAmount}', context)} : ${po.purchaserName} to ${po.supplierName} - ${resultNote.deliveryNoteId}',
          true);
    } catch (e) {
      genListener.onError(e.toString());
      throw e;
    }
  }

  static Future _acceptDeliveryNote(DeliveryNote note) async {
//    var user = users.elementAt(rand.nextInt(users.length - 1));
//    assert(user != null);
    var acc = DeliveryAcceptance(
      customer: note.customer,
      customerName: note.customerName,
      supplier: note.supplier,
      purchaseOrder: note.purchaseOrder,
      purchaseOrderNumber: note.purchaseOrderNumber,
      deliveryNote: note.deliveryNoteId,
    );
    try {
      var aa = await DataAPI3.acceptDelivery(acc);
      deliveryAcceptances.add(aa);
      genListener.onEvent(
          '💦 💦  DeliveryAcceptance added: ${note.customerName} to ${note.supplierName} ',
          true);
    } catch (e) {
      genListener.onError(e.toString());
      throw e;
    }
  }

  static Future _registerInvoice(
      DeliveryAcceptance deliveryAcceptance, DeliveryNote note) async {
    var invoice = Invoice(
      invoiceNumber: _getRandomInvoiceNumber(),
      customer: deliveryAcceptance.customer,
      supplier: deliveryAcceptance.supplier,
      purchaseOrder: deliveryAcceptance.purchaseOrder,
      deliveryNote: deliveryAcceptance.deliveryNote,
      supplierName: note.supplierName,
      customerName: deliveryAcceptance.customerName,
      purchaseOrderNumber: deliveryAcceptance.purchaseOrderNumber,
      amount: note.amount,
      valueAddedTax: note.vat,
      totalAmount: note.totalAmount,
      isOnOffer: false,
      isSettled: false,
      deliveryAcceptance: deliveryAcceptance.acceptanceId,
    );
    try {
      var i = await DataAPI3.registerInvoice(invoice);
      invoices.add(i);
      genListener.onEvent(
          '🔵 🔵  Invoice added: ${invoice.invoiceNumber} - ${getFormattedAmount('${invoice.totalAmount}', context)} ${note.customerName} to ${note.supplierName} ',
          true);
    } catch (e) {
      genListener.onError(e.toString());
      throw e;
    }
  }

  static Future _acceptInvoice(Invoice invoice) async {
//    var user = users.elementAt(rand.nextInt(users.length - 1));
//    assert(user != null);
//    assert(deliveryAcceptance.govtDocumentRef != null);
    var acceptance = InvoiceAcceptance(
        customerName: invoice.customerName,
        customer: invoice.customer,
        invoice: invoice.invoiceId,
        invoiceNumber: invoice.invoiceNumber,
        supplier: invoice.supplier,
        supplierName: invoice.supplierName);
    try {
      var i = await DataAPI3.acceptInvoice(acceptance);
      invoiceAcceptances.add(i);
      genListener.onEvent(
          '🔵 🔵  Invoice Acceptance added: ${acceptance.invoiceNumber} -  ${invoice.customerName} to ${invoice.supplierName} ',
          true);
    } catch (e) {
      genListener.onError(e.toString());
      throw e;
    }
  }

  static Future _makeOffer(
      {Invoice invoice, InvoiceAcceptance acceptance}) async {
    double disc = getRandomDisc();
    var sector = sectors.elementAt(rand.nextInt(sectors.length - 1));

    assert(sector != null);
    //var token = await _fcm.getToken();
    Offer offer = new Offer(
        supplier: invoice.supplier,
        invoice: invoice.invoiceId,
        purchaseOrder: invoice.purchaseOrder,
        offerAmount: invoice.amount * ((100 - disc) / 100),
        invoiceAmount: invoice.totalAmount,
        discountPercent: disc,
        startTime: getUTCDate(),
        endTime: _getRandomEndDate(),
        participantId: invoice.supplier,
        customerName: invoice.customerName,
        supplierName: invoice.supplierName,
        sectorName: sector.sectorName,
        customer: invoice.customer,
        sector: sector.sectorId,
        invoiceAcceptance: acceptance.acceptanceId);
    try {
      var off = await DataAPI3.makeOffer(offer);
      offers.add(off);
      genListener.onEvent(
          '💙 💙 💙 💙 Offer: ${invoice.supplierName} for: ${getFormattedAmount('${offer.offerAmount}', context)} discount: ${offer.discountPercent}%',
          true);
    } catch (e) {
      print(e);
      genListener.onError('👿 👿 👿 ' + e.toString());
    }
  }

  static String _getRandomEndDate() {
    int days = rand.nextInt(20);
    if (days < 10) {
      days = 10;
    }
    var date = DateTime.now().add(Duration(days: days));
    return getUTC(date);
  }

  static double getRandomDisc() {
    const discounts = [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      1.0,
      2.0,
      3.0,
      7.0,
      8.0,
      4.0,
      5.0,
      9.0,
      2.0,
      1.0,
      3.0,
      4.0,
      10.0,
      4.0,
      11.0,
      1.0,
      2.0,
      5.0,
      3.0,
      12.0
    ];
    return discounts[rand.nextInt(discounts.length - 1)];
  }

  static double _getRandomMinimumDisc() {
    const discounts = [
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      1.0,
      2.0,
      3.0,
      8.0,
      4.0,
      5.0,
      9.0,
      2.0,
      1.0,
      3.0,
      4.0,
      4.0,
      1.0,
      2.0,
      5.0,
      3.0,
    ];
    return discounts[rand.nextInt(discounts.length - 1)];
  }

  static String _getRandomPO() {
    var po =
        'PO-${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}';
    po += '-${rand.nextInt(9)}${rand.nextInt(9)}';
    return po;
  }

  static String _getRandomInvoiceNumber() {
    var po =
        'INV-${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}${rand.nextInt(9)}';
    po += '-${rand.nextInt(9)}${rand.nextInt(9)}';
    return po;
  }

  static double _getRandomPOAmount() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(100) * 6950.00;
    } else {
      seed = rand.nextInt(100) * 765.00;
    }
    if (seed == 0.0) {
      seed = 100000.00;
    }
    return seed;
  }

  static double _getRandomMaxInvestable() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(100) * 695000.00;
    } else {
      seed = rand.nextInt(100) * 76500.00;
    }
    if (seed == 0.0) {
      seed = 5000000.00;
    }
    return seed;
  }

  static double _getRandomMaxInvoice() {
    var m = rand.nextInt(1000);
    double seed = 0.0;
    if (m > 700) {
      seed = rand.nextInt(1000) * 695.00;
    } else {
      seed = rand.nextInt(1000) * 765.00;
    }
    if (seed == 0.0) {
      seed = 500000.00;
    }
    return seed;
  }

  /////////////
  static List<AutoTradeOrder> orders;
  static Future generateProfilesAndOrders(
      GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    print(
        '\n\n 🔵   🔵   🔵   🔵   🔵  Generator.generateProfilesAndOrders starting ...\n\n');
    genListener.onEvent('🔵  🔵  🔵  🔵  🔵 loading data ....', false);
    start = DateTime.now();
    investors = await ListAPI.getInvestors();
    genListener.onEvent('🔵  🔵  🔵  ${investors.length} investors', false);

    for (var investor in investors) {
      await _generateProfile(investor);
    }
    genListener.onEvent('☕️  ☕️  ☕️  ${profiles.length} profiles added', false);
    genListener.onPhaseComplete();

    for (var profile in profiles) {
      await _generateAutoTradeOrder(profile);
    }
    genListener.onEvent(
        '❤️ ❤️ ❤️ ${orders.length} autoTradeOrders added', false);
    genListener.onPhaseComplete();
  }

  static _generateAutoTradeOrder(InvestorProfile profile) async {
    AutoTradeOrder autoTradeOrder = AutoTradeOrder(
        investor: profile.investor,
        investorProfile: profile.profileId,
        isCancelled: false,
        investorName: profile.name);

    try {
      var order = await DataAPI3.addAutoTradeOrder(autoTradeOrder);
      genListener.onEvent('💕 💕 AutoTradeOrder added: ${profile.name}', true);
      orders.add(order);
    } catch (e) {
      genListener.onError('👿 👿 👿 $e');
    }
  }

  static _generateProfile(Investor investor) async {
    InvestorProfile ip = InvestorProfile(
        investor: investor.participantId,
        name: investor.name,
        email: investor.email,
        minimumDiscount: _getRandomMinimumDisc(),
        maxInvestableAmount: _getRandomMaxInvestable(),
        maxInvoiceAmount: _getRandomMaxInvoice());

    try {
      var mResponse = await DataAPI3.addInvestorProfile(ip);
      profiles.add(mResponse);
      genListener.onEvent('💙  💚  💛 Profile added', true);
    } catch (e) {
      genListener.onError('👿 👿 👿 $e');
    }
  }
}

class Unit {
  Customer customer;
  Supplier supplier;

  Unit(this.customer, this.supplier);
}
