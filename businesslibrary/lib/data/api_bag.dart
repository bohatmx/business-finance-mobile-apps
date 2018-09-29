class APIBag {
  bool debug;
  Map data;
  String collectionName, apiSuffix;

  APIBag({this.debug, this.data, this.collectionName, this.apiSuffix});
  APIBag.fromJson(Map data) {
    this.debug = data['debug'];
    this.data = data['data'];
    this.collectionName = data['collectionName'];
    this.apiSuffix = data['apiSuffix'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'debug': debug,
        'data': data,
        'collectionName': collectionName,
        'apiSuffix': apiSuffix,
      };
}
