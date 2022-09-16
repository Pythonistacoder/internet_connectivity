library fixpals_internet_connectivity;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/internet_bloc/internet_events.dart';
import 'blocs/internet_bloc/internet_states.dart';
import 'models/internet_connector.dart';

class InternetConnectivityBloc extends Bloc<InternetEvent, InternetState> {
  // final Connectivity _connectivity = Connectivity();
  // StreamSubscription? connectivitySubscription;
  final InternetConnector _internetConnector = InternetConnector();
  StreamSubscription? _internetSubscription;
  InternetConnectivityBloc() : super(InternetInitialState()) {
    on<InternetLostEvent>((event, emit) => emit(InternetLostState()));
    on<InternetRetrievedEvent>((event, emit) => emit(InternetRetrievedState()));

    _internetSubscription =
        _internetConnector.getInternetStatusStream().listen((result) {
      if (result == "CONNECTED") {
        add(InternetRetrievedEvent());
      } else {
        add(InternetLostEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _internetSubscription?.cancel();
    return super.close();
  }
}
