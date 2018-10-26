import 'dart:io';
import 'dart:math';

import 'package:businesslibrary/api/data_api3.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/offer.dart';
import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class GenListener {
  onEvent(String message);
  onPhaseComplete();
}

class Generator {
  static List<GovtEntity> customers;
  static List<Supplier> suppliers;
  static List<Unit> units = List();
  static int index = 0;
  static const nameSpace = 'resource:com.oneconnect.biz.';
  static Random rand = Random(DateTime.now().millisecondsSinceEpoch);
  static List<Future> futures = List();
  static List<Sector> sectors = List();
  static List<User> users = List();
  static DateTime start;
  static GenListener genListener;
  static BuildContext context;

  static Future fixEndDates() async {
    offers = await ListAPI.getOpenOffers();
    Firestore firestore = Firestore.instance;
    for (var offer in offers) {
      offer.endTime = _getRandomEndDate();
      await firestore
          .collection('invoiceOffers')
          .document(offer.documentReference)
          .setData(offer.toJson());
      print(
          'Generator.fixEndDates ... updated end time: ${offer.endTime} : ${offer.offerAmount}');
    }
  }

  static Future generateOffers(GenListener listener, BuildContext ctx) async {
    listener.onEvent('## Making mass offers ...');
    suppliers = await ListAPI.getSuppliers();
    sectors = await ListAPI.getSectors();
    genListener = listener;
    context = ctx;

    for (var supplier in suppliers) {
      invoices =
          await ListAPI.getInvoices(supplier.documentReference, 'suppliers');
      for (var invoice in invoices) {
        if (!invoice.isOnOffer) {
          await _makeOffer(invoice, supplier);
        }
      }
    }
    print('Generator.generateOffers made ${offers.length} offers in session');
    listener.onEvent('Done! made ${offers.length} offers in session');
  }

  static Future generate(GenListener listener, BuildContext ctx) async {
    genListener = listener;
    context = ctx;
    print(
        '\n\nGenerator.generate ############ generate business trades starting ...\n\n');
    genListener.onEvent(
        'Data Generation Starting .... loading customers, suppliers, sectors and users ....');
    start = DateTime.now();
    customers = await ListAPI.getGovtEntitiesByCountry('South Africa');
    suppliers = await ListAPI.getSuppliers();
    sectors = await ListAPI.getSectors();
    users = await ListAPI.getUsers();

    customers.forEach((customer) {
      suppliers.forEach((supplier) {
        units.add(Unit(customer, supplier));
      });
    });
    print(
        '\n\nGenerator.generate - number of units: ${units.length} to process\n\n');
    genListener
        .onEvent('Generator number of units to process: ${units.length}');
    index = 0;
    await _startDancing();
  }

  static Future _startDancing() async {
    for (var unit in units) {
      await _generatePurchaseOrder(unit.supplier, unit.customer);
      sleep(Duration(seconds: 1));
    }
    print(
        '\n\n\n\n\nGenerator.control - purchaseOrders generated: ${purchaseOrders.length}\n\n');
    const div =
        '\n\n\n####################################################################################\n\n\n';
    print(div);
    genListener.onEvent(
        'Generator - purchaseOrders generated: ${purchaseOrders.length}');
    genListener.onPhaseComplete();

    for (var po in purchaseOrders) {
      await _generateDeliveryNote(po);
      sleep(Duration(seconds: 1));
    }
    print(div);
    genListener.onEvent(
        'Generator - delivery notes generated: ${purchaseOrders.length}');
    genListener.onPhaseComplete();

    for (var note in deliveryNotes) {
      await _acceptDeliveryNote(note);
      sleep(Duration(seconds: 1));
    }
    print(div);
    genListener.onEvent(
        'Generator - delivery notes accepted: ${deliveryNotes.length}');
    genListener.onPhaseComplete();

    for (var acc in deliveryAcceptances) {
      var note;
      deliveryNotes.forEach((n) {
        if (n.deliveryNoteId == acc.deliveryNote.split('#').elementAt(1)) {
          note = n;
        }
      });
      await _registerInvoice(acc, note);
      sleep(Duration(seconds: 1));
    }
    print(div);
    genListener.onEvent('Generator - invoices generated: ${invoices.length}');
    genListener.onPhaseComplete();

    for (var inv in invoices) {
      Supplier supplier;
      suppliers.forEach((s) {
        if (s.participantId == inv.supplier.split('#').elementAt(1)) {
          supplier = s;
        }
      });
      await _makeOffer(inv, supplier);
    }
    sleep(Duration(seconds: 1));

    print(div);
    genListener.onEvent('Generator - offers generated: ${offers.length}');
    genListener.onPhaseComplete();
  }

  static List<PurchaseOrder> purchaseOrders = List();
  static List<DeliveryNote> deliveryNotes = List();
  static List<DeliveryAcceptance> deliveryAcceptances = List();
  static List<Invoice> invoices = List();
  static List<Offer> offers = List();

  static Future _generatePurchaseOrder(
      Supplier supplier, GovtEntity customer) async {
    var user = users.elementAt(rand.nextInt(users.length - 1));
    assert(user != null);
    var po = PurchaseOrder(
      supplierDocumentRef: supplier.documentReference,
      purchaseOrderNumber: _getRandomPO(),
      supplier: nameSpace + 'Supplier#${supplier.participantId}',
      govtEntity: nameSpace + 'GovtEntity#${customer.participantId}',
      date: getUTCDate(),
      amount: _getRandomPOAmount(),
      description: 'Generated Demo Purchase Order',
      supplierName: supplier.name,
      purchaserName: customer.name,
      govtDocumentRef: customer.documentReference,
      user: nameSpace + 'User#${user.userId}',
    );

    try {
      var pOrder = await DataAPI3.registerPurchaseOrder(po);
      purchaseOrders.add(pOrder);
      genListener.onEvent(
          'Purchase order added: ${getFormattedAmount('${po.amount}', context)} : ${po.purchaserName} to ${po.supplierName} ');
    } catch (e) {
      throw e;
    }
  }

