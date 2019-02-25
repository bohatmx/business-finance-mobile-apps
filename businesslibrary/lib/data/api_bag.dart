class APIBag {
  bool debug;
  String jsonString;
  String userName, functionName;

  APIBag({this.debug, this.userName, this.functionName, this.jsonString});

  APIBag.fromJson(Map data) {
    this.debug = data['debug'];
    this.userName = data['userName'];
    this.functionName = data['functionName'];
    this.jsonString = data['jsonString'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'debug': debug,
        'userName': userName,
        'functionName': functionName,
        'jsonString': jsonString,
      };
}
