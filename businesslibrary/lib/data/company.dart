import 'package:businesslibrary/data/misc_data.dart';

class Company extends BaseParticipant {
  String participantId;
  String name;
  String cellphone;
  String email;
  String description;
  String address, dateRegistered;
  String privateSectorType, country;

  Company(
      {this.participantId,
      this.name,
      this.cellphone,
      this.email,
      this.description,
      this.address,
      this.country,
      this.dateRegistered,
      this.privateSectorType});

  static const Technology = "TECHNOLOGY",
      Retail = "RETAIL",
      Industrial = 'INDUSTRIAL',
      Agricultural = 'AGRICULTURAL',
      Informal = 'INFORMAL_TRADE',
      Construction = 'CONSTRUCTION',
      FinancialServices = 'FINANCIAL_SERVICES',
      Education = 'EDUCATIONAL';

  Company.fromJson(Map data) {
    this.participantId = data['participantId'];
    this.name = data['name'];
    this.description = data['description'];
    this.privateSectorType = data['privateSectorType'];
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
        'privateSectorType': privateSectorType,
        'cellphone': cellphone,
        'address': address,
        'email': email,
        'country': country,
        'dateRegistered': dateRegistered,
      };
}
