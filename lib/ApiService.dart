import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl; // Base URL of the API

  ApiService({required this.baseUrl});

  /// Generic GET Request
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to GET data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during GET request: $e');
    }
  }

  /// Generic POST Request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to POST data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during POST request: $e');
    }
  }
}
