import 'dart:convert';
import 'package:http/http.dart' as http;

class MLService {
  // Use http://10.0.2.2:8000 for Android Emulator
  // Use http://localhost:8000 for Windows/Web
  static const String baseUrl = "http://10.0.2.2:8000";
  static const Duration timeout = Duration(seconds: 30);
  
  // Simple caching mechanism
  static final Map<String, dynamic> _predictCache = {};
  static const int _cacheMaxSize = 50;

  static Future<double> predictBill({
    required double totalDailyUnits,
    required int month,
    required double unitRate,
  }) async {
    // Create cache key
    final cacheKey = '${totalDailyUnits}_${month}_$unitRate';
    
    // Return cached result if exists
    if (_predictCache.containsKey(cacheKey)) {
      return _predictCache[cacheKey] as double;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "total_daily_units": totalDailyUnits,
          "month": month,
          "unit_rate": unitRate,
        }),
      ).timeout(timeout, onTimeout: () {
        throw Exception("Prediction request timeout after $timeout");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prediction = (data["predicted_bill"] as num).toDouble();
        
        // Store in cache with size limit
        if (_predictCache.length >= _cacheMaxSize) {
          _predictCache.remove(_predictCache.keys.first);
        }
        _predictCache[cacheKey] = prediction;
        
        return prediction;
      } else {
        throw Exception(
            "Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Prediction failed: $e");
    }
  }

  /// Clear cache when needed (e.g., on logout)
  static void clearCache() {
    _predictCache.clear();
  }
}
