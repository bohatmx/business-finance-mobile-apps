import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/util.dart';

class Accept {
  static Future<String> sendAcceptance(DeliveryNote note, User user) async {
    print(
        '\n\nAccept.sendAcceptance ####################### ......purchaseOrderNumber: ${note.purchaseOrderNumber}\n\n');
    var a = DeliveryAcceptance(
      date: DateTime.now().toIso8601String(),
      supplier: note.supplier,
      deliveryNote:
          'resource:com.oneconnect.biz.DeliveryNote#${note.deliveryNoteId}',
      govtEntity: note.govtEntity,
      customerName: note.customerName,
      purchaseOrder: note.purchaseOrder,
      purchaseOrderNumber: note.purchaseOrderNumber,
      user: 'resource:com.oneconnect.biz.User#${user.userId}',
    );
    var api = DataAPI(getURL());
    var res = await api.acceptDelivery(a);

    return res;
  }

  static Future<String> sendInvoiceAcceptance(
      Invoice invoice, User user) async {
    print(
        '\n\nAccept.sendInvoiceAcceptance ...... ######################### invoiceNumber: ${invoice.invoiceNumber}');
    var a = InvoiceAcceptance(
      date: DateTime.now().toIso8601String(),
      supplierName: invoice.supplierName,
      invoiceNumber: invoice.invoiceNumber,
      invoice: 'resource:com.oneconnect.biz.Invoice#${invoice.invoiceId}',
      govtEntity: invoice.govtEntity,
      customerName: invoice.customerName,
      user: 'resource:com.oneconnect.biz.User#${user.userId}',
      supplierDocumentRef: invoice.supplierDocumentRef,
    );
    var api = DataAPI(getURL());
    var res = await api.acceptInvoice(a);

    return res;
  }
}
