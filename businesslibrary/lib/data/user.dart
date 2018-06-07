class User {
  String userId,
      firstName,
      lastName,
      idNumber,
      email,
      password,
      cellphone,
      address;
  DateTime dateRegistered;

  User(
      {this.userId,
      this.firstName,
      this.lastName,
      this.idNumber,
      this.email,
      this.password,
      this.cellphone,
      this.address,
      this.dateRegistered});

  static const companyStaff = "COMPANY",
      govtStaff = 'GOVT',
      auditorStaff = 'AUDITOR',
      bankStaff = "BANK",
      supplierStaff = 'SUPPLIER',
      oneConnectStaff = 'ONECONNECT',
      investorStaff = 'INVESTOR',
      procurementStaff = 'PROCUREMENT';

  User.fromJSON(Map data) {
    this.userId = data['userId'];
    this.dateRegistered = data['dateRegistered'];
    this.firstName = data['firstName'];
    this.lastName = data['lastName'];
    this.idNumber = data['idNumber'];
    this.password = data['password'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'dateRegistered': dateRegistered,
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'password': password,
        'cellphone': cellphone,
        'address': address,
      };
}
