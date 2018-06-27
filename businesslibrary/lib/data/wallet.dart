class Wallet {
  String stellarPublicKey;
  String dateRegistered;
  String lastBalance;
  String lastBalanceDate;
  String govtEntity;
  String company;
  String supplier;
  String procurementOffice;
  String oneConnect;
  String auditor, sourceSeed;
  String bank, secret, fcmToken;
  String investor, documentReference;
  bool debug;

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
      this.debug,
      this.secret,
      this.sourceSeed,
      this.fcmToken,
      this.documentReference,
      this.investor});

  Wallet.fromJson(Map data) {
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
    this.documentReference = data['documentReference'];
    this.secret = data['secret'];
    this.fcmToken = data['fcmToken'];
    this.sourceSeed = data['sourceSeed'];
    this.debug = data['debug'];
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
        'documentReference': documentReference,
        'secret': secret,
        'fcmToken': fcmToken,
        'sourceSeed': sourceSeed,
        'debug': debug,
      };
}