  static Future _generateDeliveryNote(PurchaseOrder po) async {
    var user = users.elementAt(rand.nextInt(users.length - 1));
    assert(user != null);
    var note = DeliveryNote(
        supplierName: po.supplierName,
        amount: po.amount,
        purchaseOrderNumber: po.purchaseOrderNumber,
        purchaseOrder: nameSpace + 'PurchaseOrder#${po.purchaseOrderId}',
        supplierDocumentRef: po.supplierDocumentRef,
        vat: po.amount * 0.15,
        date: getUTCDate(),
        supplier: po.supplier,
        customerName: po.purchaserName,
        totalAmount: po.amount * 1.15,
        user: nameSpace + 'User#${user.userId}',
        govtDocumentRef: po.govtDocumentRef,
        govtEntity: po.govtEntity);
    try {
      var nn = await DataAPI3.registerDeliveryNote(note);
      deliveryNotes.add(nn);
      genListener.onEvent(
          'Delivery Note added: ${getFormattedAmount('${note.totalAmount}', context)} : ${po.purchaserName} to ${po.supplierName} - ${nn.deliveryNoteId}');
    } catch (e) {
      throw e;
    }
  }

  static Future _acceptDeliveryNote(DeliveryNote note) async {
    var user = users.elementAt(rand.nextInt(users.length - 1));
    assert(user != null);
    var acc = DeliveryAcceptance(
      govtEntity: note.govtEntity,
      customerName: note.customerName,
      supplier: note.supplier,
      date: getUTCDate(),
      purchaseOrder: note.purchaseOrder,
      purchaseOrderNumber: note.purchaseOrderNumber,
      supplierDocumentRef: note.supplierDocumentRef,
      govtDocumentRef: note.govtDocumentRef,
      deliveryNote: nameSpace + 'DeliveryNote#${note.deliveryNoteId}',
      user: nameSpace + 'User#${user.userId}',
    );
    try {
      var aa = await DataAPI3.acceptDelivery(acc);
      deliveryAcceptances.add(aa);
      genListener.onEvent(
          'DeliveryAcceptance added: ${note.customerName} to ${note.supplierName} ');
    } catch (e) {
      throw e;
    }
  }

  static Future _registerInvoice(
      DeliveryAcceptance deliveryAcceptance, DeliveryNote note) async {
    var user = users.elementAt(rand.nextInt(users.length - 1));
    assert(user != null);
    assert(deliveryAcceptance.govtDocumentRef != null);
    var invoice = Invoice(
      invoiceNumber: _getRandomInvoiceNumber(),
      govtEntity: deliveryAcceptance.govtEntity,
      company: deliveryAcceptance.company,
      supplier: deliveryAcceptance.supplier,
      govtDocumentRef: deliveryAcceptance.govtDocumentRef,
      companyDocumentRef: deliveryAcceptance.companyDocumentRef,
      supplierDocumentRef: deliveryAcceptance.supplierDocumentRef,
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
      user: nameSpace + 'User#${user.userId}',
      deliveryAcceptance:
          NameSpace + 'DeliveryAcceptance#${deliveryAcceptance.acceptanceId}',
      date: new DateTime.now().toIso8601String(),
    );
    try {
      var i = await DataAPI3.registerInvoice(invoice);
      invoices.add(i);
      genListener.onEvent(
          'Invoice added: ${invoice.invoiceNumber} - ${getFormattedAmount('${invoice.totalAmount}', context)} ${note.customerName} to ${note.supplierName} ');
    } catch (e) {
      throw e;
    }
  }

  static Future _makeOffer(Invoice invoice, Supplier supplier) async {
    double disc = _getRandomDisc();
    var sector = sectors.elementAt(rand.nextInt(sectors.length - 1));
    assert(sector != null);
    Offer offer = new Offer(
        supplier: invoice.supplier,
        invoice: NameSpace + 'Invoice#' + invoice.invoiceId,
        purchaseOrder: invoice.purchaseOrder,
        offerAmount: invoice.amount * ((100 - disc) / 100),
        invoiceAmount: invoice.totalAmount,
        discountPercent: disc,
        startTime: getUTCDate(),
        endTime: _getRandomEndDate(),
        date: getUTCDate(),
        participantId: supplier.participantId,
        customerName: invoice.customerName,
        supplierDocumentRef: supplier.documentReference,
        supplierName: supplier.name,
        sectorName: sector.sectorName,
        sector: nameSpace + 'Sector#${sector.sectorId}',
        invoiceDocumentRef: invoice.documentReference);
    try {
      var off = await DataAPI3.makeOffer(offer);
      offers.add(off);
      genListener.onEvent(
          'Offer added: ${invoice.supplierName} for: ${getFormattedAmount('${offer.offerAmount}', context)} discount: ${offer.discountPercent}%');
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static String _getRandomEndDate() {
    int days = rand.nextInt(16);
    if (days < 5) {
      days = 10;
    }
    var date = DateTime.now().add(Duration(days: days));
    return getUTC(date);
  }

  static double _getRandomDisc() {
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
}

class Unit {
  GovtEntity customer;
  Supplier supplier;

  Unit(this.customer, this.supplier);
}
