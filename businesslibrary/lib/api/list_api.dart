import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/purchase_order.dart';

class ListAPI {
  final String url;

  ListAPI(this.url);

  static HttpClient _httpClient = new HttpClient();

  Future<List<GovtEntity>> getGovtEntities() async {
    print('ListAPI.getGovtEntities -----> url: ${url  + DataAPI.GOVT_ENTITY}');
    HttpClientRequest mRequest =
        await _httpClient.getUrl(Uri.parse(url + DataAPI.GOVT_ENTITY));
    HttpClientResponse resp = await mRequest.close();
    print('ListAPI.getGovtEntities ######### resp.statusCode: ${resp
            .statusCode}');
    var list = List<GovtEntity>();
    if (resp.statusCode == 200) {
      var contents = await _transform(resp);
      List mList = json.decode(contents);
      await mList.forEach((f) {
        GovtEntity g = new GovtEntity.fromJson(f);
        list.add(g);
        print('ListAPI.getGovtEntities)))))))  entity added to list: ${g
                .toJson()}');
      });

      print('ListAPI.getGovtEntities entities: ${list.length}');
      return list;
    } else {
      print('ListAPI.getGovtEntities ERROR  ${resp.reasonPhrase}');
      return null;
    }
  }

  Future<List<PurchaseOrder>> getPurchaseOrders(String participantId) async {
    assert(participantId != null);
    var httpClient = new HttpClient();

    List<PurchaseOrder> list = List();

    var request = await httpClient.getUrl(Uri.parse(url + participantId));
    var resp = await request.close();
    var statusCode = resp.statusCode;
    print("REST server HTTP status code: $statusCode");
    if (resp.statusCode == 200) {
      var contents = await _transform(resp);
      List mList = json.decode(contents);
      await mList.forEach((f) {
        PurchaseOrder g = new PurchaseOrder.fromJson(f);
        list.add(g);
        print('ListAPI.getPurchaseOrders)))))))  purch order added to list: ${g
            .toJson()}');
      });

      print('ListAPI.getPurchaseOrders entities: ${list.length}');
      return list;
    } else {
      print('ListAPI.getPurchaseOrders ERROR  ${resp.reasonPhrase}');
      return null;
    }

    return list;
  }

  Future<String> _transform(HttpClientResponse resp) async {
    StringBuffer builder = new StringBuffer();
    await for (String a in await resp.transform(utf8.decoder)) {
      builder.write(a);
    }
    return builder.toString();
  }
}
