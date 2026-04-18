import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://dubbed-disregard-deepness.ngrok-free.dev";

  static Future<Map<String, dynamic>?> detectPest(File image) async {
    print("🔥 API CALLED");

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

      var response = await request.send();

      print("📡 Status Code: ${response.statusCode}");

      var respStr = await response.stream.bytesToString();
      print("📦 Response Body: $respStr");

      if (response.statusCode == 200) {
        return jsonDecode(respStr);
      } else {
        print("❌ Error: ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Exception: $e");
    }

    return null;
  }
}