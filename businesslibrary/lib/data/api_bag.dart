class APIBag {
  bool debug;
  Map data;
  Map user;
  String sourceSeed;
  String collectionName, apiSuffix;

  APIBag(
      {this.debug,
      this.data,
      this.collectionName,
      this.apiSuffix,
      this.sourceSeed,
      this.user});
  APIBag.fromJson(Map data) {
    this.debug = data['debug'];
    this.data = data['data'];
    this.collectionName = data['collectionName'];
    this.apiSuffix = data['apiSuffix'];
    this.user = data['user'];
    this.sourceSeed = data['sourceSeed'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'debug': debug,
        'data': data,
        'collectionName': collectionName,
        'apiSuffix': apiSuffix,
        'user': user,
        'sourceSeed': sourceSeed,
      };
}

/*
const debug = request.body.debug;
    const collectionName = request.body.collectionName;
    const apiSuffix = request.body.apiSuffix;
    const data = request.body.data;
    const user = request.body.user;
    const sourceSeed = request.body.sourceSeed;
 */
