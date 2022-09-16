import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/check_internet.dart';

class InternetConnector {
  final Connectivity _connectivity = Connectivity();

  Stream<String> getInternetStatusStream() async* {
    final Stream<ConnectivityResult> connectivityStream =
        _connectivity.onConnectivityChanged;
    await for (final connectivityResult in connectivityStream) {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        await for (final value
            in Stream.periodic(const Duration(seconds: 10))) {
          yield await checkInternet();
        }
      } else {
        yield "DISCONNECTED";
      }
    }
  }
}
