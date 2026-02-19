import 'dart:convert';
import 'package:http/http.dart' as http;

class MLService {
  static const String baseUrl = "http://10.0.2.2:8000";

  static Future<double> predictBill({
    required double totalDailyUnits,
    required int month,
    required double unitRate,
  }) async {
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
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["predicted_bill"] as num).toDouble();
    } else {
      throw Exception(
          "Server error: ${response.statusCode} - ${response.body}");
    }
  }
}
