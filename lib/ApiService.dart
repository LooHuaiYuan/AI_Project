import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Expense.dart';

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

  /// Fetches data from the database
  Future<List<Expense>> fetchData() async {
    try {
      final rawData = await get('');
      print(rawData); // Debugging: Check the raw data structure

      // Ensure rawData is treated as a List<dynamic>
      final data = (rawData as List<dynamic>)
          .map((item) {
        // Each item is a List<dynamic> with a known structure
        final list = item as List<dynamic>;
        return Expense(
          category: list[0] as String,
          totalPrice: (list[1] as num).toDouble(), // Ensure double conversion
          date: DateTime.parse(list[2] as String),
        );
      })
          .toList();

      return data;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

}
