import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';

class StorageAPI {
  static FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

  // ignore: missing_return
  static Future<String> uploadFile(String folderName, String path) async {
    print('StorageAPI.uploadFile $folderName path: $path');
    rand = new Random(new DateTime.now().millisecondsSinceEpoch);
    var index = path.lastIndexOf('.');
    var extension = path.substring(index + 1);
    var name = 'BFN' +
        new DateTime.now().toIso8601String() +
        '_${rand.nextInt(1000)} +.$extension';

    File file = new File(path);
    var task =
        _firebaseStorage.ref().child(folderName).child(name).putFile(file);
    await task.future.then((snap) {
      var url = snap.downloadUrl.toString();
      print('StorageAPI._uploadFile: SUCCESS!!! -  FILE UPLOADED ...: $url');
      return url;
    }).catchError((e) {
      print('StorageAPI._uploadFile ERROR $e');
      return '0';
    });
    print(
        'StorageAPI.uploadFile \n****  END OF METHOD  ... what happens next while uploading??????\n\n');
  }

  // ignore: missing_return
  static Future<int> deleteFolder(String folderName) async {
    print('StorageAPI.deleteFolder ######## deleting $folderName');
    var task = _firebaseStorage.ref().child(folderName).delete();
    await task.then((f) {
      print('StorageAPI.deleteFolder $folderName deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      print('StorageAPI.deleteFolder ERROR $e');
      return 1;
    });
  }

  // ignore: missing_return
  static Future<int> deleteFile(String folderName, String name) async {
    print('StorageAPI.deleteFile ######## deleting $folderName : $name');
    var task = _firebaseStorage.ref().child(folderName).child(name).delete();
    task.then((f) {
      print(
          'StorageAPI.deleteFile $folderName : $name deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      print('StorageAPI.deleteFile ERROR $e');
      return 1;
    });
  }
}
