library fixpals_internet_connectivity;

import 'dart:async';
import 'package:backend_connect/response/models/abstract/api_response_model.dart';
import 'package:backend_connect/response/models/implementation/error_model.dart';
import 'package:backend_connect/response/models/implementation/response_model.dart';
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

  ///TODO: while creating a bloc to fetch data from backend try to link that block with this bloc
  ///so that if there is a response model it gets connected and if its
  ///error model then it disconnects the internet
  ///
  ///also try to break the timer if there is a request and set the timer again

  void checkInternetConnection(ApiResponseModel responseModel) {
    if (responseModel is ResponseModel) {
      onlineStatus = CONNECTED;
      add(InternetRetrievedEvent());
    } else if (responseModel is ErrorModel) {
      onlineStatus = DISCONNECTED;
      add(InternetLostEvent());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _internetSubscription?.cancel();
    return super.close();
  }
}
