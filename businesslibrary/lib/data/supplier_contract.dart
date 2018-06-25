class SupplierContract {
  String contractId;
  String startDate;
  String endDate;
  String date;
  String estimatedValue;
  String customerName;
  String supplierName;
  String description;
  String documentReference;
  String govtDocumentRef;
  String companyDocumentRef;
  String supplierDocumentRef;
  String govtEntity;
  String company;
  String supplier;
  String user, contractURL;

  SupplierContract(
      {this.contractId,
      this.startDate,
      this.endDate,
      this.date,
      this.estimatedValue,
      this.customerName,
      this.supplierName,
      this.description,
      this.documentReference,
      this.govtDocumentRef,
      this.companyDocumentRef,
      this.supplierDocumentRef,
      this.govtEntity,
      this.company,
      this.contractURL,
      this.supplier,
      this.user});

  SupplierContract.fromJson(Map data) {
    this.contractId = data['contractId'];
    this.startDate = data['startDate'];
    this.company = data['company'];
    this.govtEntity = data['govtEntity'];
    this.user = data['user'];
    this.endDate = data['endDate'];
    this.estimatedValue = data['estimatedValue'];
    this.date = data['date'];
    this.customerName = data['customerName'];
    this.description = data['description'];
    this.documentReference = data['documentReference'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];
    this.govtDocumentRef = data['govtDocumentRef'];
    this.supplierDocumentRef = data['supplierDocumentRef'];
    this.companyDocumentRef = data['companyDocumentRef'];
    this.contractURL = data['contractURL'];
  }

  Map<String, String> toJson() => <String, String>{
        'contractId': contractId,
        'startDate': startDate,
        'company': company,
        'govtEntity': govtEntity,
        'user': user,
        'endDate': endDate,
        'estimatedValue': estimatedValue,
        'date': date,
        'customerName': customerName,
        'description': description,
        'documentReference': documentReference,
        'supplierName': supplierName,
        'supplier': supplier,
        'govtDocumentRef': govtDocumentRef,
        'supplierDocumentRef': supplierDocumentRef,
        'companyDocumentRef': companyDocumentRef,
        'contractURL': contractURL,
      };
}
