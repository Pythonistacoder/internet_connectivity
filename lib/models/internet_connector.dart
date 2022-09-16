import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnector {
  final Connectivity _connectivity = Connectivity();

  Stream<String> getInternetStatusStream() async* {
    final Stream<ConnectivityResult> connectivityStream =
        _connectivity.onConnectivityChanged;
    await for (final connectivityResult in connectivityStream) {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        yield "CONNECTED";
      } else {
        yield "DISCONNECTED";
      }
    }
  }
}
