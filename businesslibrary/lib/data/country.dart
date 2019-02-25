class Country {
  String name, code, countryId;
  double vat;

  Country({this.name, this.code, this.vat, this.countryId});
  Country.fromJson(Map data) {
    this.name = data['name'];
    this.code = data['code'];
    this.vat = data['vat'];
    this.countryId = data['countryId'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'code': code,
        'vat': vat,
        'countryId': countryId,
      };
}
