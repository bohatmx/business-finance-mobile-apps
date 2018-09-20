import 'package:businesslibrary/data/misc_data.dart';

class GovtEntity extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description, documentReference;
  String address, dateRegistered;
  String govtEntityType, country;
  bool allowAutoAccept;

  GovtEntity(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.allowAutoAccept,
      this.documentReference,
      this.dateRegistered,
      this.govtEntityType});

  static const National = "NATIONAL",
      Municipality = 'MUNICIPALITY',
      Provincial = 'PROVINCIAL';

  GovtEntity.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.govtEntityType = data['govtEntityType'];
    this.cellphone = data['cellphone'];
    this.address = data['address'];
    this.email = data['email'];
    this.country = data['country'];
    this.dateRegistered = data['dateRegistered'];
    this.documentReference = data['documentReference'];
    this.allowAutoAccept = data['allowAutoAccept'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'participantId': participantId,
        'name': name,
        'description': description,
        'govtEntityType': govtEntityType,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
        'documentReference': documentReference,
        'allowAutoAccept': allowAutoAccept,
      };
}
