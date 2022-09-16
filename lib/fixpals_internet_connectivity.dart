library fixpals_internet_connectivity;

import 'dart:async';
import 'package:fixpals_internet_connectivity/constants/connected_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/internet_bloc/internet_events.dart';
import 'blocs/internet_bloc/internet_states.dart';
import 'models/internet_connector.dart';
import 'utils/check_internet.dart';

class InternetConnectivityBloc extends Bloc<InternetEvent, InternetState> {
  final InternetConnector _internetConnector = InternetConnector();
  StreamSubscription? _internetSubscription;
  Timer? _timer;

  String onlineStatus = DISCONNECTED;

  InternetConnectivityBloc() : super(InternetInitialState()) {
    on<InternetLostEvent>((event, emit) => emit(InternetLostState()));
    on<InternetRetrievedEvent>((event, emit) => emit(InternetRetrievedState()));

    _internetSubscription =
        _internetConnector.getInternetStatusStream().listen((result) {
      if (result == CONNECTED) {
        _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
          checkInternet().then((String connectionStatus) {
            if (connectionStatus == CONNECTED) {
              if (onlineStatus != connectionStatus) {
                add(InternetRetrievedEvent());
                onlineStatus = connectionStatus;
              }
            } else {
              if (onlineStatus != connectionStatus) {
                add(InternetLostEvent());
                onlineStatus = connectionStatus;
              }
            }
          });
        });
        onlineStatus = CONNECTED;
        add(InternetRetrievedEvent());
      } else {
        _timer?.cancel();
        onlineStatus = DISCONNECTED;
        add(InternetLostEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _internetSubscription?.cancel();
    return super.close();
  }
}
