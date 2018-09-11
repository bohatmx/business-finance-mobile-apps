import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
