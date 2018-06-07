class Wallet {
  String stellarPublicKey;
  DateTime dateRegistered;
  String lastBalance;
  DateTime lastBalanceDate;
  String govtEntity;
  String company;
  String supplier;
  String procurementOffice;
  String oneConnect;
  String auditor;
  String bank;
  String investor;

  Wallet(
      {this.stellarPublicKey,
      this.dateRegistered,
      this.lastBalance,
      this.lastBalanceDate,
      this.govtEntity,
      this.company,
      this.supplier,
      this.procurementOffice,
      this.oneConnect,
      this.auditor,
      this.bank,
      this.investor});

  Wallet.fromJSON(Map data) {
    this.stellarPublicKey = data['stellarPublicKey'];
    this.dateRegistered = data['dateRegistered'];
    this.lastBalance = data['lastBalance'];
    this.govtEntity = data['govtEntity'];
    this.company = data['company'];
    this.supplier = data['supplier'];
    this.oneConnect = data['oneConnect'];
    this.auditor = data['auditor'];
    this.bank = data['bank'];
    this.investor = data['investor'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'stellarPublicKey': stellarPublicKey,
        'dateRegistered': dateRegistered,
        'lastBalance': lastBalance,
        'govtEntity': govtEntity,
        'company': company,
        'supplier': supplier,
        'procurementOffice': procurementOffice,
        'oneConnect': oneConnect,
        'auditor': auditor,
        'bank': bank,
        'investor': investor,
      };
}
