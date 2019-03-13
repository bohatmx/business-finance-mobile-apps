import 'package:businesslibrary/data/misc_data.dart';

class Investor extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description, dateRegistered;
  String address, country;

  Investor({
    this.participantId,
    this.name,
    this.cellphone,
    this.email,
    this.description,
    this.address,
    this.dateRegistered,
    this.country,
  });

  Investor.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['address'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
  }
  Map<String, String> toJson() => <String, String>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
      };
}
