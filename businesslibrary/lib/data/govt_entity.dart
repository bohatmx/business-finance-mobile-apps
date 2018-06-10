import 'package:businesslibrary/data/misc_data.dart';

class GovtEntity extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description, documentReference;
  String address, dateRegistered;

  String govtEntityType, country;

  GovtEntity(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.documentReference,
      this.dateRegistered,
      this.govtEntityType});

  static const HomeAffairs = "HOME_AFFAIRS",
      TradeAndIndustry = "TRADE_AND_INDUSTRY",
      PublicWorks = 'PUBLIC_WORKS',
      Municipality = 'MUNICIPALITY',
      Provincial = 'PROVINCIAL',
      Transport = 'TRANSPORT';

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
  }

  Map<String, String> toJson() => <String, String>{
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
      };
}
