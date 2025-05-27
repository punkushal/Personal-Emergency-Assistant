import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:personal_emergency_assistant/constants/app_constants.dart';
import 'package:personal_emergency_assistant/models/alert.dart';

class AlertApiService {
  //fetch weather alerts
  Future<Alert> fetchWeatherAlerts(String lat, String lon) async {
    try {
      final queryParams = {'key': dotenv.env['API_KEY'], 'q': '$lat,$lon'};

      final uri = Uri.parse(
        AppConstants.weatherApiBaseUrl,
      ).replace(queryParameters: queryParams);

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        return Alert.fromWeatherApi(data);
      } else {
        throw Exception('Failed to load weather alerts: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather alerts: $e');
    }
  }
}
