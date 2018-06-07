import 'package:govapp/data/user.dart';
import 'package:govapp/data/wallet.dart';
import 'package:meta/meta.dart';

class Company extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address;
  List<Wallet> wallets;
  List<User> users;
  String privateSectorType;

  Company(
      {@required this.participantId,
      @required this.name,
      this.cellphone,
      @required this.email,
      this.description,
      this.address,
      @required this.wallets,
      @required this.users,
      @required this.privateSectorType});

  static const Technology = "TECHNOLOGY",
      Retail = "RETAIL",
      Industrial = 'INDUSTRIAL',
      Agricultural = 'AGRICULTURAL',
      Informal = 'INFORMAL_TRADE',
      Construction = 'CONSTRUCTION',
      FinancialServices = 'FINANCIAL_SERVICES',
      Education = 'EDUCATIONAL';

  Company.fromJSON(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.privateSectorType = data['privateSectorType'];
    this.wallets = data['wallets'];
    this.users = data['users'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['address'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'privateSectorType': privateSectorType,
        'wallets': wallets,
        'users': users,
        'cellphone': cellphone,
        'address': address,
        'email': email
      };
}
