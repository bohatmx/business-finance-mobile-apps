import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class Lookups {
  static Firestore _firestore = Firestore.instance;

  static Future<List<PrivateSectorType>> getTypes() async {
    List<PrivateSectorType> list = List();

    var qs = await _firestore
        .collection('privateSectorTypes')
        .getDocuments()
        .catchError((e) {
      return list;
    });
    qs.documents.forEach((doc) {
      var type = new PrivateSectorType.fromJson(doc.data);
      list.add(type);
    });

    return list;
  }

  static Future<List<Country>> getCountries() async {
    List<Country> list = List();

    var qs =
        await _firestore.collection('countries').getDocuments().catchError((e) {
      print('Lookups.getCountries ERROR $e');
      return list;
    });
    qs.documents.forEach((doc) {
      var type = new Country.fromJson(doc.data);
      list.add(type);
    });

    return list;
  }

  static Future<int> storeCountries() async {
    var t1 = new Country(name: 'South Africa', code: 'ZA');
    await _firestore.collection('countries').add(t1.toJson()).catchError((e) {
      return 1;
    });
    var t2 = new Country(name: 'Zimbabbwe', code: 'ZA');
    await _firestore.collection('countries').add(t2.toJson()).catchError((e) {
      return 1;
    });
    var t3 = new Country(name: 'Lesotho', code: 'ZA');
    await _firestore.collection('countries').add(t3.toJson()).catchError((e) {
      return 1;
    });
    var t4 = new Country(name: 'Mozambique', code: 'ZA');
    await _firestore.collection('countries').add(t4.toJson()).catchError((e) {
      return 1;
    });
    var t5 = new Country(name: 'Namibia', code: 'ZA');
    await _firestore.collection('countries').add(t5.toJson()).catchError((e) {
      return 1;
    });
    var t6 = new Country(name: 'Kenya', code: 'ZA');
    await _firestore.collection('countries').add(t6.toJson()).catchError((e) {
      return 1;
    });
    var t7 = new Country(name: 'Botswana', code: 'ZA');
    await _firestore.collection('countries').add(t7.toJson()).catchError((e) {
      return 1;
    });
    var t8 = new Country(name: 'Swaziland', code: 'ZA');
    await _firestore.collection('countries').add(t8.toJson()).catchError((e) {
      return 1;
    });
    var t9 = new Country(name: 'Uganda', code: 'ZA');
    await _firestore.collection('countries').add(t9.toJson()).catchError((e) {
      return 1;
    });
    var t10 = new Country(name: 'Tanzania', code: 'ZA');
    await _firestore.collection('countries').add(t10.toJson()).catchError((e) {
      return 1;
    });
    var t11 = new Country(name: 'Zambia', code: 'ZA');
    await _firestore.collection('countries').add(t11.toJson()).catchError((e) {
      return 1;
    });
    var t12 = new Country(name: 'Malawi', code: 'ZA');
    await _firestore.collection('countries').add(t12.toJson()).catchError((e) {
      return 1;
    });
    return 0;
  }

  static Future<int> storePrivateSectorTypes() async {
    var t1 = new PrivateSectorType(type: 'Retail');
    await _firestore
        .collection('privateSectorTypes')
        .add(t1.toJson())
        .catchError((e) {
      return 1;
    });
    var t2 = new PrivateSectorType(type: 'Financial Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t2.toJson())
        .catchError((e) {
      return 1;
    });
    var t3 = new PrivateSectorType(type: 'Education & Training');
    await _firestore
        .collection('privateSectorTypes')
        .add(t3.toJson())
        .catchError((e) {
      return 1;
    });
    var t4 = new PrivateSectorType(type: 'Agriculture');
    await _firestore
        .collection('privateSectorTypes')
        .add(t4.toJson())
        .catchError((e) {
      return 1;
    });
    var t5 = new PrivateSectorType(type: 'Professional Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t5.toJson())
        .catchError((e) {
      return 1;
    });
    var t6 = new PrivateSectorType(type: 'Industrial');
    await _firestore
        .collection('privateSectorTypes')
        .add(t6.toJson())
        .catchError((e) {
      return 1;
    });
    var t7 = new PrivateSectorType(type: 'Health');
    await _firestore
        .collection('privateSectorTypes')
        .add(t7.toJson())
        .catchError((e) {
      return 1;
    });
    var t8 = new PrivateSectorType(type: 'Transportation');
    await _firestore
        .collection('privateSectorTypes')
        .add(t8.toJson())
        .catchError((e) {
      return 1;
    });
    var t9 = new PrivateSectorType(type: 'Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t9.toJson())
        .catchError((e) {
      return 1;
    });
    var t10 = new PrivateSectorType(type: 'Infrastructure');
    await _firestore
        .collection('privateSectorTypes')
        .add(t10.toJson())
        .catchError((e) {
      return 1;
    });
    var t11 = new PrivateSectorType(type: 'Event Management');
    await _firestore
        .collection('privateSectorTypes')
        .add(t11.toJson())
        .catchError((e) {
      return 1;
    });
    var t12 = new PrivateSectorType(type: 'Catering');
    await _firestore
        .collection('privateSectorTypes')
        .add(t12.toJson())
        .catchError((e) {
      return 1;
    });
    var t13 = new PrivateSectorType(type: 'Electrical Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t13.toJson())
        .catchError((e) {
      return 1;
    });
    var t14 = new PrivateSectorType(type: 'Construction');
    await _firestore
        .collection('privateSectorTypes')
        .add(t14.toJson())
        .catchError((e) {
      return 1;
    });
    var t15 = new PrivateSectorType(type: 'Information & Technology');
    await _firestore
        .collection('privateSectorTypes')
        .add(t15.toJson())
        .catchError((e) {
      return 1;
    });
    var t16 = new PrivateSectorType(type: 'Engineering');
    await _firestore
        .collection('privateSectorTypes')
        .add(t16.toJson())
        .catchError((e) {
      return 1;
    });
    var t17 = new PrivateSectorType(type: 'Manufacturing');
    await _firestore
        .collection('privateSectorTypes')
        .add(t17.toJson())
        .catchError((e) {
      return 1;
    });
    var t18 = new PrivateSectorType(type: 'Social Services');
    await _firestore
        .collection('privateSectorTypes')
        .add(t18.toJson())
        .catchError((e) {
      return 1;
    });

    return 0;
  }
}

class PrivateSectorType {
  String type;

  PrivateSectorType({@required this.type});
  PrivateSectorType.fromJson(Map data) {
    this.type = data['type'];
  }
  Map<String, String> toJson() => <String, String>{
        'type': type,
      };
}

class Country {
  String name, code;

  Country({this.name, this.code});
  Country.fromJson(Map data) {
    this.name = data['name'];
    this.code = data['code'];
  }
  Map<String, String> toJson() => <String, String>{
        'name': name,
        'code': code,
      };
}

String getFormattedDateMedium(String date, BuildContext context) {
  var cc = MaterialLocalizations.of(context);
  return cc.formatMediumDate(DateTime.parse(date));
}

String getFormattedDateLong(String date, BuildContext context) {
  var cc = MaterialLocalizations.of(context);
  return cc.formatFullDate(DateTime.parse(date));
}

String getFormattedDate(String date) {
  DateTime d = DateTime.parse(date);
  var format = new DateFormat.yMMMd();
  return format.format(d);
}

String getFormattedLongestDate(String date) {
  DateTime d = DateTime.parse(date);
  var format = new DateFormat.yMMMMEEEEd();
  return format.format(d);
}

String getFormattedAmount(String amount, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = myLocale.languageCode + '_' + myLocale.countryCode;
  //print('getFormattedAmount ----------- locale is  $val');
  final oCcy = new NumberFormat("#,##0.00", val);
  double m = double.parse(amount);

  return oCcy.format(m);
}

prettyPrint(Map map, String name) {
  print('\n\n$name \t{\n');
  map.forEach((key, val) {
    print('\t$key : $val ,\n');
  });
  print('\n}\n\n');
}
