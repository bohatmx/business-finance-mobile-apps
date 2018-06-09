import 'dart:async';

import 'package:businesslibrary/api/network_api.dart';
import 'package:businesslibrary/data/govt_entity.dart';

class CrudDriver {
  static Future<String> addGovtEntity() async {
    GovtEntity entity = GovtEntity();
    entity.name = 'Information &  Communications Technology Division';
    entity.email = 'deptis@gov.co.za';
    entity.cellphone = '082 566 7890';
    entity.description = 'A great division for various geeks and misfits';
    entity.address = '33 Sibanyoni Road, Centurion, Gauteng  2008';
    entity.govtEntityType = GovtEntity.PublicWorks;
    entity.country = 'SOUTH_AFRICA';
    entity.dateRegistered = new DateTime.now().toIso8601String();

    print('CrudDriver.addGovtEntity ...... ${entity.toJson()}');

    //add entity to the blockchain
    String key = await NetworkAPI.addGovtEntity(entity);
    if (key == "0") {
      print('CrudDriver.addGovtEntity FAILED');
    } else {
      print('CrudDriver.addGovtEntity SUCCEEDED. Yeah! key: $key');
    }
    return key;
  }

  static Future<List<GovtEntity>> getGovtEntities() async {
    List<GovtEntity> list = await NetworkAPI.getGovtEntities();
    if (list == null) {
      print('CrudDriver.getGovtEntities FAILED');
    } else {
      print('CrudDriver.getGovtEntities SUCCEEDED. Yeah! ${list.length}');
      list.forEach((entity) {
        print(
            'CrudDriver.getGovtEntities, entity via package: ${entity.toJson()}');
      });
    }
    return list;
  }
}
