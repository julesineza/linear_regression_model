import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://linear-regression-model-w79d.onrender.com';

  /// Checks GET / to see if the Render server is awake and online
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 90));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sends POST /predict and returns the formatted prediction string
  static Future<String> predictYield({
    required String country,
    required String product,
    required String seasonName,
    required String productionSystem,
    required double area,
    required int plantingYear,
    required int plantingMonth,
    required int harvestMonth,
  }) async {
    final Map<String, dynamic> requestBody = {
      'country': country,
      'product': product,
      'season_name': seasonName,
      'crop_production_system': productionSystem,
      'area': area,
      'planting_year': plantingYear,
      'planting_month': plantingMonth,
      'harvest_month': harvestMonth,
    };

    final response = await http
        .post(
          Uri.parse('$baseUrl/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dynamic rawPrediction = data is Map
          ? (data['prediction'] ??
              data['predicted_yield'] ??
              data['yield'] ??
              data.values.first)
          : data;

      return rawPrediction is num
          ? rawPrediction.toStringAsFixed(2)
          : rawPrediction.toString();
    } else {
      throw Exception('API Error (${response.statusCode}): ${response.body}');
    }
  }
}