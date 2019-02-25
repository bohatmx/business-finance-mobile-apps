import 'dart:async';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:businesslibrary/data/customer.dart';
import 'package:businesslibrary/data/investor.dart';
import 'package:businesslibrary/data/supplier.dart';
import 'package:businesslibrary/data/user.dart';
import 'package:businesslibrary/util/page_util/data.dart';
import 'package:businesslibrary/util/page_util/intro_page_view.dart';
import 'package:businesslibrary/util/styles.dart';
import 'package:businesslibrary/util/support/chat_page.dart';
import 'package:businesslibrary/util/support_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  final Function receiveResponse;

  const ContactUs({Key key, this.receiveResponse}) : super(key: key);

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs>
    with SingleTickerProviderStateMixin {
  GoogleMapController _mapController;
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;
  Investor investor;
  Supplier supplier;
  Customer customer;
  User user;
  StreamSubscription<Map<String, double>> _locationSubscription;
  AnimationController _animationController;
  Animation<double> _animation;

  Location _location = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;
  double mLat = -25.883328, mLng = 28.168771;
  String userType;
  Image image1;
  static const String USER_SUPPLIER = '1',
      USER_INVESTOR = '2',
      USER_CUSTOMER = '3';
  bool isIOS;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getCached();

    _animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _location.onLocationChanged().listen((Map<String, double> result) {});
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
      preferredSize: Size.fromHeight(140.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              '340 Witch Hazel Avenue, Centurion',
              style: Styles.whiteBoldSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
            child: Divider(
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 30.0, left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FadeTransition(
                  opacity: _animation,
                  child: IconButton(
                    icon: Icon(
                      Icons.phone,
                      size: 30.0,
                      color: Colors.black,
                    ),
                    onPressed: _onPhoneTapped,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                IconButton(
                  icon: Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  onPressed: _onEmailTapped,
                ),
                SizedBox(
                  width: 20.0,
                ),
                IconButton(
                  icon: Icon(
                    Icons.chat,
                    color: Colors.white,
                  ),
                  onPressed: _onChatTapped,
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
      body: Stack(
        children: <Widget>[
          GoogleMap(
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
          Positioned(
            left: 10.0,
            top: 10.0,
            child: FloatingActionButton(
              onPressed: _onMapTypeToggle,
              elevation: 16.0,
              mini: true,
              child: Icon(
                Icons.map,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 100.0,
            right: 100.0,
            bottom: 10.0,
            child: RaisedButton(
              elevation: 16.0,
              color: Colors.pink,
              onPressed: _onPressed,
              child: Text(
                'More Information',
                style: Styles.whiteSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setMapStuff() {
    _mapController.updateMapOptions(GoogleMapOptions(
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal));

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(mLat, mLng), zoom: 12.0)));
    _mapController.addMarker(MarkerOptions(
      position: LatLng(mLat, mLng),
      icon: BitmapDescriptor.fromAsset('assets/computers.png'),
      zIndex: 4.0,
      infoWindowText:
          InfoWindowText('OneConnect BFN', 'We are the FinTech People'),
    ));
  }

  void _onPhoneTapped() async {
    print('_ContactUsState._onPhoneTapped ............');
    const url = 'tel:0710441887';
    try {
      if (await canLaunch(url)) {
        await launch("tel:0710441887");
      }
    } catch (e) {
      print('_ContactUsState._onPhoneTapped ERROR ERROR ERROR ERROR');
      print(e);
    }
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
      new MaterialPageRoute(
          builder: (context) => ChatPage(
                doSomething: doSomething,
              )),
    );
  }

  void doSomething() {
    print(
        '\n\n_ContactUsState.doSomething ......... YAY! executed by child widget');
  }

  void _onPressed() {
    print('_ContactUsState._onPressed ...');
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => IntroPageView(items: sampleItems, user: user)),
    );
  }

  int toggle = 0;
  void _onMapTypeToggle() {
    if (toggle == null) {
      toggle = 0;
    } else {
      if (toggle == 0) {
        toggle = 1;
      } else {
        if (toggle == 1) {
          toggle = 2;
        } else {
          if (toggle == 2) {
            toggle = 0;
          }
        }
      }
    }
    switch (toggle) {
      case 0:
        _doNormalMap();
        break;
      case 1:
        _doTerrainMap();
        break;
      case 2:
        _doSatelliteMap();
        break;
    }
  }

  void _doTerrainMap() {
    _mapController.updateMapOptions(GoogleMapOptions(
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.terrain));
  }

  void _doSatelliteMap() {
    _mapController.updateMapOptions(GoogleMapOptions(
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.satellite));
  }

  void _doNormalMap() {
    _mapController.updateMapOptions(GoogleMapOptions(
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.normal));
  }
}
