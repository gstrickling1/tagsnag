import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plate_result.dart';
import '../models/suggestion.dart';

class ApiService {
  // TODO: Update with your deployed backend URL
  static const String baseUrl = 'https://tagsnag-qs2s.onrender.com/api';

  static Future<PlateResult> checkPlate(String plate, {String state = 'GA', String vehicleType = 'car'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-plate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'plate': plate, 'state': state, 'vehicle_type': vehicleType}),
    );

    if (response.statusCode == 200) {
      return PlateResult.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to check plate: ${response.statusCode}');
  }

  static Future<List<String>> getSuggestions(String interest, {String state = 'GA', String vehicleType = 'car'}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/suggest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'interest': interest, 'state': state, 'vehicle_type': vehicleType}),
    );

    if (response.statusCode == 200) {
      return SuggestResponse.fromJson(jsonDecode(response.body)).suggestions;
    }
    throw Exception('Failed to get suggestions: ${response.statusCode}');
  }

  static Future<ChatRefineResponse> chatRefine({
    required String interest,
    required String message,
    required List<Map<String, String>> history,
    String state = 'GA',
    String vehicleType = 'car',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat-refine'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'interest': interest,
        'message': message,
        'history': history,
        'state': state,
        'vehicle_type': vehicleType,
      }),
    );

    if (response.statusCode == 200) {
      return ChatRefineResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to refine: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getClaimInfo(String state) async {
    final response = await http.get(
      Uri.parse('$baseUrl/claim-info/$state'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get claim info: ${response.statusCode}');
  }
}
