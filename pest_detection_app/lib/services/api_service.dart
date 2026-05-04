import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://pest-backend-3lmw.onrender.com";

  static Future<Map<String, dynamic>?> detectPest(File image) async {
    print("🔥 API CALLED");
    print("➡️ URL: $baseUrl/detect-pest");

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/detect-pest'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      // IMPORTANT HEADERS
      request.headers.addAll({
        "Accept": "application/json",
      });

      // TIMEOUT ADDED (VERY IMPORTANT FOR RENDER)
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 120));

      print("📡 Status Code: ${streamedResponse.statusCode}");

      var response = await http.Response.fromStream(streamedResponse);

      print("📦 Response Body: ${response.body}");

      if (streamedResponse.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Error: ${streamedResponse.statusCode}");
      }
    } catch (e) {
      print("💥 Exception: $e");
    }

    return null;
  }
}