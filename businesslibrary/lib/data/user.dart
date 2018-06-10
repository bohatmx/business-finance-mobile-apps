class User {
  String userId,
      firstName,
      lastName,
      idNumber,
      govtEntity,
      company,
      supplier,
      auditor,
      oneConnect,
      procurementOffice,
      investor,
      bank,
      email,
      password,
      cellphone,
      address,
      fcmToken,
      documentReference;
  String dateRegistered, isAdministrator, userType;

  User(
      {this.userId,
      this.firstName,
      this.lastName,
      this.idNumber,
      this.govtEntity,
      this.company,
      this.supplier,
      this.auditor,
      this.oneConnect,
      this.procurementOffice,
      this.investor,
      this.bank,
      this.email,
      this.password,
      this.cellphone,
      this.address,
      this.fcmToken,
      this.documentReference,
      this.dateRegistered,
      this.isAdministrator,
      this.userType});

  static const companyStaff = "COMPANY",
      govtStaff = 'GOVT_STAFF',
      auditorStaff = 'AUDITOR',
      bankStaff = "BANK",
      supplierStaff = 'SUPPLIER',
      oneConnectStaff = 'ONECONNECT',
      investorStaff = 'INVESTOR',
      procurementStaff = 'PROCUREMENT';

  User.fromJson(Map data) {
    this.userId = data['userId'];
    this.dateRegistered = data['dateRegistered'];
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.idNumber = data['idNumber'];
    this.email = data['email'];
    this.password = data['password'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.isAdministrator = data['isAdministrator'];
    this.fcmToken = data['fcmToken'];
    this.documentReference = data['documentReference'];

    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.supplier = data['supplier'];
    this.auditor = data['auditor'];
    this.oneConnect = data['oneConnect'];
    this.procurementOffice = data['procurementOffice'];
    this.investor = data['investor'];
    this.bank = data['bank'];
    this.userType = data['userType'];
  }
  Map<String, String> toJson() => <String, String>{
        'userId': userId,
        'dateRegistered': dateRegistered,
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'email': email,
        'password': password,
        'cellphone': cellphone,
        'address': address,
        'fcmToken': fcmToken,
        'isAdministrator': isAdministrator,
        'documentReference': documentReference,
        'govtEntity': govtEntity,
        'company': company,
        'supplier': supplier,
        'auditor': auditor,
        'oneConnect': oneConnect,
        'procurementOffice': procurementOffice,
        'investor': investor,
        'bank': bank,
        'userType': userType,
      };
}
