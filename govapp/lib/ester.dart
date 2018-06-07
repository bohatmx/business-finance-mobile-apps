import 'package:businesslibrary/api/network_api.dart';
import 'package:businesslibrary/data/delivery_note.dart';

class Ester {
  DeliveryNote note = new DeliveryNote();

  static getData() {
    String url = NetworkAPI.getURL();
    print('Ester.getData URL: $url');
  }
}
