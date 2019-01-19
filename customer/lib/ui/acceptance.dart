import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/delivery_acceptance.dart';
import 'package:businesslibrary/data/delivery_note.dart';
import 'package:businesslibrary/data/invoice.dart';
import 'package:businesslibrary/data/invoice_acceptance.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/lookups.dart';

class Accept {
  static Future<String> sendAcceptance(DeliveryNote note, User user) async {
    print(
        '\n\nAccept.sendAcceptance ####################### ......purchaseOrderNumber: ${note.purchaseOrderNumber}\n\n');
    var a = DeliveryAcceptance(
      date: getUTCDate(),
      supplier: note.supplier,
      deliveryNote:
          'resource:com.oneconnect.biz.DeliveryNote#${note.deliveryNoteId}',
      govtEntity: note.govtEntity,
      customerName: note.customerName,
      purchaseOrder: note.purchaseOrder,
      purchaseOrderNumber: note.purchaseOrderNumber,
      user: 'resource:com.oneconnect.biz.User#${user.userId}',
    );
    var res = await DataAPI.acceptDelivery(a);

    return res;
  }

  static Future<String> sendInvoiceAcceptance(
      Invoice invoice, User user) async {
    print(
        '\n\nAccept.sendInvoiceAcceptance ...... ######################### invoiceNumber: ${invoice.invoiceNumber}');
    var a = InvoiceAcceptance(
      date: getUTCDate(),
      supplierName: invoice.supplierName,
      invoiceNumber: invoice.invoiceNumber,
      invoice: 'resource:com.oneconnect.biz.Invoice#${invoice.invoiceId}',
      govtEntity: invoice.govtEntity,
      customerName: invoice.customerName,
      user: 'resource:com.oneconnect.biz.User#${user.userId}',
      supplierDocumentRef: invoice.supplierDocumentRef,
    );
    var res = await DataAPI.acceptInvoice(a);

    return res;
  }
}
