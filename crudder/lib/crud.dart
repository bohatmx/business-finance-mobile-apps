import 'dart:async';

import 'package:businesslibrary/api/data_api.dart';
import 'package:businesslibrary/api/list_api.dart';
import 'package:businesslibrary/data/company.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:crudder/util.dart';

class CrudDriver {
  static Future<String> addGovtEntity() async {
    GovtEntity entity = GovtEntity();
    entity.name = 'Agriculture Division';
    entity.email = 'agric@gov.co.za';
    entity.cellphone = '082 566 3348';
    entity.description = 'A division for Agruculturists';
    entity.address = '480 Joe Mlangeni Road, Centurion, Gauteng  2008';
    entity.govtEntityType = GovtEntity.TradeAndIndustry;
    entity.country = 'SOUTH_AFRICA';
    entity.dateRegistered = new DateTime.now().toIso8601String();

    print('CrudDriver.addGovtEntity ...... ${entity.toJson()}');

    var api = new DataAPI(Util.getURL());

    var key = await api.addGovtEntity(entity);
    if (key == "0") {
      print('CrudDriver.addGovtEntity FAILED');
    } else {
      print('CrudDriver.addGovtEntity SUCCEEDED. Yeah! key: $key');
    }
    entity.name = 'Water Division';
    entity.email = 'waterdiv@gov.co.za';
    entity.cellphone = '082 566 1122';
    entity.description = 'A division for Water Engineers';
    entity.address = '480 WF Nkomo, Pretoria, Gauteng  2008';
    entity.govtEntityType = GovtEntity.PublicWorks;
    entity.country = 'SOUTH_AFRICA';
    entity.dateRegistered = new DateTime.now().toIso8601String();

    key = await api.addGovtEntity(entity);
    if (key == "0") {
      print('CrudDriver.addGovtEntity FAILED');
    } else {
      print('CrudDriver.addGovtEntity SUCCEEDED. Yeah! key: $key');
    }
    entity.name = 'Roads Division';
    entity.email = 'roadsdiv@gov.co.za';
    entity.cellphone = '082 566 5544';
    entity.description = 'A division for Road Engineers';
    entity.address = '489 WF Nkomo, Pretoria, Gauteng  2008';
    entity.govtEntityType = GovtEntity.PublicWorks;
    entity.country = 'SOUTH_AFRICA';
    entity.dateRegistered = new DateTime.now().toIso8601String();

    key = await api.addGovtEntity(entity);
    if (key == "0") {
      print('CrudDriver.addGovtEntity FAILED');
    } else {
      print('CrudDriver.addGovtEntity SUCCEEDED. Yeah! key: $key');
    }
    return key;
  }

  static Future<String> addCompanies() async {
    Company company = Company();
    company.name = 'Acme Industrial Pty Ltd';
    company.email = 'sales@acmeindustry.co.za';
    company.cellphone = '082 776 3348';
    company.description = 'A general industrial company';
    company.address = '480 Joe Mlangeni Road, Centurion, Gauteng  2008';
    company.privateSectorType = Company.Industrial;
    company.country = 'SOUTH_AFRICA';
    company.dateRegistered = new DateTime.now().toIso8601String();

    print('CrudDriver.addCompanies ...... ${company.toJson()}');

    var api = new DataAPI(Util.getURL());

    var key = await api.addCompany(company);
    if (key == "0") {
      print('CrudDriver.addCompanies FAILED');
    } else {
      print('CrudDriver.addCompanies SUCCEEDED. Yeah! key: $key');
    }
    company.name = 'GBS Logistic Pty Ltd';
    company.email = 'sales@gbslogistics.co.za';
    company.cellphone = '082 566 1122';
    company.description = 'A Logistics and Transport company';
    company.address = '133 Joe Slovo Avenue, Parktown, Gauteng  2008';
    company.privateSectorType = Company.Industrial;
    company.country = 'SOUTH_AFRICA';
    company.dateRegistered = new DateTime.now().toIso8601String();

    key = await api.addCompany(company);
    if (key == "0") {
      print('CrudDriver.addCompanies FAILED');
    } else {
      print('CrudDriver.addCompanies SUCCEEDED. Yeah! key: $key');
    }

    return key;
  }

  static Future<List<GovtEntity>> getGovtEntities() async {
    var api = new ListAPI(Util.getURL());
    List<GovtEntity> list = await api.getGovtEntities();
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
