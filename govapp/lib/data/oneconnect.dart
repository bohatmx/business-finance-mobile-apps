import 'package:govapp/data/user.dart';
import 'package:govapp/data/wallet.dart';
import 'package:meta/meta.dart';

class OneConnect extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address;
  List<Wallet> wallets;
  List<User> users;

  OneConnect(
      {@required this.participantId,
      @required this.name,
      this.cellphone,
      @required this.email,
      this.description,
      this.address,
      @required this.wallets,
      @required this.users});

  OneConnect.fromJSON(Map data) {
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
        'email': email
      };
}
