import 'package:http/http.dart' as http;

import '../constants/connected_status.dart';

Future<String> checkInternet() async {
  final url = Uri.parse("https://fixpals-public-backend.herokuapp.com/");
  try {
    await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    ).timeout(const Duration(seconds: 8));
    return CONNECTED;
  } catch (error) {
    return DISCONNECTED;
  }
}
