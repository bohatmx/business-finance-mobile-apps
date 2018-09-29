import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:businesslibrary/api/auto_trade.dart';
import 'package:businesslibrary/data/invoice_bid.dart';
import 'package:businesslibrary/data/sector.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  static File jsonFile;
  static Directory dir;
  static bool fileExists;

  static Future<List<Sector>> getSector() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/sectors.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print("FileUtil ## file exists, reading ...");
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      Sectors w = new Sectors.fromJson(map);
      print('FileUtil ## returning payments found: ${w.sectors.length}');
      return w.sectors;
    } else {
      return null;
    }
  }

  static Future<int> saveSectors(Sectors sectors) async {
    Map map = sectors.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/sectors.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('FileUtil_saveSectors  ## file exists ...writing sectors file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'FileUtil_saveSectors ##  has cached list of sectors))))))))))))))))))) : ${sectors.sectors.length}');
      return 0;
    } else {
      print(
          'FileUti_saveSectorsl ## file does not exist ...creating and writing sectors file');
      var file = await jsonFile.create();
      var x = await file.writeAsString(json.encode(map));
      print('FileUtil_saveSectors ## looks like we cooking with gas!' + x.path);
      return 0;
    }
  }

  static Future<List<InvoiceBid>> getInvoiceBids() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/invoiceBids.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print("FileUtil ## file exists, reading ...");
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      InvoiceBids w = new InvoiceBids.fromJson(map);
      print('FileUtil ## returning InvoiceBids found: ${w.bids.length}');
      return w.bids;
    } else {
      return null;
    }
  }

  static Future<int> saveInvoiceBids(InvoiceBids bids) async {
    Map map = bids.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/invoiceBids.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('FileUtil_saveInvoiceBids  ## file exists ...writing bids file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'FileUtil_saveInvoiceBids ##  has cached list of bids))))))))))))))))))) : ${bids.bids.length}');
      return 0;
    } else {
      print(
          'FileUti_saveInvoiceBids ## file does not exist ...creating and writing bids file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      return 0;
    }
  }

  static Future<List<ExecutionUnit>> getExecutionUnits() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/executionUnits.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print("FileUtil ## file exists, reading ...");
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      ExecutionUnits w = new ExecutionUnits.fromJson(map);
      return w.units;
    } else {
      return null;
    }
  }

  static Future<int> saveExecutionUnits(ExecutionUnits units) async {
    Map map = units.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/executionUnits.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('FileUtil_saveExecutionUnits ## file exists ...writing units file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'FileUtil_saveExecutionUnits##  has cached list of units))))))))))))))))))) :');
      return 0;
    } else {
      print(
          'FileUti_saveExecutionUnits## file does not exist ...creating and writing units file');
      var file = await jsonFile.create();
      await file.writeAsString(json.encode(map));
      return 0;
    }
  }
}

class Sectors {
  List<Sector> sectors;

  Sectors(this.sectors);

  Sectors.fromJson(Map data) {
    List map = data['sectors'];
    this.sectors = List();
    map.forEach((m) {
      var sector = Sector.fromJson(m);
      sectors.add(sector);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'sectors': sectors,
      };
}

class InvoiceBids {
  List<InvoiceBid> bids;

  InvoiceBids(this.bids);

  InvoiceBids.fromJson(Map data) {
    List map = data['bids'];
    this.bids = List();
    map.forEach((m) {
      var bid = InvoiceBid.fromJson(m);
      bids.add(bid);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'bids': bids,
      };
}

class ExecutionUnits {
  List<ExecutionUnit> units;

  ExecutionUnits(this.units);

  ExecutionUnits.fromJson(Map data) {
    List map = data['units'];
    this.units = List();
    map.forEach((m) {
      var bid = ExecutionUnit.fromJson(m);
      units.add(bid);
    });
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'units': units,
      };
}
