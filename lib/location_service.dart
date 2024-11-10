// location_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch location data using pincode
Future<Map<String, String>> fetchLocationData(String pincode) async {
  try {
    final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data[0]['Status'] == 'Success') {
        // Extract city and state from the API response
        String city = data[0]['PostOffice'][0]['Division'] ?? 'N/A';
        String state = data[0]['PostOffice'][0]['State'] ?? 'N/A';
        return {'city': city, 'state': state};
      } else {
        return {'city': 'Invalid Pincode', 'state': 'N/A'};
      }
    } else {
      throw Exception('Failed to load location data');
    }
  } catch (e) {
    print("Error fetching location data: $e");
    throw Exception('Failed to fetch location data');
  }
}
