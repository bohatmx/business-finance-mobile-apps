import 'dart:async';

import 'package:businesslibrary/api/network_api.dart';
import 'package:businesslibrary/data/govt_entity.dart';

class CrudDriver {
  static Future<String> addGovtEntity() async {
    GovtEntity entity = GovtEntity();
    entity.name = 'Division of Information Tech';
    entity.email = 'deptis@gov.co.za';
    entity.cellphone = '082 566 7890';
    entity.description = 'A great division';
    entity.address = '33 Sibanyoni Road';
    entity.govtEntityType = GovtEntity.HomeAffairs;
    entity.co

    print('CrudDriver.addGovtEntity ${entity.toJson()}');

    //add entity to the blockchain
    String result = await NetworkAPI.addGovtEntity(entity);
    if (result == "0") {
      print('CrudDriver.addGovtEntity FAILED');
    } else {
      print('CrudDriver.addGovtEntity SUCCEEDED. Yeah!');
    }
    return result;
  }
}
