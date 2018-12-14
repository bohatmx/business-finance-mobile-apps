import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/govt_entity.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/chat_page.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/support_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();

}

class _ContactUsState extends State<ContactUs> {
  GoogleMapController _mapController;
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;
  Investor investor;
  Supplier supplier;
  GovtEntity customer;
  User user;
  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;
  double mLat = -25.883328, mLng = 28.168771;
  String userType;
  Image image1;
  static const String USER_SUPPLIER = '1', USER_INVESTOR = '2', USER_CUSTOMER = '3';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
    getCached();

  }
void getCached() async {
  user = await SharedPrefs.getUser();
  customer = await SharedPrefs.getGovEntity();
  investor = await SharedPrefs.getInvestor();
  supplier = await SharedPrefs.getSupplier();

  if (customer != null) {
    userType = USER_CUSTOMER;
  }
  if (investor != null) {
    userType = USER_INVESTOR;
  }
  if (supplier != null) {
    userType = USER_SUPPLIER;
  }
  _locationSubscription =
      _location.onLocationChanged().listen((Map<String, double> result) {
      });
  print('_ContactUsState.getCached user: ${user.toJson()}');
}
  void getLocation() async {}
  initPlatformState() async {
    print('_ContactUsState.initPlatformState ..............................');
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();
      print(
          '_ContactUsState.initPlatformState permission: $_permission location: $location');
      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

    if (location != null) {}
    setState(() {
      _startLocation = location;
    });
  }

  Widget _getBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(120.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:20.0),
            child: Text(
              '340 Witch Hazel Avenue, Centurion',
              style: Styles.whiteBoldSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top:8.0, bottom: 30.0, left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: _onPhoneTapped,
                  child: Text(
                    '012 346 5670',
                    style: Styles.whiteBoldLarge,
                  ),
                ),
                SizedBox(width: 20.0,),
                IconButton(
                  icon: Icon(Icons.email, color: Colors.white,), onPressed: _onEmailTapped,
                ),
                SizedBox(width: 20.0,),
                IconButton(
                  icon: Icon(Icons.chat, color: Colors.white,), onPressed: _onChatTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('BFN - OneConnect'),
        bottom: _getBottom(),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          print('_ContactUsState.build ------ onMapCreated');
          _mapController = controller;
          setMapStuff();
        },
        options: GoogleMapOptions(
          myLocationEnabled: true,
          compassEnabled: true,
          zoomGesturesEnabled: true,
        ),
      ),
    );
  }

  void setMapStuff() {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(mLat, mLng), zoom: 12.0)));
    _mapController.addMarker(MarkerOptions(
      position: LatLng(mLat, mLng),
      icon: BitmapDescriptor.fromAsset('assets/computers.png'), zIndex: 4.0,
      infoWindowText: InfoWindowText('OneConnect', 'We are the FinTech People'),
    ));
  }
  void _onPhoneTapped() {
    print('_ContactUsState._onPhoneTapped ............');
  }
  void _onEmailTapped() {
    print('_ContactUsState._onEmailTapped ............');
    print('_ContactUsState._onEmailTapped userType; $userType');
    assert(userType != null);
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => SupportEmail(userType)),
    );
  }
  void _onChatTapped() {
    print('_ContactUsState._onChatTapped ............');
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => ChatPage()),
    );
  }
}
