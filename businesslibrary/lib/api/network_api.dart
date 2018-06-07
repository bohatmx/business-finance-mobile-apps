import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/data/purchase_order.dart';
import 'package:businesslibrary/data/user.dart';

class NetworkAPI {
  static const DEBUG_URL_HOME = 'http://192.168.86.238:3003/api/'; //FIBRE
  static const DEBUG_URL_ROUTER = 'http://192.168.8.237:3003/api/'; //ROUTER

  static const RELEASE_URL = 'http://192.168.86.238:3003/api/'; //CLOUD

  static String getURL() {
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_HOME; //switch  to DEBUG_URL_ROUTER before demo
    } else {
      url = RELEASE_URL;
    }
    return url;
  }

  Future addUser(User user) async {
    String url = getURL();
    var httpClient = new HttpClient();
    httpClient.postUrl(Uri.parse(url)).then((HttpClientRequest request) {
      request.write(user);

      return request.close();
    }).then((HttpClientResponse response) {});

    return null;
  }

  static Future<List<PurchaseOrder>> getPurchaseOrders(
      String participantId) async {
    assert(participantId != null);
    String url = getURL() + participantId;
    print("getPurchaseOrders url: " + url);
    var httpClient = new HttpClient();

    List<PurchaseOrder> pos = List();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var statusCode = response.statusCode;
    print("REST server HTTP status code: $statusCode");
    if (response.statusCode == HttpStatus.OK) {
      var jx = await response.transform(utf8.decoder).join();
      Map data = json.decode(jx);
      data.forEach((key, value) {
        var po = new PurchaseOrder.fromJSON(value);
        pos.add(po);
      });
    } else {
      var code = response.statusCode;
      var msg = 'Bad REST server HTTP status code: $code';
      print(msg);
      throw (msg);
    }

    return pos;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
