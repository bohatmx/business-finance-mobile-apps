class Util {
  static const DEBUG_URL_HOME = 'http://192.168.86.238:3003/api/'; //FIBRE
  static const DEBUG_URL_ROUTER = 'http://192.168.8.237:3003/api/'; //ROUTER
  static const RELEASE_URL = 'http://192.168.86.238:3003/api/'; //CLOUD

  static String getURL() {
    var url;
    if (isInDebugMode) {
      url = DEBUG_URL_HOME; //switch  to DEBUG_URL_ROUTER before demo
    } else {
      url = RELEASE_URL;
    }
    return url;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
