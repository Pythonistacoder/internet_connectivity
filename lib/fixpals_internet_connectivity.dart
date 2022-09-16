library fixpals_internet_connectivity;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/internet_bloc/internet_events.dart';
import 'blocs/internet_bloc/internet_states.dart';
import 'models/internet_connector.dart';
import 'utils/check_internet.dart';

class InternetConnectivityBloc extends Bloc<InternetEvent, InternetState> {
  // final Connectivity _connectivity = Connectivity();
  // StreamSubscription? connectivitySubscription;
  final InternetConnector _internetConnector = InternetConnector();
  StreamSubscription? _internetSubscription;
  Timer? _timer;

  InternetConnectivityBloc() : super(InternetInitialState()) {
    on<InternetLostEvent>((event, emit) => emit(InternetLostState()));
    on<InternetRetrievedEvent>((event, emit) => emit(InternetRetrievedState()));

    _internetSubscription =
        _internetConnector.getInternetStatusStream().listen((result) {
      if (result == "CONNECTED") {
        _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          checkInternet().then((String connectionStatus) {
            if (connectionStatus == "CONNECTED") {
              add(InternetRetrievedEvent());
            } else {
              add(InternetLostEvent());
            }
          });
        });
        add(InternetRetrievedEvent());
      } else {
        if (_timer != null) _timer!.cancel();
        add(InternetLostEvent());
      }
    });
  }

  @override
  Future<void> close() {
    if (_timer != null) _timer!.cancel();
    _internetSubscription?.cancel();
    return super.close();
  }
}
