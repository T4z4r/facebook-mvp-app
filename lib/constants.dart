// class Constants {
//   static const String apiBaseUrl = 'http://192.168.1.107:8000/api';
// }

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
}
