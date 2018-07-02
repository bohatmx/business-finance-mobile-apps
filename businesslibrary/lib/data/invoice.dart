class Invoice {
  String supplier,
      purchaseOrder,
      invoiceId,
      deliveryNote,
      company,
      govtEntity,
      wallet,
      user,
      invoiceNumber,
      description,
      reference,
      documentReference,
      supplierDocumentRef,
      govtDocumentRef,
      companyDocumentRef,
      supplierContract,
      contractDocumentRef,
      companyInvoiceSettlement,
      offer,
      govtInvoiceSettlement,
      supplierName;
  bool isOnOffer, isSettled;
  String date, datePaymentRequired;
  String customerName, purchaseOrderNumber;
  List<String> investorInvoiceSettlements;
  double amount, totalAmount, valueAddedTax;

  Invoice(
      {this.supplier,
      this.invoiceId,
      this.purchaseOrder,
      this.deliveryNote,
      this.company,
      this.govtEntity,
      this.wallet,
      this.user,
      this.companyInvoiceSettlement,
      this.govtInvoiceSettlement,
      this.investorInvoiceSettlements,
      this.isSettled,
      this.invoiceNumber,
      this.description,
      this.reference,
      this.date,
      this.totalAmount,
      this.valueAddedTax,
      this.purchaseOrderNumber,
      this.customerName,
      this.supplierName,
      this.documentReference,
      this.supplierDocumentRef,
      this.govtDocumentRef,
      this.contractDocumentRef,
      this.supplierContract,
      this.companyDocumentRef,
      this.datePaymentRequired,
      this.isOnOffer,
      this.offer,
      this.amount});

  Invoice.fromJson(Map data) {
    this.totalAmount = data['totalAmount'];
    this.valueAddedTax = data['valueAddedTax'];

    this.supplier = data['supplier'];
    this.invoiceId = data['invoiceId'];
    this.deliveryNote = data['deliveryNote'];
    this.purchaseOrder = data['purchaseOrder'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.wallet = data['wallet'];
    this.user = data['user'];
    this.invoiceNumber = data['invoiceNumber'];
    this.description = data['description'];
    this.reference = data['reference'];
    this.date = data['date'];
    this.datePaymentRequired = data['datePaymentRequired'];
    this.amount = data['amount'];
    this.documentReference = data['documentReference'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.supplierName = data['supplierName'];
    this.govtDocumentRef = data['govtDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];
    this.purchaseOrderNumber = data['purchaseOrderNumber'];
    this.customerName = data['customerName'];
    this.supplierContract = data['supplierContract'];
    this.contractDocumentRef = data['contractDocumentRef'];
    this.isOnOffer = data['isOnOffer'];
    this.offer = data['offer'];

    this.companyInvoiceSettlement = data['companyInvoiceSettlement'];
    this.govtInvoiceSettlement = data['govtInvoiceSettlement'];
    this.isSettled = data['isSettled'];
    this.investorInvoiceSettlements = data['investorInvoiceSettlements'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();

    map['totalAmount'] = totalAmount;
    map['valueAddedTax'] = valueAddedTax;

    map['supplier'] = supplier;
    map['invoiceId'] = invoiceId;
    map['deliveryNote'] = deliveryNote;
    map['purchaseOrder'] = purchaseOrder;
    map['company'] = company;
    map['govtEntity'] = govtEntity;
    map['wallet'] = wallet;
    map['user'] = user;
    map['invoiceNumber'] = invoiceNumber;
    map['description'] = description;
    map['reference'] = reference;
    map['date'] = date;
    map['datePaymentRequired'] = datePaymentRequired;
    map['amount'] = amount;
    map['documentReference'] = documentReference;
    map['supplierDocumentRef'] = supplierDocumentRef;
    map['supplierName'] = supplierName;
    map['govtDocumentRef'] = govtDocumentRef;
    map['companyDocumentRef'] = companyDocumentRef;
    map['purchaseOrderNumber'] = purchaseOrderNumber;
    map['customerName'] = customerName;
    map['supplierContract'] = supplierContract;
    map['contractDocumentRef'] = contractDocumentRef;
    map['isOnOffer'] = isOnOffer;
    map['offer'] = offer;

    map['companyInvoiceSettlement'] = companyInvoiceSettlement;
    map['govtInvoiceSettlement'] = govtInvoiceSettlement;
    map['isSettled'] = isSettled;
    map['investorInvoiceSettlements'] = investorInvoiceSettlements;
    return map;
  }
}
