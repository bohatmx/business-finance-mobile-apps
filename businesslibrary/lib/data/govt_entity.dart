import 'package:businesslibrary/data/misc_data.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';

class GovtEntity extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address;
  List<Wallet> wallets;
  List<User> users;
  String privateSectorType;

  GovtEntity(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.wallets,
      this.users,
      this.privateSectorType});

  static const HomeAffairs = "HOME AFFAIRS",
      TradeAndIndustry = "TRADE & INDUSTRY",
      PublicWorks = 'PUBLIC_WORKS',
      Municipality = 'MUNICIPALITY',
      Provincial = 'PROVINCIAL',
      Transport = 'TRANSPORT';

  GovtEntity.fromJSON(Map data) {
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
