import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _baseUrl =
      "https://v6.exchangerate-api.com/v6/4b84269c238e51037340acdf/latest/USD";

  Future<Map<String, dynamic>> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch exchange rates");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
