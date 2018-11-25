class InvestorProfile {
  String profileId;
  String name;
  String cellphone;
  String email, date;
  double maxInvestableAmount, maxInvoiceAmount;
  double minimumDiscount;
  String investor, investorDocRef;
  List<String> sectors, suppliers;

  InvestorProfile(
      {this.profileId,
      this.name,
      this.cellphone,
      this.email,
      this.date,
      this.sectors,
      this.suppliers,
      this.investorDocRef,
      this.minimumDiscount,
      this.maxInvestableAmount,
      this.maxInvoiceAmount,
      this.investor});

  InvestorProfile.fromJson(Map data) {
    this.profileId = data['profileId'];
    this.name = data['name'];
    this.maxInvestableAmount = data['maxInvestableAmount'] * 1.00;
    this.maxInvoiceAmount = data['maxInvoiceAmount'] * 1.00;
    this.cellphone = data['cellphone'];
    this.investor = data['investor'];
    this.email = data['email'];
    this.investor = data['investor'];
    this.investorDocRef = data['investorDocRef'];
    this.minimumDiscount = data['minimumDiscount'] * 1.0;

    this.date = data['date'];
    List list = data['sectors'];

    this.sectors = List();
    if (list != null) {
      list.forEach((s) {
        this.sectors.add(s);
      });
    }
    List list2 = data['suppliers'];
    this.suppliers = List();
    if (list2 != null) {
      list2.forEach((s) {
        this.suppliers.add(s);
      });
    }
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'profileId': profileId,
        'name': name,
        'date': date,
        'investorDocRef': investorDocRef,
        'maxInvestableAmount': maxInvestableAmount,
        'cellphone': cellphone,
        'maxInvoiceAmount': maxInvoiceAmount,
        'email': email,
        'investor': investor,
        'sectors': sectors,
        'suppliers': suppliers,
        'minimumDiscount': minimumDiscount,
      };
}
