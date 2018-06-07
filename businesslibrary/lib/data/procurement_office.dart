import 'package:businesslibrary/data/misc_data.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/data/wallet.dart';

class ProcurementOffice extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, country;
  List<Wallet> wallets;
  List<User> users;

  ProcurementOffice(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.wallets,
      this.country,
      this.users});

  ProcurementOffice.fromJSON(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
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
        'wallets': wallets,
        'users': users,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
      };
}
