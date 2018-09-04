class InvestorProfile {
  String profileId;
  String name;
  String cellphone;
  String email, date;
  double maxInvestableAmount, maxInvoiceAmount;
  String investor;
  List<String> sectors, suppliers;

  InvestorProfile(
      {this.profileId,
      this.name,
      this.cellphone,
      this.email,
      this.date,
      this.sectors,
      this.suppliers,
      this.maxInvestableAmount,
      this.maxInvoiceAmount,
      this.investor});

  InvestorProfile.fromJson(Map data) {
    this.profileId = data['profileId'];
    this.name = data['name'];
    this.maxInvoiceAmount = data['maxInvoiceAmount'];
    this.cellphone = data['cellphone'];
    this.investor = data['investor'];
    this.email = data['email'];
    this.investor = data['investor'];
    this.sectors = data['sectors'];
    this.investor = data['investor'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'profileId': profileId,
        'name': name,
        'maxInvestableAmount': maxInvestableAmount,
        'cellphone': cellphone,
        'maxInvoiceAmount': maxInvoiceAmount,
        'email': email,
        'investor': investor,
        'sectors': sectors,
        'suppliers': suppliers,
      };
}
